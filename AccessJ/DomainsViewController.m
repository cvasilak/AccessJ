//
//  DomainsViewController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 forthnet S.A. All rights reserved.
//

#import "DomainsViewController.h"
#import "GenericDataViewController.h"
#import "ProgressViewController.h"
#import "Server.h"
#import "MBean.h"

#import "ASIHTTPRequest.h"
#import "SBJson.h"


@implementation DomainsViewController

@synthesize server;
@synthesize domains;
@synthesize data;
@synthesize spinner;

- (void)dealloc {
    [server release];
    [domains release];
    [data release];
    [spinner release];
    
    DLog(@"DomainsViewController dealloc");
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    self.server = nil;
    self.domains = nil;
    self.data = nil;
    self.spinner = nil;
    
    DLog(@"DomainsViewController viewDidUnload");
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Domains";
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                   target:self 
                                                                                   action:@selector(makeRequest)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];

    ProgressViewController *theSpinner = [[ProgressViewController alloc] initWithNibName:@"ProgressView" 
                                                                                  bundle:nil 
                                                                           andParentView:self.navigationController.view];
    
    self.spinner = theSpinner;
    
    [theSpinner release];

    [self makeRequest];        

    DLog(@"DomainsViewController viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Request / Response
- (void)makeRequest {
    
    DLog(@"[[fetching list...]]");

    [spinner startAnimating];
    
    NSDictionary *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:@"LIST", @"type",
                                 @"/", @"path",
                                 nil];
    
    NSURL *url = [NSURL URLWithString:server.hostport];

    // clear any cached passwords
    // (see http://groups.google.com/group/asihttprequest/browse_thread/thread/5136714698727167/c0b40fc4c57dee16)
    [ASIHTTPRequest clearSession];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];

    [request appendPostData:[[requestBody JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [spinner stopAnimating];
    
    NSArray *keyPropertyList = [server.keyPropertyList componentsSeparatedByString:@","];
    
    // {domains}
    NSDictionary *dlist = [[[request responseString] JSONValue] objectForKey:@"value"];
    NSMutableDictionary *list = [[NSMutableDictionary alloc] init]; 
    
    // foreach domain in the list
    for (NSString *domainName in [dlist allKeys]) {
        // {mbeans under domain domainName}
        NSDictionary *mbeans = [dlist objectForKey:domainName];

        // sub dic
        // this will hold the "type="
        NSMutableDictionary *tree = [[NSMutableDictionary alloc] init];
        
        // foreach mbean in the domain
        for (NSString *objectName in [mbeans allKeys]) {
            NSArray *tokens = [objectName componentsSeparatedByString:@","];
        
            // determine mbean properties for this objectname
            NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
            for (NSString *token in tokens) {
                NSArray *keyval = [token componentsSeparatedByString:@"="];
                
                NSString *key = [keyval objectAtIndex:0];
                NSString *value = [keyval objectAtIndex:1];
                
                [properties setObject:value forKey:key];
            }
            
            // sort out properties according to "keyPropertyList"
            NSMutableArray *sortedPropertyNames = [[NSMutableArray alloc] init];
            for (NSString *property in keyPropertyList) {
                // trim any space characters just in case
                property = [property stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if ([properties objectForKey:property] != nil) {
                    [sortedPropertyNames addObject:property];
                }
            }
            for (NSString *property in properties) {
                if ([sortedPropertyNames containsObject:property])
                    continue;
                
                [sortedPropertyNames addObject:property];
            }
            /*
             <tree>  ->  <subtree> ...
             "Queue"  ->  "Core" -> "jms.queue.testQueue" -> "jms.queue.testQueue" -> NSNull
             "Queue"  ->  "Core" -> "jms.topic.testTopic" -> "jms.topic.testTopic" -> NSNull
             */
            
            NSMutableDictionary *node;
            
            NSMutableDictionary *subtree = tree;
            
            for (NSString *propertyName in sortedPropertyNames) {
                NSString *value = [properties objectForKey:propertyName];

                node = [subtree objectForKey:value];

                if (node == nil) {
                    node = [[[NSMutableDictionary alloc] init] autorelease];
                }
                
                [subtree setObject:node forKey:value];
                
                subtree = node;
            }
            
            MBean *mbean = [[MBean alloc] init];
            
            mbean.domain = domainName;
            mbean.server = server;
            mbean.attr = [[mbeans valueForKey:objectName] valueForKey:@"attr"];
            mbean.op = [[mbeans valueForKey:objectName] valueForKey:@"op"];
            mbean.objectname = [NSString stringWithFormat:@"%@:%@", domainName, objectName];
            
            [subtree setObject:mbean forKey:@"MBEAN_TAIL"];  // TODO: better name
 
            [mbean release];
            
            [properties release];
            [sortedPropertyNames release];
        }
        
        [list setObject:tree forKey:domainName];
        [tree release];
    }

    self.data = list;

    // sort the domain list
    self.domains = [[list allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    [list release];

	[self.tableView reloadData];
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

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.domains count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"DomainCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	
    UIImage *image = [UIImage imageNamed:@"domain.png"];
    cell.imageView.image = image;
    
    cell.textLabel.text = [self.domains objectAtIndex:row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    GenericDataViewController *gtvController = [[GenericDataViewController alloc] initWithStyle:UITableViewStylePlain];
    
    NSString *domain = [self.domains objectAtIndex:row];
    gtvController.data = [self.data valueForKey:domain];
    gtvController.title = domain;
    
    [self.navigationController pushViewController:gtvController animated:YES];
	[gtvController release];
}

@end
