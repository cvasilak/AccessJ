//
//  MBeanOperationExecController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "MBeanOperationExecController.h"
#import "MBeanOperationResponseController.h"
#import "ProgressViewController.h"
#import "MBean.h"
#import "MBeanValue.h"
#import "Server.h"

#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation MBeanOperationExecController

@synthesize mbean;
@synthesize opName;
@synthesize op;
@synthesize params;
@synthesize paramsValue;
@synthesize textFieldBeingEdited;
@synthesize spinner;

- (void)dealloc {
	[mbean release];
    [opName release];
    [op release];
	[params release];
    [paramsValue release];
    [textFieldBeingEdited release];
    [spinner release];
    
	DLog(@"MBeanOperationExecController deAlloc");
	
	[super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    self.mbean = nil;
    self.opName = nil;
    self.op = nil;
    self.params = nil;
    self.paramsValue = nil;
    self.spinner = nil;
    self.textFieldBeingEdited = nil;
    
    DLog(@"MBeanOperationExecController viewDidUnLoad");
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.params = [op valueForKey:@"args"];
    
    // initialize params value to NSNull
    self.paramsValue = [[NSMutableArray alloc] initWithCapacity:[self.params count]];
    for (int i = 0; i < [self.params count]; i++) {
        [self.paramsValue addObject:[NSNull null]];
    }
    
    ProgressViewController *theSpinner = [[ProgressViewController alloc] initWithNibName:@"ProgressView"
                                                                                  bundle:nil 
                                                                           andParentView:self.navigationController.view];
    self.spinner = theSpinner;
    
    [theSpinner release];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:NSLocalizedString(@"Back", 
                                                                     @"Back - for button to cancel changes")
                                     style:UIBarButtonSystemItemCancel
                                     target:self
                                     action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];

    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Execute", 
                                                                   @"Execute - for button to execute operation")
                                   style:UIBarButtonItemStyleDone
                                   target:self 
                                   action:@selector(execute)];
    
    self.navigationItem.rightBarButtonItem = saveButton;

    DLog(@"MBeanOperationExecController viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Actions
- (IBAction)textFieldDone:(id)sender {
    UITableViewCell *cell =	(UITableViewCell *)[[sender superview] superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];
    NSUInteger row = [textFieldIndexPath row];

    row++;
    if (row >= [params count]) {
        row = 0;
    }
    
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:newPath];
    UITextField *nextField = nil;
    for (UIView *oneView in nextCell.contentView.subviews) {
        if ([oneView isMemberOfClass:[UITextField class]])
            nextField = (UITextField *)oneView;
    }
    [nextField becomeFirstResponder];
}

