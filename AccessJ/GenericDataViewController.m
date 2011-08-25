//
//  GenericDataViewController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 forthnet S.A. All rights reserved.
//

#import "GenericDataViewController.h"
#import "MBeanInfoRootController.h"
#import "ProgressViewController.h"
#import "Server.h"
#import "MBean.h"

#import "ASIHTTPRequest.h"
#import "SBJson.h"


@implementation GenericDataViewController

@synthesize data;
@synthesize sortedKeys;
@synthesize spinner;

- (void)dealloc {
    [data release];
    [sortedKeys release];
    [spinner release];
    
    DLog(@"GenericTableViewController dealloc");
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    self.data = nil;
    self.sortedKeys = nil;
    self.spinner = nil;
    
    DLog(@"GenericTableViewController viewDidUnLoad");    
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
   // self.navigationItem.rightBarButtonItem = self.editButton
    /*
    ProgressViewController *theSpinner = [[ProgressViewController alloc] initWithNibName:@"ProgressView" 
                                                                                  bundle:nil 
                                                                           andParentView:self.navigationController.view];

    self.spinner = theSpinner;
    
    [theSpinner release];
    */
    self.sortedKeys = [[data allKeys] sortedArrayUsingSelector:@selector(compare:)];
    //TODO this results in EXEC_BAD_ACCESS  resolve why
    //[theSpinner release];
    
    DLog(@"GenericTableViewController viewDidLoad");    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Request / Response
- (void)makeRequest {
    /*
    [spinner stopAnimating];    
     
    NSDictionary *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:@"LIST", @"type", self.title, @"path", nil];
    
    NSURL *url = [NSURL URLWithString:server.hostport];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request appendPostData:[[requestBody JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setDelegate:self];
    [request startAsynchronous];
     */
}

- (void)requestFinished:(ASIHTTPRequest *)request {

    /*
    [spinner stopAnimating];
     
    self.response = [[request responseString] JSONValue];
    self.domain = [self.response objectForKey:@"value"];
    self.mbeans = [[self.response objectForKey:@"value"] allKeys];
    
     
    
	[self.tableView reloadData];
    */
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    /*
     
    [spinner stopAnimating];
         [spinner stopAnimating];
    NSError *error = [request error];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                    message:[error localizedDescription]
                                                   delegate:nil 
                                          cancelButtonTitle:@"Bummer"
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
     
    */
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sortedKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"GenericCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	
    NSString *key = [sortedKeys objectAtIndex:row];
    
    NSMutableDictionary *subdata = [self.data valueForKey:key];
    
    if ( ([subdata isKindOfClass:[MBean class]]) ||
        ([subdata objectForKey:@"MBEAN_TAIL"] != nil && [subdata count] == 1) 
        ) {
        
        UIImage *image = [UIImage imageNamed:@"mbean.png"];
        cell.imageView.image = image;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        UIImage *image = [UIImage imageNamed:@"folder.png"];
        cell.imageView.image = image;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([key isEqualToString:@"MBEAN_TAIL"])
        cell.textLabel.text = @"@this";        
    else
        cell.textLabel.text = key;

	return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    NSString *key = [sortedKeys objectAtIndex:row];

    id subdata = [self.data valueForKey:key];
    
    if ( ([subdata isKindOfClass:[MBean class]]) ||
         ([subdata objectForKey:@"MBEAN_TAIL"] != nil && [subdata count] == 1) 
       ) {  // we reached the end of the list

        MBean *mbean;
        
        if ([subdata isKindOfClass:[MBean class]])
            mbean = subdata;
         else 
            mbean = [subdata objectForKey:@"MBEAN_TAIL"];
        
        MBeanInfoRootController *rootController = [[MBeanInfoRootController alloc] init];
        
        rootController.mbean = mbean;
        
        if ([key isEqualToString:@"MBEAN_TAIL"])
           rootController.title = [self title];
        else 
           rootController.title = key;

        [self.navigationController pushViewController:rootController animated:YES];
        [rootController release];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        GenericDataViewController *gtvController = [[GenericDataViewController alloc] initWithStyle:UITableViewStylePlain];
        gtvController.data = subdata;
        gtvController.title = key;
        
        [self.navigationController pushViewController:gtvController animated:YES];
        [gtvController release];
    }
}
@end
