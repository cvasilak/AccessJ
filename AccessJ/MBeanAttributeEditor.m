#import "MBeanAttributeEditor.h"
#import "ProgressViewController.h"
#import "MBean.h"
#import "Server.h"

#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation MBeanAttributeEditor
@synthesize mbean;
@synthesize attr;
@synthesize spinner;

-(void)dealloc {
    [mbean release];
    [attr release];
    [spinner release];
   
    DLog(@"MBeanAttributeEditor deAlloc");
    
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
    ProgressViewController *theSpinner = [[ProgressViewController alloc] initWithNibName:@"ProgressView"
                                                                                  bundle:nil 
                                                                           andParentView:self.navigationController.view];
    self.spinner = theSpinner;
    
    [theSpinner release];
    
	DLog(@"MBeanAttributeEditor viewDidLoad");
}


- (void)viewWillAppear:(BOOL)animated  {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                     target:self
                                     action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Save", 
                                                                   @"Save - for button to save changes")
                                   style:UIBarButtonItemStyleDone
                                   target:self 
                                   action:@selector(save)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    // TODO: Determine bool type
    self.navigationItem.rightBarButtonItem.enabled = [[[mbean.attr valueForKey:attr] valueForKey:@"rw"] boolValue];
    
    [saveButton release];
    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.mbean = nil;
	self.attr = nil;
	self.spinner = nil;

	DLog(@"MBeanAttributeEditor viewDidUnload");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(IBAction)updateWithValue:(id)value; {
    DLog(@"[[updating attribute \"%@\" for mbean \"%@\"]]", attr, mbean.objectname);
    
    [spinner startAnimating];
    
    NSDictionary *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:@"WRITE", @"type", 
                                 mbean.objectname, @"mbean", 
                                 attr, @"attribute", 
                                 value, @"value", 
                                 nil];
    
    
    NSURL *url = [NSURL URLWithString:mbean.server.hostport];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    
    DLog(@"%@", requestBody);
    
    [request appendPostData:[[requestBody JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

#pragma mark - Actions
-(IBAction)save {
    // subclasses should implement
   
}

-(IBAction)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Request / Response
- (void)requestFinished:(ASIHTTPRequest *)request {
    [spinner stopAnimating];
    
    [NSThread sleepForTimeInterval:1.0];
    
    NSDictionary *response = [[request responseString] JSONValue];

    DLog(@"%@", response);
    
    if ([[response valueForKey:@"status"] intValue] == 200) {  // success
        id value = [[response valueForKey:@"request"] valueForKey:@"value"];
        [[mbean.attr valueForKey:attr]setValue:value forKey:@"value"];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                        message:@""
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];

        [self.navigationController popViewControllerAnimated:YES];
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
