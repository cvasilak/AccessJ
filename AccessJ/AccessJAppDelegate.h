//
//  AccessJAppDelegate.h
//  AccessJ
//
//  Created by Christos Vasilakis on 14/06/2011.
//  Copyright 2011 forthnet S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccessJAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController *navController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@end
