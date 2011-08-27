//
//  AccessJAppDelegate.m
//  AccessJ
//
//  Created by Christos Vasilakis on 14/06/2011.
//  Copyright 2011 forthnet S.A. All rights reserved.
//

#import "AccessJAppDelegate.h"

#import "ServersManager.h"

#import "Reachability.h"

@implementation AccessJAppDelegate


@synthesize window=_window;
@synthesize navController;
@synthesize reachability;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self checkInternetReachability];
    
    // Override point for customization after application launch.
    [self.window addSubview:navController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    DLog(@"applicationWillResignActive called");

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"applicationDidEnterBackground called");
    [reachability stopNotifier];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    DLog(@"applicationWillEnterForeground called");
    
    [self checkInternetReachability];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DLog(@"applicationDidBecomeActive called");
}

- (void)applicationWillTerminate:(UIApplication *)application{
    DLog(@"applicationWillTerminate called");
    
    [reachability stopNotifier];
}

#pragma mark -
#pragma mark Reachability Support

-(void)checkInternetReachability {
    // Reachability initialization
    if (self.reachability == nil) {
        self.reachability = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:self.reachability];
    }
	
    if ([reachability currentReachabilityStatus] == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"connectivity is down, for proper operation this app requires an internet connection."
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
	[reachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)obj {
	Reachability *r = (Reachability *)[obj object];
 
    if ([r currentReachabilityStatus] == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"connectivity is down, for proper operation this app requires an internet connection."
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

- (void)dealloc
{
    [_window release];
    [navController release];
    [reachability release];
    [super dealloc];
}

@end
