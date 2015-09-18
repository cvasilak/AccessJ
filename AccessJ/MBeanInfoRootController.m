//
//  MBeanInfoRootController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "MBeanInfoRootController.h"
#import "MBeanInfoAttributesController.h"
#import "MBeanInfoOperationsController.h"
#import "ProgressViewController.h"
#import "Server.h"
#import "MBean.h"

#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation MBeanInfoRootController

@synthesize mbean;
@synthesize spinner;
@synthesize attrController;
@synthesize opController;
@synthesize tabBarController;

- (void)dealloc {
	[mbean release];
	[tabBarController release];
	[spinner release];
    
	DLog(@"MBeanInfoRootController deAlloc");
	
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
	self.mbean = nil;
	self.tabBarController = nil;
	self.spinner = nil;
	
	DLog(@"MBeanInfoRootController viewDidUnload");
    
    [super viewDidUnload];
}

- (void)loadView {
	[super viewDidLoad];
	
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
    
    // to avoid overlap of the tableview ontop of statusbar
    self.navigationController.navigationBar.translucent = NO;
    
    // Declare view controllers
	MBeanInfoAttributesController *aController = [[MBeanInfoAttributesController alloc] initWithStyle:UITableViewStylePlain];
	MBeanInfoOperationsController *oController = [[MBeanInfoOperationsController alloc] initWithStyle:UITableViewStylePlain];

    aController.mbean = mbean;
    oController.mbean = mbean;
    
    // Set a title for each view controller. These will also be names of each tab
    aController.title = @"Attributes";
    oController.title = @"Operations";

    aController.tabBarItem.image = [UIImage imageNamed:@"summary.png"];
	oController.tabBarItem.image = [UIImage imageNamed:@"operations.png"];
    
    aController.parentNavigationController = self.navigationController;
    oController.parentNavigationController = self.navigationController;
        
    // Create an empty tab controller and set it to fill the screen minus the top title bar
    UITabBarController *atabBarController = [[UITabBarController alloc] init];
	atabBarController.delegate = self;

    // TODO: revisit this
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||
       (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
      	atabBarController.view.frame = CGRectMake(0, 0, 320, IS_WIDESCREEN? 568: 480);
    } else if ((interfaceOrientation == UIInterfaceOrientationPortrait) || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        atabBarController.view.frame = CGRectMake(0, 0, 320, IS_WIDESCREEN? 550: 460);
    }
    
	// Set each tab to show an appropriate view controller
    [atabBarController setViewControllers: [NSArray arrayWithObjects:aController, oController, nil]];
    
	self.tabBarController = atabBarController;
    
    self.attrController = aController;
    self.opController = oController;
	
    // Clean up objects we don't need anymore
    [aController release];
    [oController release];
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																				   target:self
																				   action:@selector(refresh:)];
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
    
    // Finally, add the tab controller view to the parent view
    [self.view addSubview:tabBarController.view];
	
	DLog(@"MBeanInfoRootController viewDidLoad");
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    ProgressViewController *theSpinner = [[ProgressViewController alloc] initWithNibName:@"ProgressView" bundle:nil 
                                                                           andParentView:self.navigationController.view];
    
    self.spinner = theSpinner;
    
    [theSpinner release];
    
    [self makeRequest];
    
	DLog(@"MBeanInfoRootController viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated {
	[self.attrController refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Actions
- (IBAction)refresh:(id)sender {
    [self makeRequest];
}

#pragma mark - Request / Response
- (void)makeRequest {
    
    // TODO: determine either attributes or operations to refresh
    //       check tabbarcontroller to determine which tab is active
    
    DLog(@"[[fetching attributes...]]");
    
    [spinner startAnimating];
    
    NSDictionary *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:@"READ", @"type",
                                 mbean.objectname, @"mbean", 
                                 nil];
     
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
    
    NSDictionary *response = [[request responseString] JSONValue];
    
   if ([[response valueForKey:@"status"] intValue] == 200) {  // success

       NSDictionary *attrs = [response valueForKey:@"value"];
    
        for (NSString *attrName in [attrs allKeys]) {
            id value = [attrs valueForKey:attrName];
            
            NSMutableDictionary *attr = [mbean.attr valueForKey:attrName];
            [attr setObject:value forKey:@"value"];
        }

        attrController.data = mbean.attr;
        
        attrController.isInRootAttributesScreen = YES;
        attrController.currentDisplayedAttributeName = @""; // root attributes
        attrController.path = @"";  // root path
        
        [attrController refresh];
   } else { // an error occured inform user
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                       message:[response valueForKey:@"error"]
                                                      delegate:nil 
                                             cancelButtonTitle:@"Bummer"
                                             otherButtonTitles:nil];
       
       [alert show];
       [alert release];
   }
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

@end
