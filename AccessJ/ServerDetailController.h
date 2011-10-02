//
//  ServerDetailController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNumberOfEditableRows	8

#define kServerNameRowIndex             0
#define kServerHostnameRowIndex         1
#define kServerPortRowIndex             2
#define kServerContextPathRowIndex      3
#define kServerKeyPropertyListRowIndex  4
#define kServerUseSSLRowIndex           5
#define kServerUsernameRowIndex         6
#define kServerPasswordRowIndex         7

#define kNonEditableTextColor  [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0]

#define kLabelTag 4096

@class Server;

@interface ServerDetailController : UITableViewController <UITextFieldDelegate> {
    Server *server;
    
	NSArray *fieldLabels;
	NSMutableDictionary *tempValues;
	UITextField *textFieldBeingEdited;
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (void)textFieldDone:(id)sender;
- (void)switchValueChanged:(id)sender;
@end
