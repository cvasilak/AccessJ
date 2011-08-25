//
//  MBeanOperationExecController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequestDelegate.h"

#define kLabelTag 4096
#define kNonEditableTextColor    [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:2.0]

@class MBean;
@class ProgressViewController;

@interface MBeanOperationExecController : UITableViewController<UITextFieldDelegate, ASIHTTPRequestDelegate> {
	MBean *mbean;
    
    NSString *opName;
    NSDictionary *op;
    NSArray *params;
    NSMutableArray *paramsValue;

    ProgressViewController *spinner;    
    UITextField *textFieldBeingEdited;
}

@property (nonatomic, retain) NSString *opName;
@property (nonatomic, retain) MBean *mbean;
@property (nonatomic, retain) NSDictionary *op;
@property (nonatomic, retain) NSArray *params;
@property (nonatomic, retain) NSMutableArray *paramsValue;
@property (nonatomic, retain) ProgressViewController *spinner;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;

- (void)setValue:(NSString *)value forRow:(NSNumber *)row;
- (NSString *)beautifyJavaType:(NSString *)type;
   
- (IBAction)execute;
- (IBAction)cancel;
- (IBAction)textFieldDone:(id)sender;

@end
