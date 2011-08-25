//
//  DomainsViewController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 forthnet S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@class Server;
@class ProgressViewController;

@interface DomainsViewController : UITableViewController<ASIHTTPRequestDelegate> {
    Server *server;
    NSArray *domains;
    NSDictionary *data;
    
	ProgressViewController *spinner;    
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) NSArray *domains;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) ProgressViewController *spinner;

- (void)makeRequest;

@end
