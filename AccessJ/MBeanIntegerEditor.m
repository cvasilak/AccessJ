#import "MBeanIntegerEditor.h"
#import "MBeanValue.h"
#import "MBean.h"

@implementation MBeanIntegerEditor

-(void)dealloc {
    DLog(@"MBeanIntegerEditor deAlloc");
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	DLog(@"MBeanIntegerEditor viewDidLoad");
}

#pragma mark -
#pragma mark Table View methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"IntegerEditorCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 210, 25)];
   		label.tag = kLabelTag;
        label.textAlignment = UITextAlignmentCenter;
        
        UIFont *font = [UIFont boldSystemFontOfSize:18.0];
        label.textColor = kNonEditableTextColor;
        label.font = font;
        [cell.contentView addSubview:label];
        [label release];
		
        UITextField *theTextField = [[UITextField alloc] 
                                     initWithFrame:CGRectMake(220, 10, 70, 25)];
        
        theTextField.adjustsFontSizeToFitWidth = YES;
        theTextField.textAlignment = UITextAlignmentRight;
        theTextField.keyboardType = UIKeyboardTypeDecimalPad;
        
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
    
    // convert to NSNUmber
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * theNumber = [f numberFromString:textField.text];
    [f release];
    
    [super updateWithValue:theNumber];
}
@end
