#import "MBeanStringEditor.h"
#import "MBeanValue.h"
#import "MBean.h"

@implementation MBeanStringEditor

-(void)dealloc {
    DLog(@"MBeanStringEditor deAlloc");
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	DLog(@"MBeanStringEditor viewDidLoad");
}


#pragma mark -
#pragma mark Table View methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StringEditorCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 25)];
   		label.tag = kLabelTag;
        label.textAlignment = NSTextAlignmentCenter;
        
        UIFont *font = [UIFont boldSystemFontOfSize:18.0];
        label.textColor = kNonEditableTextColor;
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        [cell.contentView addSubview:label];
        [label release];
		
        UITextField *theTextField = [[UITextField alloc] 
                                     initWithFrame:CGRectMake(160, 10, 130, 25)];
        
        theTextField.adjustsFontSizeToFitWidth = YES;
        theTextField.textAlignment = NSTextAlignmentRight;

        theTextField.tag = kTextFieldTag;
        [cell.contentView addSubview:theTextField];
        
        [theTextField release];
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:kLabelTag];
    
    label.text = attr;
    
    UITextField *textField = (UITextField *)[cell.contentView 
                                             viewWithTag:kTextFieldTag];
    
    id <MBeanValue, NSObject> rawValue = [[mbean.attr valueForKey:attr] valueForKey:@"value"];
    textField.text = [rawValue cellDisplay];
    
    [textField becomeFirstResponder];
    return cell;
}

-(IBAction)save {
    NSUInteger onlyRow[] = {0, 0};
    NSIndexPath *onlyRowPath = [NSIndexPath indexPathWithIndexes:onlyRow length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:onlyRowPath];
    UITextField *textField = (UITextField *)[cell.contentView 
                                             viewWithTag:kTextFieldTag];

    [textField resignFirstResponder];
    
    [super updateWithValue:textField.text];
}
@end
