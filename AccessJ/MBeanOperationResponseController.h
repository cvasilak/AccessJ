//
//  MBeanOperationResponseController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBeanOperationResponseController : UITableViewController {
   id data;
    
   NSArray *sortedKeys;
}

@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSArray *sortedKeys;
@end
