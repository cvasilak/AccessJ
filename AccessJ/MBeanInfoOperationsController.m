//
//  MBeanInfoOperationsController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "MBeanInfoOperationsController.h"
#import "MBeanOperationExecController.h"
#import "MBean.h"

@implementation MBeanInfoOperationsController

@synthesize mbean;
@synthesize ops;
@synthesize sortedKeys;
@synthesize parentNavigationController;

- (void)dealloc {
	[mbean release];
    [ops release];
    [sortedKeys release];
    
    [parentNavigationController release];
	
	DLog(@"MBeanInfoOperationsController deAlloc");
	
	[super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
	self.mbean = nil;
    self.ops = nil;
    self.sortedKeys = nil;
    self.parentNavigationController = nil;
    
    DLog(@"MBeanInfoOperationsController viewDidUnload");
    
  	[super viewDidUnload];
}

- (void)viewDidLoad {	
	[super viewDidLoad];
	
    self.ops = [NSMutableDictionary dictionary];

    NSEnumerator *keyEnum = [self.mbean.op keyEnumerator];

    NSString *key;
    while ((key = [keyEnum nextObject]) != nil) {
        id obj = [self.mbean.op valueForKey:key];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self.ops setValue:obj forKey:key];
        } else if ([obj isKindOfClass:[NSArray class]]) {  // handle similar method names but with different parameters
            
            for (int i = 0; i < [obj count]; i++) {
                [self.ops setValue:[[self.mbean.op valueForKey:key] objectAtIndex:i] forKey:[NSString stringWithFormat: @"%@ [%d]", key, i+1]];
            }
        }       
    }
    
    self.sortedKeys = [[self.ops allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
	DLog(@"MBeanInfoOperationsController viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Actions
- (IBAction)refresh {
   	[self.tableView reloadData];
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [sortedKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"OperationCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	
	NSString *opName = [sortedKeys objectAtIndex:row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ()", opName];
        
    NSDictionary *op = [ops valueForKey:opName];
    
    NSArray *params = [op valueForKey:@"args"];

    NSMutableString *descr = [NSMutableString string];
    BOOL canEdit = YES;
    
    if ([params count] != 0) {
        // create a string that is a 
        // concatenation of argument types
        [descr appendString:@"( "];
        for (int i = 0; i < [params count]; i++) {
            NSDictionary *param = [params objectAtIndex:i];
            NSString *type = [self beautifyJavaType:[param valueForKey:@"type"]];
       
            [descr appendString:type];
            
            // check if the operation can be edited
            if (canEdit) // if its not already set check otherwise no need, some parameter is not supported
                canEdit = [self canEditType:type];
            
            if (i < [params count]-1)
                [descr appendString:@", "];
        }
        
        [descr appendString:@" )"];
    }
    
    if (canEdit) {
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.detailTextLabel.text = descr;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}


#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];

    NSString *opName = [sortedKeys objectAtIndex:row];
    NSDictionary *op = [ops valueForKey:opName];
    
    NSArray *params = [op valueForKey:@"args"];
    
    // if args has an array parameter we don't support it (yet)
    for (NSDictionary *param in params) {
        NSString *type = [param valueForKey:@"type"];
        
        // strip out "java.lang"
        if ([type hasPrefix:@"java.lang."]) {
            // cut the "java.lang" and ";" character
            type = [type substringWithRange:NSMakeRange(10,[type length]-10)];
        }
        
        if (![self canEditType:type]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"we don't support invocation of this operation yet because of complex types (stay tuned!)"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Bummer"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];

            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
    }
    
    MBeanOperationExecController *opExecController = [[MBeanOperationExecController alloc] initWithStyle:UITableViewStyleGrouped];
    opExecController.mbean = mbean;
    opExecController.op = op;
    opExecController.opName = opName;
    opExecController.title = opName;
    
    [self.parentNavigationController pushViewController:opExecController animated:YES];

    [opExecController release];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Utility Methods
- (NSString *)beautifyJavaType:(NSString *)type {
    NSMutableString *descr = [NSMutableString string];
    
    if ([type hasPrefix:@"["]) { // the type is an array
        
        // the depth of a multidimensional array
        int lastOccurenceOfLeftBracket = (int)([type rangeOfString:@"[" options:NSBackwardsSearch].location) + 1;
        
        // determine encoding of type
        // see http://download.oracle.com/javase/6/docs/api/java/lang/Class.html#getName()
        NSString *encoding = [type substringWithRange:NSMakeRange(lastOccurenceOfLeftBracket, 1)];
        
        if ([encoding isEqualToString:@"Z"]) {
            [descr appendString:@"boolean"];
        } else if ([encoding isEqualToString:@"B"]) {
            [descr appendString:@"byte"];
        } else if ([encoding isEqualToString:@"C"]) {
            [descr appendString:@"char"];
        } else if ([encoding isEqualToString:@"D"]) {
            [descr appendString:@"double"];
        } else if ([encoding isEqualToString:@"F"]) {
            [descr appendString:@"float"];
        } else if ([encoding isEqualToString:@"I"]) {
            [descr appendString:@"int"];
        } else if ([encoding isEqualToString:@"J"]) {
            [descr appendString:@"long"];
        } else if ([encoding isEqualToString:@"S"]) {
            [descr appendString:@"short"];
        } else if ([encoding isEqualToString:@"L"]) {  // class name e.g. [Ljava.lang.Object;
            NSString *className = [type substringFromIndex:lastOccurenceOfLeftBracket+1];
            
            //strip out known package names
            if ([className hasPrefix:@"javax.management.openmbean."]) {
                [descr appendString:[className substringWithRange:NSMakeRange(27,[className length]-28)]];                
            } else if ([className hasPrefix:@"java.lang."]) {
                [descr appendString:[className substringWithRange:NSMakeRange(10,[className length]-11)]];
            } else {
                [descr appendString:className];                        
            }
        }
        
        //  [[[[D]
        // append multidimensioanal (depth) indicators
        for (int i = 0; i <= (lastOccurenceOfLeftBracket - 1); i++) {
            [descr appendString:@"[]"];
        }
        
    } else {
        if ([type hasPrefix:@"javax.management.openmbean."]) {
            type = [type substringWithRange:NSMakeRange(27,[type length]-27)];                
        } else if ([type hasPrefix:@"java.lang."]) {
            // cut the "java.lang" and ";" character
            type = [type substringWithRange:NSMakeRange(10,[type length]-10)];
        }
        
        [descr appendString:type];                        
        
    }
    
    return descr;
}

- (BOOL)canEditType:(NSString *)type {
    // no support for arrays
    if ([type hasPrefix:@"["])
        return NO;

    // use compare cause some primitive wrappers have similar names
    if (![type compare:@"long" options:NSCaseInsensitiveSearch] == NSOrderedSame &&
        ![type compare:@"int"  options:NSCaseInsensitiveSearch] == NSOrderedSame    &&
        ![type compare:@"short" options:NSCaseInsensitiveSearch] == NSOrderedSame   &&
        ![type compare:@"float" options:NSCaseInsensitiveSearch] == NSOrderedSame   &&
        ![type compare:@"double" options:NSCaseInsensitiveSearch] == NSOrderedSame  &&
        ![type compare:@"boolean" options:NSCaseInsensitiveSearch] == NSOrderedSame &&
        ![type isEqualToString:@"char"] &&
        ![type isEqualToString:@"Character"]  &&
        ![type isEqualToString:@"Integer"]    &&
        ![type isEqualToString:@"String"]     &&
        ![type isEqualToString:@"BigDecimal"] &&
        ![type isEqualToString:@"BigInteger"])
        
        return NO;
    
    return YES;
}

@end