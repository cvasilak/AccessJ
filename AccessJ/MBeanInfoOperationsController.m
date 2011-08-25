//
//  MBeanInfoOperationsController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "MBeanInfoOperationsController.h"
#import "MBeanOperationExecController.h"
#import "MBean.h"

@implementation MBeanInfoOperationsController

@synthesize mbean;
@synthesize ops;
@synthesize sortedKeys;
@synthesize parentNavigationController;

- (void)dealloc {
	[mbean release];
    [ops release];
    [sortedKeys release];
    
    [parentNavigationController release];
	
	DLog(@"MBeanInfoOperationsController deAlloc");
	
	[super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
	self.mbean = nil;
    self.ops = nil;
    self.sortedKeys = nil;
    self.parentNavigationController = nil;
    
    DLog(@"MBeanInfoOperationsController viewDidUnload");
    
  	[super viewDidUnload];
}

- (void)viewDidLoad {	
	[super viewDidLoad];
	
    self.ops = [NSMutableDictionary dictionary];

    NSEnumerator *keyEnum = [self.mbean.op keyEnumerator];

    NSString *key;
    while ((key = [keyEnum nextObject]) != nil) {
        id obj = [self.mbean.op valueForKey:key];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self.ops setValue:obj forKey:key];
        } else if ([obj isKindOfClass:[NSArray class]]) {  // handle similar method names but with different parameters
            
            for (int i = 0; i < [obj count]; i++) {
                [self.ops setValue:[[self.mbean.op valueForKey:key] objectAtIndex:i] forKey:[NSString stringWithFormat: @"%@ [%d]", key, i+1]];
            }
        }       
    }
    
    self.sortedKeys = [[self.ops allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
	DLog(@"MBeanInfoOperationsController viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Actions
- (IBAction)refresh {
   	[self.tableView reloadData];
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [sortedKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"OperationCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	
	NSString *opName = [sortedKeys objectAtIndex:row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ()", opName];
        
    NSDictionary *op = [ops valueForKey:opName];
    
    NSArray *params = [op valueForKey:@"args"];

    NSMutableString *descr = [NSMutableString string];
    
    BOOL canEdit = YES;
    
    if ([params count] != 0) {
        [descr appendString:@"( "];
        
        for (int i = 0; i < [params count]; i++) {
            NSDictionary *arg = [params objectAtIndex:i];
            
            NSString *type = [arg valueForKey:@"type"];
            if ([type isEqualToString:@"java.lang.String"]) {
                [descr appendString:@"String"];
            } else if ([type isEqualToString:@"[J"]) {
                [descr appendString:@"[]"];
                canEdit = NO; // no support for editing of arrays (yet)
            } else {
                [descr appendString:type];
            }
            
            if (i < [params count]-1)
                [descr appendString:@", "];
        }
        
        [descr appendString:@" )"];
    }
    
    if (canEdit) {
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.detailTextLabel.text = descr;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];

    NSString *opName = [sortedKeys objectAtIndex:row];
    NSDictionary *op = [ops valueForKey:opName];
    
    NSArray *params = [op valueForKey:@"args"];
    
    // if args has an array parameter we don't support it (yet)
    for (NSDictionary *param in params) {
        if ([[param valueForKey:@"type"] isEqualToString:@"[J"]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
    }
    
    MBeanOperationExecController *opExecController = [[MBeanOperationExecController alloc] initWithStyle:UITableViewStyleGrouped];
    opExecController.mbean = mbean;
    opExecController.op = op;
    opExecController.opName = opName;
    opExecController.title = opName;
    
    [self.parentNavigationController pushViewController:opExecController animated:YES];

    [opExecController release];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end