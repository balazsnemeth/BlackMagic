//
//  BMNetworkManager.h
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMMIResult.h"

@interface BMNetworkManager : NSObject

+ (BMNetworkManager*) sharedManager;

- (void) registerPlayer:(NSString*)playerName onCompletion:(void (^)(NSDictionary *result))success
                failure:(void (^)(NSError *error))failure;

/**Csak akkor fut compleation-be, ha a procees true, és van az ellenfélnek lépése.*/
- (void) startRequestNextMove:(NSString*)playerName onCompletion:(void (^)(NSDictionary *result))success
                               failure:(void (^)(NSError *error))failure;


- (void) proceedPlayer:(NSString*)playerName withInput:(NSDictionary*)step  onCompletion:(void (^)(NSDictionary *result))success
                      failure:(void (^)(NSError *error))failure;


- (void) restartGameOnCompletion:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void) resetServerOnCompletion:(void (^)())success failure:(void (^)(NSError *error))failure;


@end
