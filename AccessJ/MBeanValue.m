#import "MBeanValue.h"

@implementation NSString (MBeanValue)
- (NSString *)cellDisplay {
	return self;
}

- (NSString *)controllerClassName {
    return @"MBeanStringEditor";
}

- (BOOL)canBePlotted {
    return NO;
}
@end

@implementation NSDate (MBeanValue)
- (NSString *)cellDisplay {
    
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *ret = [formatter stringFromDate:self];
	[formatter release];
	return ret;
}

- (NSString *)controllerClassName {
    return nil;
}

- (BOOL)canBePlotted {
    return NO;
}
@end

@implementation NSNumber (MBeanValue) 
- (NSString *)cellDisplay {
    if ([self isBoolean]) {
        return ([self boolValue] == YES? @"true":@"false");
    }
    
   return [self descriptionWithLocale:[NSLocale currentLocale]];
}

- (BOOL)isBoolean {
    // TODO: Determine how to correctly check if its a boolean value
    if ([[[self class] description] isEqualToString:@"__NSCFBoolean"] ||
        [[[self class] description] isEqualToString:@"NSCFBoolean"]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)controllerClassName {
    if ([self isBoolean]) {
        return @"MBeanBooleanEditor";
    }
    
    return @"MBeanIntegerEditor";
}

- (BOOL)canBePlotted {
    return ([self isBoolean]?NO:YES);
}

@end

@implementation NSDecimalNumber (MBeanValue) 
- (NSString *)cellDisplay {
    return [self descriptionWithLocale:[NSLocale currentLocale]];
}

- (NSString *)controllerClassName {
    return @"MBeanStringEditor";
}

- (BOOL)canBePlotted {
    return YES;
}

@end

@implementation NSArray (MBeanValue) 
- (NSString *)cellDisplay {
    return @"";
}

- (NSString *)controllerClassName {
    return nil;
}

- (BOOL)canBePlotted {
    return NO;
}
@end

@implementation NSDictionary (MBeanValue) 
- (NSString *)cellDisplay {
    return @"";
}

- (NSString *)controllerClassName {
    return nil;
}

- (BOOL)canBePlotted {
    return NO;
}

@end

@implementation NSNull (MBeanValue) 
- (NSString *)cellDisplay {
    return @"null";
}

- (NSString *)controllerClassName {
    return nil;
}

- (BOOL)canBePlotted {
    return NO;
}

@end




