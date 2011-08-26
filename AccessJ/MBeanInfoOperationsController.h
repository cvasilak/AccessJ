//
//  MBeanInfoOperationsController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBean;

@interface MBeanInfoOperationsController : UITableViewController {
	MBean *mbean;
    
    NSMutableDictionary *ops;
    NSArray *sortedKeys;

    UINavigationController *parentNavigationController;
}

@property (nonatomic, retain) MBean *mbean;
@property (nonatomic, retain) NSMutableDictionary *ops;
@property (nonatomic, retain) NSArray *sortedKeys;
@property (nonatomic, retain) UINavigationController *parentNavigationController;

- (IBAction)refresh;

- (NSString *)beautifyJavaType:(NSString *)type;
- (BOOL)canEditType:(NSString *)type;
@end