- (void)execute {
    if (textFieldBeingEdited != nil) {
        NSNumber *tagAsNum= [[NSNumber alloc]
                             initWithInt:textFieldBeingEdited.tag];
        [self setValue:textFieldBeingEdited.text forRow:tagAsNum];
        [tagAsNum release];
        
        [textFieldBeingEdited resignFirstResponder];
    }
    
    // check if no parameters are specified (aka the existence of NSNull values)
    for (id obj in paramsValue) {
        if (obj == [NSNull null]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Not enough arguments specified!"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Bummer"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];
            
            return;
        }
    }
    
    DLog(@"[[executing operation %@]]", opName);
    
    [spinner startAnimating];
    
    NSMutableDictionary *requestBody = [NSMutableDictionary dictionary];
    
    [requestBody setObject:@"EXEC" forKey:@"type"];
    [requestBody setObject:mbean.objectname forKey:@"mbean"];
    
    NSRange rangeToIndex = [opName rangeOfString:@"[" options:NSCaseInsensitiveSearch];
    
    NSMutableString *signature = [NSMutableString string];
    
    if (rangeToIndex.location == NSNotFound) {
        [signature appendString:opName];
    } else {
        [signature appendString:[opName substringToIndex:rangeToIndex.location-1]];
    }
    
    // handle overloaded methods
    // the signature is a fully qualified argument
    // class names or native types, separated by
    // columns and enclosed with parentheses. 
    if ([params count] > 0) {
        [signature appendString:@"("];
        for (int i = 0; i < [params count]; i++) {
            NSDictionary *param = [params objectAtIndex:i];
            [signature appendString:[param valueForKey:@"type"]];

            if (i < [params count]-1)
                [signature appendString:@","];
            
        }
        
        [signature appendString:@")"];
    }
    
    [requestBody setObject:signature forKey:@"operation"];
    [requestBody setObject:paramsValue forKey:@"arguments"];

    DLog(@"%@", requestBody);
    
    NSURL *url = [NSURL URLWithString:mbean.server.hostport];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    
    [request appendPostData:[[requestBody JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (IBAction)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Request / Response
- (void)requestFinished:(ASIHTTPRequest *)request {
    [spinner stopAnimating];
    
    NSDictionary *response = [[request responseString] JSONValue];
    
    DLog(@"%@", response);
    
    if ([[response valueForKey:@"status"] intValue] == 200) { //success
        id <MBeanValue, NSObject> value = [response objectForKey:@"value"];

        // for "composite / tabular / array" response
        if ([value isKindOfClass:[NSDictionary class]] ||
            [value isKindOfClass:[NSArray class]]) { 
            MBeanOperationResponseController *responseController = [[MBeanOperationResponseController alloc] initWithStyle:UITableViewStylePlain];
            responseController.data = value;
            responseController.title = @"Response";
            
            [self.navigationController pushViewController:responseController animated:YES];

            
        } else { //  else handle primitive response
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:[value cellDisplay]
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];
        }
    } else { //an error has occured
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error (%@)", [response valueForKey:@"status"]]
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self beautifyJavaType:[op valueForKey:@"ret"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [params count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OperationParamCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 25)];
   		label.tag = kLabelTag;
        label.textAlignment = UITextAlignmentRight;

        UIFont *font = [UIFont boldSystemFontOfSize:14.0];
        label.textColor = kNonEditableTextColor;
        label.font = font;
        [cell.contentView addSubview:label];
        [label release];
		
        UITextField *textField = [[UITextField alloc] 
                                     initWithFrame:CGRectMake(120, 10, 190, 25)];
        
        textField.clearsOnBeginEditing = NO;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.returnKeyType = UIReturnKeyDone;
        [textField setDelegate:self];
        [textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];

        [cell.contentView addSubview:textField];

        [textField release];
    }

    NSUInteger row = [indexPath row];
    UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
    UITextField *textField = nil;
    
    for (UIView *oneView in cell.contentView.subviews) {
        if ([oneView isMemberOfClass:[UITextField class]]) 
            textField = (UITextField *)oneView;
    }
    
    NSDictionary *arg = [params objectAtIndex:row];
    label.text = [arg valueForKey:@"name"];
    textField.placeholder = [self beautifyJavaType:[arg valueForKey:@"type"]];
    
    if ([[arg valueForKey:@"type"] isEqualToString:@"long"] ||
        [[arg valueForKey:@"type"] isEqualToString:@"int"]) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    } else if ([[arg valueForKey:@"type"] isEqualToString:@"boolean"]) {
        textField.keyboardType = UIKeyboardTypeDefault;
        // default to true value
        textField.text = @"true";
        
        [paramsValue replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:YES]];
        
    } else {
        textField.keyboardType = UIKeyboardTypeDefault;
    }
    
    textField.tag = row;
    
    return cell;
}

#pragma mark - Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *value = textField.text;
    NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];

    [self setValue:value forRow:tagAsNum];
    [tagAsNum release];
}

#pragma mark - Utility Methods
- (void)setValue:(NSString *)value forRow:(NSNumber *)row {

    if (![value isEqualToString:@""]) { // if not empty string
        NSDictionary *arg = [params objectAtIndex:[row intValue]];
        
        id convValue;
        
        if ([[arg valueForKey:@"type"] isEqualToString:@"long"] ||
            [[arg valueForKey:@"type"] isEqualToString:@"int"]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            convValue = [f numberFromString:value];
            [f release];
        } else if ([[arg valueForKey:@"type"] isEqualToString:@"boolean"]) {
            BOOL boolValue = ([value isEqualToString:@"true"]? YES:NO);
            convValue = [NSNumber numberWithBool:boolValue];
        }
        
        [paramsValue replaceObjectAtIndex:[row intValue] withObject:convValue];

    } else { // clean any garbage 
        [paramsValue replaceObjectAtIndex:[row intValue] withObject:[NSNull null]];
    }
}

- (NSString *)beautifyJavaType:(NSString *)type {
    if ([type isEqualToString:@"[J"]) {
        return @"long[]";
    } else if ([type isEqualToString:@"java.lang.String"]) {
        return @"String";
    } else if ([type isEqualToString:@"[Ljava.lang.String;"]) {
        return @"String[]";
    } else if ([type isEqualToString:@"javax.management.openmbean.CompositeData"]) {
        return @"CompositeData";
    } else if ([type isEqualToString:@"[Ljavax.management.openmbean.CompositeData;"]) {
        return @"CompositeData[]";
    } else if ([type isEqualToString:@"javax.management.openmbean.TabularData"]) {
        return @"TabularData";
    } else if ([type isEqualToString:@"[Ljavax.management.openmbean.TabularData;"]) {
        return @"TabularData[]";
    } else {
        return type;
    }
}

@end
