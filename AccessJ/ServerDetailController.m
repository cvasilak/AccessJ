//
//  ServerDetailController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "ServerDetailController.h"
#import "ServersViewController.h"
#import "Server.h"
#import "ServersManager.h"


@implementation ServerDetailController

@synthesize server;
@synthesize fieldLabels;
@synthesize tempValues;
@synthesize textFieldBeingEdited;

- (void)dealloc {
    [server release];
	[fieldLabels release];
	[tempValues release];
	[textFieldBeingEdited release];
	
	DLog(@"ServerDetailController deAlloc");
    
	[super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    self.server = nil;
	self.fieldLabels = nil;
	self.tempValues = nil;
	self.textFieldBeingEdited = nil;
    
	DLog(@"ServerDetailController viewDidUnload");
    
 	[super viewDidUnload];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSArray *array = [[NSArray alloc] initWithObjects:@"Name", @"Hostname", @"Port", @"Context Path", @"keyPropertyList", @"Use SSL", @"Username", @"Password", nil];
	self.fieldLabels = array;
	
	[array release];
    
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (server == nil) { // new server
        [dict setObject:@"/jolokia" forKey:[NSNumber numberWithInt:kServerContextPathRowIndex]];
        [dict setObject:@"type" forKey:[NSNumber numberWithInt:kServerKeyPropertyListRowIndex]];
        
    }
    
	self.tempValues = dict;
	[dict release];
	
	DLog(@"ServerDetailController viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return kNumberOfEditableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellEditIdentifier = @"ServerCellEditIdentifer";
  	static NSString *CellEditSwitchIdentifier = @"ServerCellEditSwitchIdentifer";
    
	NSUInteger row = [indexPath row];
	
    UITableViewCell *cell;
    
    if (row == kServerUseSSLRowIndex) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellEditSwitchIdentifier];        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellEditIdentifier];        
    }
	
	if (cell == nil) {
        if (row == kServerUseSSLRowIndex /* || anotherUISwitchRowIndex*/) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellEditSwitchIdentifier] autorelease];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 110, 25)];
            label.tag = kLabelTag;
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont boldSystemFontOfSize:12.0];
            label.textColor = kNonEditableTextColor;
            label.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:label];
            [label release];
            
            UISwitch *toggler = [[UISwitch alloc] initWithFrame:CGRectMake(130, 10, 0, 0)];
            [toggler addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:toggler];
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellEditIdentifier] autorelease];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 110, 25)];
            label.tag = kLabelTag;
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont boldSystemFontOfSize:12.0];
            label.textColor = kNonEditableTextColor;
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label];
            [label release];
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, 168, 25)];
            textField.clearsOnBeginEditing = NO;
            [textField setDelegate:self];
            if (row == kServerPasswordRowIndex)
                [textField setSecureTextEntry:YES];
            else
                [textField setSecureTextEntry:NO];
            
            if (row == kServerPortRowIndex)
                [textField setKeyboardType:UIKeyboardTypeDecimalPad];
            else 
                [textField setKeyboardType:UIKeyboardTypeDefault];
            
            textField.returnKeyType = UIReturnKeyDone;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
            [cell.contentView addSubview:textField];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	UILabel *label = (UILabel *) [cell viewWithTag:kLabelTag];
	UITextField *textField = nil;
    UISwitch *toggler = nil;
    
    for (UIView *oneView in cell.contentView.subviews) {
		if ([oneView isMemberOfClass:[UITextField class]])
			textField = (UITextField *) oneView;
        else if ([oneView isMemberOfClass:[UISwitch class]]) {
            toggler = (UISwitch *) oneView;
        }
	}
	
	label.text = [fieldLabels objectAtIndex:row];
	NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
	
	switch (row) {
		case kServerNameRowIndex:
			if ([[tempValues allKeys] containsObject:rowAsNum])
				textField.text = [tempValues objectForKey:rowAsNum];
			else
				textField.text = server.name;
			
			break;
		case kServerHostnameRowIndex:
			if ([[tempValues allKeys] containsObject:rowAsNum])
				textField.text = [tempValues objectForKey:rowAsNum];
			else
				textField.text = server.hostname;
			
			break;
		case kServerPortRowIndex:
			if ([[tempValues allKeys] containsObject:rowAsNum])
				textField.text = [tempValues objectForKey:rowAsNum];
			else
				textField.text = server.port;
			
			break;
        case kServerContextPathRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
				textField.text = [tempValues objectForKey:rowAsNum];
			else
				textField.text = server.contextPath;
			
			break;
		case kServerKeyPropertyListRowIndex:
			if ([[tempValues allKeys] containsObject:rowAsNum])
				textField.text = [tempValues objectForKey:rowAsNum];
			else
				textField.text = server.keyPropertyList;
			
			break;
		case kServerUseSSLRowIndex:
			if ([[tempValues allKeys] containsObject:rowAsNum])
				toggler.on = [[tempValues objectForKey:rowAsNum] boolValue];
			else
				toggler.on = server.isSSLSecured;
			
			break;
		case kServerUsernameRowIndex:
			if ([[tempValues allKeys] containsObject:rowAsNum])
				textField.text = [tempValues objectForKey:rowAsNum];
			else
				textField.text = server.username;
			
			break;
		case kServerPasswordRowIndex:
			if ([[tempValues allKeys] containsObject:rowAsNum])
				textField.text = [tempValues objectForKey:rowAsNum];
			else
				textField.text = server.password;
            
			break;
            
		default:
			break;
	}
	
	if (textFieldBeingEdited == textField)
		textFieldBeingEdited = nil;
    
    if (toggler != NULL)
        toggler.tag = row;
    else
       	textField.tag = row;
    
	[rowAsNum release];
	
	return cell;
}

