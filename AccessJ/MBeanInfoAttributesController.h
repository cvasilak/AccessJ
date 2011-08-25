//
//  MBeanInfoAttributesController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@class MBean;
@class ProgressViewController;

@interface MBeanInfoAttributesController : UITableViewController <ASIHTTPRequestDelegate> {
    MBean *mbean;
    id data;
   
    NSArray *sortedKeys;
    NSString *currentDisplayedAttributeName;
    NSString *path;
    
    ProgressViewController *spinner;    
    UINavigationController *parentNavigationController;
}

@property (nonatomic, retain) MBean *mbean;
@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSArray *sortedKeys;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *currentDisplayedAttributeName;
@property (nonatomic, retain) ProgressViewController *spinner;
@property (nonatomic) BOOL isInRootAttributesScreen;
@property (nonatomic, retain) UINavigationController *parentNavigationController;

- (IBAction)refresh;
@end
