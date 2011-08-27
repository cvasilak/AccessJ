//
//  MBeanInfoAttributesController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "MBeanInfoAttributesController.h"
#import "MBeanValue.h"
#import "MBeanAttributeEditor.h"
#import "MBeanAttributePlotController.h"
#import "MBean.h"
#import "Server.h"
#import "ProgressViewController.h"

#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation MBeanInfoAttributesController

@synthesize mbean;
@synthesize data;
@synthesize sortedKeys;
@synthesize path;
@synthesize isInRootAttributesScreen;
@synthesize currentDisplayedAttributeName;
@synthesize spinner;
@synthesize parentNavigationController;

- (void)dealloc {
	[mbean release];
    [data release];
    [sortedKeys release];
    [currentDisplayedAttributeName release];
    [spinner release];
    [parentNavigationController release];
	
	DLog(@"MBeanInfoAttributesController deAlloc");
	
	[super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
	self.mbean = nil;
    self.data = nil;
    self.sortedKeys = nil;
    self.currentDisplayedAttributeName = nil;
    self.spinner = nil;
    self.parentNavigationController = nil;
    
  	DLog(@"MBeanInfoAttributesController viewDidUnload");
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(makeRequest)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
    
    ProgressViewController *theSpinner = [[ProgressViewController alloc] initWithNibName:@"ProgressView" 
                                                                                  bundle:nil 
                                                                           andParentView:self.parentNavigationController.view];
    
    self.spinner = theSpinner;
    
    [theSpinner release];
    
	DLog(@"MBeanInfoAttributesController viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Actions
- (IBAction)refresh {
    // do the sorting upon refreshing of the data
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

   	[self.tableView reloadData];
}

#pragma mark - Request / Response
- (void)makeRequest {
    DLog(@"[[fetching attributes...]]");
    
    [spinner startAnimating];
    
    NSMutableDictionary *requestBody = [NSMutableDictionary dictionary];
    
    [requestBody setObject:@"READ" forKey:@"type"];
    [requestBody setObject:mbean.objectname forKey:@"mbean"];
    [requestBody setObject:currentDisplayedAttributeName forKey:@"attribute"];
    
    if (![path isEqualToString:@""]) 
        [requestBody setObject:path forKey:@"path"];
    
    DLog(@"%@", requestBody);
    
    NSURL *url = [NSURL URLWithString:mbean.server.hostport];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    
    [request appendPostData:[[requestBody JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [spinner stopAnimating];
    
    DLog(@"%@", [[request responseString] JSONValue]);
    
    //TODO Error Handling
    NSDictionary *thedata = [[[request responseString] JSONValue] valueForKey:@"value"];
    
    // update mbean attr
    // TODO: Composite Data update with path
    [[mbean.attr valueForKey:currentDisplayedAttributeName] setObject:thedata forKey:@"value"];
    
    // update current display attribute
    self.data = thedata;
    
    [self refresh];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [spinner stopAnimating];
    
    NSError *error = [request error];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                    message:[error localizedDescription]
                                                   delegate:nil 
                                          cancelButtonTitle:@"Bummer"
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([data isKindOfClass:[NSDictionary class]]) {
        return [sortedKeys count];
    } else if ([data isKindOfClass:[NSArray class]]) {
        return [data count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"AttributeCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
    NSUInteger row = [indexPath row];
    
    id <MBeanValue, NSObject> rawValue = nil;
    
    if (isInRootAttributesScreen) {
        NSDictionary *attr;
        NSString  *attrName;
        
        attrName = [sortedKeys objectAtIndex:row];
        attr = [data valueForKey:attrName];
        
        // set the cell text with attribute name
        cell.textLabel.text = attrName;
        
        // set the cell details text with attribute value
        rawValue = [attr valueForKey:@"value"];
        cell.detailTextLabel.text = [rawValue cellDisplay];
        
        // determine if its an editable attribute
        BOOL canEdit = [[attr valueForKey:@"rw"] boolValue];
        if (canEdit) {
            cell.textLabel.textColor = [UIColor blueColor];
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
        }

    } else {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSString *key = [sortedKeys objectAtIndex:row];

            // set the cell text with attribute name
            cell.textLabel.text = key;
            
            // set the cell details text with attribute value
            rawValue = [data valueForKey:key];

            // for NSArray and NSDictionary [cellDisplay] returns an empty string
            cell.detailTextLabel.text = [rawValue cellDisplay];
        } else if ([data isKindOfClass:[NSArray class]]) {
            rawValue = [self.data objectAtIndex:row];
            
            if ([rawValue isKindOfClass:[NSDictionary class]] ||    // if the value is a dictionary or an array show the row number 
                [rawValue isKindOfClass:[NSArray class]]) {
                
                cell.textLabel.text = [[NSNumber numberWithUnsignedInteger:row] stringValue];
            } else {    // else show the primitive value
                cell.textLabel.text = [rawValue cellDisplay];
            }
        }
        
         cell.textLabel.textColor = [UIColor blackColor];
    }

    // for array / composite / tabular values show the disclosure indicator
    // to inform the user that there is more down the rabbit hole...
    if ([rawValue isKindOfClass:[NSDictionary class]] ||
        [rawValue isKindOfClass:[NSArray class]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSUInteger row = [indexPath row];

    id <MBeanValue, NSObject> rawValue = nil;
    NSString *title;
    
    //TODO: Refactor me
    BOOL canEdit = NO;
    
    if (isInRootAttributesScreen) {
        NSString  *attrName = [sortedKeys objectAtIndex:row];
        NSDictionary *attr = [data valueForKey:attrName];
        
        rawValue = [attr valueForKey:@"value"];
        
        title = attrName;

        if (rawValue == nil) {  // eg. Memory Pool/ Par Eden Space/ UsageThreshold ("Unavailable" on VisualVM)
            canEdit = NO;
        } else {
            canEdit = [[attr valueForKey:@"rw"] boolValue];
        }

    } else {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSString *key = [sortedKeys objectAtIndex:row];

            title = key;
            rawValue = [data valueForKey:key];
         
        } else if ([data isKindOfClass:[NSArray class]]) {
            rawValue = [data objectAtIndex:row];
            
            if ([rawValue isKindOfClass:[NSDictionary class]] ||    // if the value is a dictionary or an array the title is the row number
                [rawValue isKindOfClass:[NSArray class]]) {
                
                title = [[NSNumber numberWithUnsignedInteger:row] stringValue];
            } else {    // else show the primitive value
                title = [rawValue cellDisplay];
            }
        } 
    }
    
    if ([rawValue isKindOfClass:[NSDictionary class]] ||
        [rawValue isKindOfClass:[NSArray class]]) {   // check if value is Composite Data or TabularData
        
        if ([rawValue count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"List is empty!"
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }

        MBeanInfoAttributesController *gtvController = [[MBeanInfoAttributesController alloc] initWithStyle:UITableViewStylePlain];
        
        gtvController.mbean = mbean;
        gtvController.data = rawValue;
        
        if ([currentDisplayedAttributeName isEqualToString:@""]) {
            gtvController.currentDisplayedAttributeName = title;
            gtvController.path = @"";
            
        } else {
            gtvController.currentDisplayedAttributeName = [self currentDisplayedAttributeName];
            
            if ([path isEqualToString:@""])
                gtvController.path = title;
            else
                gtvController.path = [NSString stringWithFormat:@"%@/%@", path, title];
        }
        
        gtvController.title = title;
        gtvController.parentNavigationController = [self parentNavigationController];
        [gtvController refresh];
        
        [self.parentNavigationController pushViewController:gtvController animated:YES];
    
        [gtvController release];

    } else {   // nope so "primitive value"
        
        if (isInRootAttributesScreen && canEdit) {
            NSString *controllerClassName = [rawValue controllerClassName];
            
            Class controllerClass = NSClassFromString(controllerClassName);
            MBeanAttributeEditor *controller = [controllerClass alloc];
            controller = [controller initWithStyle:UITableViewStyleGrouped];
            controller.mbean = mbean;
            controller.attr = title;
            controller.title = title;
            
            [self.parentNavigationController pushViewController:controller animated:YES];
            
            [controller release];
        } else {
            if ([rawValue canBePlotted]) {
                MBeanAttributePlotController *plotController = [[MBeanAttributePlotController alloc] init];
                
                plotController.mbean = mbean;
                plotController.currentValue = rawValue;
                
                if ([currentDisplayedAttributeName isEqualToString:@""]) {
                    plotController.currentDisplayedAttributeName = title;
                    plotController.path = @"";
                    
                } else {
                    plotController.currentDisplayedAttributeName = [self currentDisplayedAttributeName];
                    
                    if ([path isEqualToString:@""])
                        plotController.path = title;
                    else
                        plotController.path = [NSString stringWithFormat:@"%@/%@", path, title];
                }
                
                plotController.parentNavigationController = [self parentNavigationController];
                
                [parentNavigationController presentModalViewController:plotController animated:YES];
                
                [plotController release];
            }
        }
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end