#pragma mark - UISwitch value changed
- (void)switchValueChanged: (id)sender {
    UISwitch *toggler = (UISwitch *) sender;

	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:toggler.tag];
	[tempValues setObject:[NSNumber numberWithBool:toggler.on] forKey:tagAsNum];
	[tagAsNum release];   
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
	[tempValues setObject:textField.text forKey:tagAsNum];
	[tagAsNum release];
}

- (void)textFieldDone:(id)sender {
	UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
	UITableView *table = (UITableView *)[cell superview];
	NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];
	NSUInteger row = [textFieldIndexPath row];
	
	row++;
	if (row >= kNumberOfEditableRows)
		row = 0;
	
	NSUInteger newIndex[] = {0, row};
	NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
	UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:newPath];
	[newPath release];
	
	UITextField *nextField = nil;
	
	for (UIView *oneView in nextCell.contentView.subviews) {
		if ([oneView isMemberOfClass:[UITextField class]])
			nextField = (UITextField *)oneView;
	}
	
	[nextField becomeFirstResponder];
}

#pragma mark - Action Calls
- (IBAction)save:(id)sender {
	if (textFieldBeingEdited != nil) {
		NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textFieldBeingEdited.tag];
		[tempValues setObject:textFieldBeingEdited.text forKey:tagAsNum];
		[tagAsNum release];
        
        [textFieldBeingEdited resignFirstResponder];
	}
    
    Server *theServer;
    
    if (server == nil)
        theServer = [[Server alloc] init];
    else
        theServer = server;
    
    for (NSNumber *key in [tempValues allKeys]) {
		switch ([key intValue]) {
			case kServerNameRowIndex:
				theServer.name = [tempValues objectForKey:key];
				break;
			case kServerHostnameRowIndex:
				theServer.hostname = [tempValues objectForKey:key];
				break;
			case kServerPortRowIndex:
				theServer.port = [tempValues objectForKey:key];
				break;
            case kServerContextPathRowIndex:
                theServer.contextPath = [tempValues objectForKey:key];
                break;
			case kServerKeyPropertyListRowIndex:
				theServer.keyPropertyList = [tempValues objectForKey:key];
				break;
			case kServerUseSSLRowIndex:
				theServer.isSSLSecured = [[tempValues objectForKey:key] boolValue];
				break;
			case kServerUsernameRowIndex:
				theServer.username = [tempValues objectForKey:key];
				break;
			case kServerPasswordRowIndex:
				theServer.password = [tempValues objectForKey:key];
				break;
			default:
				break;
		}
	}
    
    // At least hostname and port must be defined
    if ([theServer.hostname length] == 0 ||
        [theServer.port length] == 0) {
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Please complete at least Hostname and Port field!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        return;
    }
    
    // Prefix the context path with the /
    // character if it is missing.
    if ([theServer.contextPath length] != 0 &&
        ![theServer.contextPath hasPrefix:@"/"]) {
        theServer.contextPath = [@"/" stringByAppendingString:theServer.contextPath];
    }
    
    if (server == nil) {  // if it is a new server 
        [[ServersManager sharedServersManager] addServer:theServer]; // add it to the list
        [theServer release];
	} 
    
    if ([tempValues count] != 0)  { // if there was any change
        // update server list on disk
        [[ServersManager sharedServersManager] save];
    }
    
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}
@end
