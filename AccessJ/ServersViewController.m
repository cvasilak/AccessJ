//
//  ServersViewController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "ServersViewController.h"
#import "ServerDetailController.h"
#import "DomainsViewController.h"
#import "ProgressViewController.h"

#import "Server.h"
#import "ServersManager.h"


@implementation ServersViewController

- (void)dealloc {
    DLog(@"ServersViewController deAlloc");
    
	[super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"ServersViewController viewDidUnload");
    
	[super viewDidUnload];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
    self.title = @"Servers List";
	
	UIBarButtonItem *editButton = self.editButtonItem; 
    [editButton setTarget:self];
    [editButton setAction:@selector(toggleEdit)];
    self.navigationItem.leftBarButtonItem = editButton;
    
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addServer)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
	DLog(@"ServersViewController viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[ServersManager sharedServersManager] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ServerCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	
    Server *server = [[ServersManager sharedServersManager] serverAtIndex:row];
	
	cell.textLabel.text = server.name;
    //[NSString stringWithFormat:@"http://%@:%@/jolokia", self.hostname, self.port];

    
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@", server.hostname, server.port];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

	return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
	
    Server *server = [[ServersManager sharedServersManager] serverAtIndex:row];    
    
	DomainsViewController *domController = [[DomainsViewController alloc] initWithStyle:UITableViewStylePlain];
    domController.server = server;
    
    [self.navigationController pushViewController:domController animated:YES];

	[domController release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	
    Server *server = [[ServersManager sharedServersManager] serverAtIndex:row];

	ServerDetailController *detailController = [[ServerDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	detailController.title = server.name;
	detailController.server = server;

	[self.navigationController pushViewController:detailController animated:YES];
	
    [detailController release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSUInteger row = [indexPath row];
		NSArray *paths = [NSArray arrayWithObject: [NSIndexPath indexPathForRow:row inSection:0]];
	
	    [[ServersManager sharedServersManager] removeServerAtIndex:row];

        // update server list on disk
        [[ServersManager sharedServersManager] save];
        
        [[self tableView] deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
	}
}

#pragma mark - Action Calls
- (IBAction)addServer {
	ServerDetailController *detailController = [[ServerDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	detailController.title = @"New Server";
	
	[self.navigationController pushViewController:detailController animated:YES];

	[detailController release];
}

- (IBAction)toggleEdit {
    BOOL editing = !self.tableView.editing;
    self.navigationItem.rightBarButtonItem.enabled = !editing;
    self.navigationItem.leftBarButtonItem.title = (editing) ? @"Done" :  @"Edit";
    [self.tableView setEditing:editing animated:YES];
}

@end
