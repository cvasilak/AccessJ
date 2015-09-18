#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

#define kNonEditableTextColor    [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:1.0]

@class MBean;
@class ProgressViewController;

@interface MBeanAttributeEditor : UITableViewController<ASIHTTPRequestDelegate> {
    MBean *mbean;
    NSString *attr;
    
    ProgressViewController *spinner;
}

@property (nonatomic, retain) MBean *mbean;
@property (nonatomic, retain) NSString *attr;
@property (nonatomic, retain) ProgressViewController *spinner;

-(IBAction)updateWithValue:(id)value;
-(IBAction)cancel;
-(IBAction)save;

@end
