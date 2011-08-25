//
//  MBeanInfoRootController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@class MBean;
@class MBeanInfoAttributesController;
@class MBeanInfoOperationsController;
@class ProgressViewController;

@interface MBeanInfoRootController : UIViewController <UITabBarControllerDelegate, ASIHTTPRequestDelegate> {
    MBean *mbean;

    MBeanInfoAttributesController *attrController;
    MBeanInfoOperationsController *opController;

    NSUInteger curController;
	UITabBarController *tabBarController;

	ProgressViewController *spinner;    
}

@property (nonatomic, retain) MBean *mbean;
@property (nonatomic, retain) MBeanInfoAttributesController *attrController;
@property (nonatomic, retain) MBeanInfoOperationsController *opController;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) ProgressViewController *spinner;


- (IBAction)refresh:(id)sender;
- (void)makeRequest;

@end
