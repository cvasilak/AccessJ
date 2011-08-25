//
//  MBeanAttributePlotController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "MBeanAttributePlotController.h"
#import "MBean.h"
#import "Server.h"

#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation GraphPoint

- (id) initWithTimestamp:(NSNumber *)theTimestamp value:(NSNumber *)theValue {
    if(!(self=[super init])) return nil;
    
    timestamp = [theTimestamp retain];
    value = [theValue retain];
	
	return self;
}

- (NSNumber*) yValue{
	return value;
}

- (NSString*) xLabel{
    // convert timestamp to time 
    // TODO: convert to static 
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    
    NSString *label = [NSString stringWithFormat:@"%@",[timeFormat stringFromDate:date]];
    [timeFormat release];
    
    return  label;
}
- (NSString*) yLabel{
	return [value description];
}

@end

@implementation MBeanAttributePlotController

@synthesize mbean;
@synthesize currentDisplayedAttributeName;
@synthesize currentValue;
@synthesize path;
@synthesize dataForPlot;
@synthesize settingsController;
@synthesize parentNavigationController;
@synthesize updateTimer;

-(void)dealloc {
    [mbean release];
    [currentDisplayedAttributeName release];
    [path release];
	[dataForPlot release];
    [settingsController release];
    [parentNavigationController release];
    [updateTimer release];

    DLog(@"MBeanAttributePlotController dealloc");    
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    self.mbean = nil;
    self.currentDisplayedAttributeName = nil;
    self.currentValue = nil;
    self.path = nil;
    self.dataForPlot = nil;
    self.settingsController = nil;
    self.parentNavigationController = nil;
    self.updateTimer = nil;
    
    DLog(@"MBeanAttributePlotController viewDidUnLoad");    
    
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    DLog(@"scheduling Timer...");
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:secs target:self selector:@selector(makeRequest) userInfo:nil repeats:YES];
    
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    DLog(@"stopping update Timer...");
    [self.updateTimer invalidate];

    [super viewWillDisappear:animated];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // eager load the controller show the update interval
    // value remains during transitions
    GraphSettingsController *controller = [[GraphSettingsController alloc] initWithNibName:@"GraphSettingsView" bundle:nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    self.settingsController = controller;

    [controller release];
    
    UIButton * button = [[UIButton buttonWithType:UIButtonTypeInfoDark] retain];
	button.frame = CGRectMake(440, 8, 25.0, 25.0);
	button.backgroundColor = [UIColor clearColor];
	[button addTarget:self action:@selector(showGraphSettings:) forControlEvents:UIControlEventTouchUpInside];

 	[self.view addSubview:button];
    
	//UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	//self.navigationItem.rightBarButtonItem = infoButton;    
    //[infoButton release];

    [button release];

    // Setup graph
    self.dataForPlot = [[NSMutableArray alloc] init]; //by default empty
    
    // append the path in title fpr Composite/Tabular data
    if ([path isEqualToString:@""]) {
        graph.title.text = currentDisplayedAttributeName;
    } else {
        graph.title.text = [NSString stringWithFormat:@"%@ (%@)", currentDisplayedAttributeName, path];
    }
        
    graph.pointDistance = 15;
    graph.goalShown = NO;

    // default update interval is 2 seconds
    secs = 2;
    
    DLog(@"MBeanAttributePlotController viewDidLoad");    
}

#pragma mark - Request / Response
- (void)makeRequest {
    DLog(@"[[fetching graph updated value...]]");
    
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
    DLog(@"%@", [[request responseString] JSONValue]);
    
    //TODO Error Handling
    NSDictionary *response = [[request responseString] JSONValue];

    //NSNumber *x = [response valueForKey:@"timestamp"];
    NSNumber *x = [response valueForKey:@"timestamp"];
	NSNumber *y = [response valueForKey:@"value"];

    DLog(@"x=%@", [x description]);
    DLog(@"y=%@", [y description]);    

    GraphPoint *gp = [[GraphPoint alloc] initWithTimestamp:x value:y];
    [dataForPlot addObject:gp];	
    
    // we need to have at least one plot otherwise an error is thrown by the library
    // if we set the graph to an empty array.
    if ([dataForPlot count] == 1) {
        [self.graph setGraphWithDataPoints:dataForPlot];
    }    

    [graph reload];

    [self.graph showIndicatorForPoint:[dataForPlot count]-1];

    DLog(@"%d", [dataForPlot count]);
    
    // TODO: update mbean attr
    //[[mbean.attr valueForKey:currentDisplayedAttributeName] setObject:theattrs forKey:@"value"];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                    message:[error localizedDescription]
                                                   delegate:nil 
                                          cancelButtonTitle:@"Bummer"
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

#pragma mark - Actions
- (IBAction)showGraphSettings:(id)sender {
	[self presentModalViewController:settingsController animated:YES];
}

#pragma mark - CraphSettingsController Delegate
- (void)graphSettingsControllerDidFinish:(GraphSettingsController *)controller {
    secs = controller.updateIntervalSlider.value;
    
	[self dismissModalViewControllerAnimated:YES];
}

@end
 