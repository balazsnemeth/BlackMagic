//
//  SettingsHandler.h
//  diaproIPad3
//
//  Created by Németh Balázs on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsHandler : NSObject

/*
 Determine the app to move background or not.
 **/
@property (nonatomic) BOOL letTheAppSleep;
/*
 Specify whether the verses are selected or not in the songlist editor.
 **/
@property (nonatomic) BOOL defaultSelectionTrueOrFalse;
/*
 Specify whether an external screen is used or not.
 **/
@property (nonatomic) BOOL useExternalScreen;

/*
 Specify whether the AI plays or the user.
 **/
@property (nonatomic) BOOL autoPlayByAI;


/**
 Set (or get) the name of the device
 */
@property (nonatomic,strong) NSString* serverIPAddress;

/**
 Set (or get) the name of the device
 */
@property (nonatomic) NSInteger serverPort;

/*
 Update the input device with the stored data.
 **/
+ (SettingsHandler*)sharedSettings;

@end
