//
//  GenericDataViewController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 forthnet S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server;
@class ProgressViewController;

@interface GenericDataViewController : UITableViewController {
    id data;

    NSArray *sortedKeys;
    ProgressViewController *spinner;
}

@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSArray *sortedKeys;
@property (nonatomic, retain) ProgressViewController *spinner;

- (void)makeRequest;

@end
