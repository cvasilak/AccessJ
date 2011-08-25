#import "MBeanBooleanEditor.h"
#import "MBeanValue.h"
#import "MBean.h"

@implementation MBeanBooleanEditor

- (void)dealloc {
    DLog(@"MBeanBooleanEditor deAlloc");
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	DLog(@"MBeanBooleanEditor viewDidLoad");
}

#pragma mark -
#pragma mark Table View methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BooleanEditorCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 25)];
        label.textAlignment = UITextAlignmentCenter;
        label.tag = kLabelTag;
        UIFont *font = [UIFont boldSystemFontOfSize:18.0];
        label.textColor = kNonEditableTextColor;
        label.font = font;
        [cell.contentView addSubview:label];
        [label release];
		
        UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(190, 10, 70, 25)];
        theSwitch.tag = kSwitchFieldTag;
        
        [cell.contentView addSubview:theSwitch];
        [theSwitch release];
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:kLabelTag];
    label.text = attr;
    
    UISwitch *toggler = (UISwitch *)[cell.contentView viewWithTag:kSwitchFieldTag];
    toggler.on = [[[mbean.attr valueForKey:attr] valueForKey:@"value"] boolValue];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)save {
    NSUInteger onlyRow[] = {0, 0};
    NSIndexPath *onlyRowPath = [NSIndexPath indexPathWithIndexes:onlyRow length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:onlyRowPath];
    UISwitch *toggler = (UISwitch *)[cell.contentView viewWithTag:kSwitchFieldTag];

    [super updateWithValue:([NSNumber numberWithBool:toggler.on])];
}
@end
