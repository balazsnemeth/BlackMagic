//
//  SettingsHandler.m
//  diaproIPad3
//
//  Created by Németh Balázs on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsHandler.h"

@interface SettingsHandler()

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation SettingsHandler

static SettingsHandler *sharedSettings = nil;

+ (SettingsHandler*)sharedSettings
{
    @synchronized(self)
    {
        if (sharedSettings == nil)
            sharedSettings = [[SettingsHandler alloc] init];
    }
    return sharedSettings;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedSettings == nil) {
            sharedSettings = [super allocWithZone:zone];
            return sharedSettings;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


+ (id)alloc {
    @synchronized(self) {
        if (sharedSettings == nil) {
            sharedSettings = [super alloc];
            return sharedSettings;  // assignment and return on first allocation
        }
    }
    return sharedSettings; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void) initDefaultSettings{
    self.defaultSelectionTrueOrFalse = TRUE;
    self.letTheAppSleep = NO;
    self.serverIPAddress = @"localhost";
    self.useExternalScreen=TRUE;
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"defaultSettingsExist"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id) init {
	if (self = [super init]) {
        if (![self existDefaultSettings]) {
            [self initDefaultSettings];
        }
    }
    return self;
}

- (BOOL) existDefaultSettings{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"defaultSettingsExist"];
}


#pragma mark - settings

- (BOOL)letTheAppSleep {    
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"letTheAppSleep"];
}

- (void)setLetTheAppSleep:(BOOL)on {
    if (on == self.letTheAppSleep) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"letTheAppSleep"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) defaultSelectionTrueOrFalse{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"defaultSelectionTrueOrFalse"];
}

- (void)setDefaultSelectionTrueOrFalse:(BOOL)on {
    if (on == self.defaultSelectionTrueOrFalse) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"defaultSelectionTrueOrFalse"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setUseExternalScreen:(BOOL)useExternalScreen{
    if (useExternalScreen == self.useExternalScreen) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:useExternalScreen forKey:@"useExternalScreen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL) useExternalScreen{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"useExternalScreen"];
}



- (NSString*) serverIPAddress{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"serverIPAddress"];
}

- (void) setServerIPAddress:(NSString *)serverIPAddress{
    if ([serverIPAddress isEqualToString:self.serverIPAddress]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:serverIPAddress forKey:@"serverIPAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




@end
