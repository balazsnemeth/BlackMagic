//
//  BMNetworkManager.m
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMNetworkManager.h"
#import "SettingsHandler.h"
#import "AFNetworking.h"
#import "BMCard.h"

@interface BMNetworkManager()

/**Seconds*/
@property (nonatomic) NSTimeInterval pollingPeriod;
@property (nonatomic,strong) NSTimer* pollingTimer;
@property (nonatomic,getter = isPolling) BOOL polling;

@end

@implementation BMNetworkManager


static BMNetworkManager *sharedNetworkManager = nil;

+ (BMNetworkManager*) sharedManager
{
    @synchronized(self)
    {
        if (sharedNetworkManager == nil)
            sharedNetworkManager = [[BMNetworkManager alloc] init];
    }
    return sharedNetworkManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _pollingPeriod = 0.1;
        _polling = FALSE;
    }
    return self;
}

- (NSString*) urlStrWithEnd:(NSString*)end{
    NSString* urlStr = [NSString stringWithFormat:@"http://%@/%@",[SettingsHandler sharedSettings].serverIPAddress,end];
    return urlStr;
}

- (void) networkRequestForUrlPath:(NSString*)urlPart withParameters:(NSDictionary*)parameters onCompletion:(void (^)(NSDictionary *result))success
                              failure:(void (^)(NSError *error))failure{
    NSString* urlStr = [self urlStrWithEnd: urlPart];
    //NSLog(@"url - %@",urlStr);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* res = (NSDictionary*)responseObject;
        NSDictionary* finalRes = [res objectForKey:@"result"];
        NSArray* finalError = [res objectForKey:@"error"];
        NSString* finSuccess = [res objectForKey:@"success"];
        if ([finSuccess isEqualToString:@"yes"]) {
            if (success) {
                success(finalRes);
            }
        }
        else{
            if (failure) {
                if ([finalError isKindOfClass:NSArray.class]) {
                    failure([NSError errorWithDomain:[finalError componentsJoinedByString:@", "] code:-1 userInfo:nil]);
                }
                else
                    failure([NSError errorWithDomain:(NSString*)finalError code:-1 userInfo:nil]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];

}


- (void) registerPlayer:(NSString*)playerName onCompletion:(void (^)(NSDictionary *result))success
                failure:(void (^)(NSError *error))failure{
    [self networkRequestForUrlPath:@"registerPlayer" withParameters:@{@"name":playerName} onCompletion:success failure:failure];
}

- (void) requestNextMove:(NSString*)playerName{
//    [self networkRequestForUrlPath:@"registerPlayer" withParameters:@{@"name":playerName} onCompletion:success failure:failure];

}

/**Csak akkor fut compleation-be, ha a procees true, és van az ellenfélnek lépése.*/
- (void) startRequestNextMove:(NSString*)playerName onCompletion:(void (^)(NSDictionary *result))success
                      failure:(void (^)(NSError *error))failure{
    
    [self.pollingTimer invalidate];
    self.pollingTimer = nil;
    self.polling = TRUE;
    
    
/*    self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:self.pollingPeriod
                                                    target:self
                                                       selector:@selector(checkEnemyNextMove:)
                                                  userInfo:@{@"name": playerName,@"completionBlock":success,@"failureBlock":failure}
                                                   repeats:YES];*/
    self.pollingTimer = [NSTimer timerWithTimeInterval:self.pollingPeriod
                                                        target:self
                                                       selector:@selector(checkEnemyNextMove:)
                                                       userInfo:@{@"name": playerName,@"completionBlock":success,@"failureBlock":failure}
                                                        repeats:YES];
    [self checkEnemyNextMove:self.pollingTimer];
}


- (void) proceedPlayer:(NSString*)playerName withInput:(NSDictionary*)step  onCompletion:(void (^)(NSDictionary *result))success
               failure:(void (^)(NSError *error))failure{
    
    
    
    NSMutableDictionary *myNewDictionary = [@{@"name": playerName} mutableCopy];
   // [myNewDictionary addEntriesFromDictionary:step];
    
    NSString* url = [NSString stringWithFormat:@"proceedWithInput?name=%@",playerName];
    for (NSString* key in [step allKeys]) {
        NSString* aktPar = [NSString stringWithFormat:@"&%@=%@",key,step[key]];
        url = [url stringByAppendingString:aktPar];
    }
    NSLog(@"url: %@",url);
    [self networkRequestForUrlPath:url withParameters:nil onCompletion:success failure:failure];
}


- (void) restartGameOnCompletion:(void (^)())success failure:(void (^)(NSError *error))failure{
    [self networkRequestForUrlPath:@"restartGame" withParameters:nil onCompletion:success failure:failure];
}

- (void) resetServerOnCompletion:(void (^)())success failure:(void (^)(NSError *error))failure{
    [self networkRequestForUrlPath:@"resetServer" withParameters:nil onCompletion:success failure:failure];
}


- (void) checkEnemyNextMove:(NSTimer*)timer{
    //NSLog(@"enemi check");
    NSDictionary* p = @{@"name": timer.userInfo[@"name"]};
    void (^completionBlock)(NSDictionary *result) = timer.userInfo[@"completionBlock"];
    void (^failureBlock)(NSError *error) = timer.userInfo[@"failureBlock"];

    [self networkRequestForUrlPath:@"getNextMove" withParameters:p onCompletion:^(NSDictionary *result) {
        NSNumber* proceed = [result objectForKey:@"proceed"];
        if (proceed.boolValue) {
            if (self.isPolling) {
                self.polling = FALSE;
                [self.pollingTimer invalidate];
                self.pollingTimer = nil;
                completionBlock(result);
            }
        }
        else{
            //Újra nézem!
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self checkEnemyNextMove:timer];
            });
        }
    } failure:^(NSError *error) {
        if (self.isPolling) {
            if (error.code != -1) {
                self.polling = FALSE;
                [self.pollingTimer invalidate];
                self.pollingTimer = nil;
                failureBlock(error);
            }
            else{
                double delayInSeconds = 0.1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self checkEnemyNextMove:timer];
                });
            }
        }
    }];
}


@end
