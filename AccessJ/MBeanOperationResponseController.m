//
//  MBeanOperationResponseController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "MBeanOperationResponseController.h"
#import "MBeanInfoRootController.h"
#import "MBeanValue.h"
#import "Server.h"
#import "MBean.h"

@implementation MBeanOperationResponseController

@synthesize data;
@synthesize sortedKeys;

- (void)dealloc {
    [data release];
    [sortedKeys release];

    DLog(@"MBeanOperationResponseController dealloc");
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    self.data = nil;
    self.sortedKeys = nil;
    DLog(@"MBeanOperationResponseController viewDidUnLoad");    
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([data isKindOfClass:[NSDictionary class]]) {
        self.sortedKeys = [[data allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
    } else if ([data isKindOfClass:[NSArray class]]) {
        if (data != nil && [data count] != 0) {
            // only sort if the array doesn't contain object elements
            // sortedArrayUsingSelector will fail if so 
            id <MBeanValue, NSObject> rawValue = [data objectAtIndex:0];
            if (![rawValue isKindOfClass:[NSDictionary class]] &&   // if the value is a dictionary or an array show the row number 
                ![rawValue isKindOfClass:[NSArray class]]) {
                
                self.data = [data sortedArrayUsingSelector:@selector(compare:)];
            }
        }
    }

    DLog(@"MBeanOperationResponseController viewDidLoad");    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([data isKindOfClass:[NSDictionary class]]) {
        return [sortedKeys count];
    } 
    
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"GenericCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	
    if ([self.data isKindOfClass:[NSDictionary class]]) {
        NSString *key = [sortedKeys objectAtIndex:row];
        
        cell.textLabel.text = key;

        id <MBeanValue, NSObject> rawValue = [[self data]valueForKey:key];
        
        if (![rawValue isKindOfClass:[NSDictionary class]] &&
            ![rawValue isKindOfClass:[NSArray class]]) {

            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = [rawValue cellDisplay];
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = @"";
        }
   
    } else if ([self.data isKindOfClass:[NSArray class]]) {
        if ([self.data count] > 0) {
            id <MBeanValue, NSObject> rawValue = [self.data objectAtIndex:row];

            if ([rawValue isKindOfClass:[NSDictionary class]] ||    // if the value is a dictionary or an array show the row number 
                [rawValue isKindOfClass:[NSArray class]]) {

                cell.textLabel.text = [[NSNumber numberWithUnsignedInteger:row] stringValue];
            } else {    // else show the primitive value
                cell.textLabel.text = [rawValue cellDisplay];
            }
        }
    } else {
        cell.textLabel.text = [[self.data objectAtIndex:row] cellDisplay];
    }
    
	return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    id rawValue;
    NSString *title;
    
    // we need to determine the type of the selected value
    // if its a dictionary or an array we allow the user
    // to proceed further down to the hierrachy
    
    if ([self.data isKindOfClass:[NSDictionary class]]) {
        NSString *key = [sortedKeys objectAtIndex:row];
        rawValue = [self.data valueForKey:key];
        title = key;
        
    } else if ([self.data isKindOfClass:[NSArray class]]) {
        rawValue = [self.data objectAtIndex:row];
        title = [[NSNumber numberWithUnsignedInt:row] stringValue];
    }
     
    if ([rawValue isKindOfClass:[NSDictionary class]] ||
        [rawValue isKindOfClass:[NSArray class]]) {
        MBeanOperationResponseController *responseController = [[MBeanOperationResponseController alloc] initWithStyle:UITableViewStylePlain];
        responseController.data = rawValue;
        responseController.title = title;
        
        [self.navigationController pushViewController:responseController animated:YES];
        [responseController release];   
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end