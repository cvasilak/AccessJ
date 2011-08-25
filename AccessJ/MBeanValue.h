#import <Foundation/Foundation.h>

@protocol MBeanValue
- (NSString *)cellDisplay;
- (NSString *)controllerClassName;
- (BOOL)canBePlotted;
@end

@interface NSString (MBeanValue) <MBeanValue>
- (NSString *)cellDisplay;
- (NSString *)controllerClassName;
- (BOOL)canBePlotted;
@end

@interface NSDate (MBeanValue) <MBeanValue>
- (NSString *)cellDisplay;
- (NSString *)controllerClassName;
- (BOOL)canBePlotted;
@end

@interface NSNumber (MBeanValue) <MBeanValue>
- (NSString *)cellDisplay;
- (NSString *)controllerClassName;
- (BOOL)isBoolean;
- (BOOL)canBePlotted;
@end

@interface NSDecimalNumber (MBeanValue) <MBeanValue>
- (NSString *)cellDisplay;
- (NSString *)controllerClassName;
- (BOOL)canBePlotted;
@end

@interface NSArray (MBeanValue) <MBeanValue>
- (NSString *)cellDisplay;
- (NSString *)controllerClassName;
- (BOOL)canBePlotted;
@end

@interface NSDictionary (MBeanValue) <MBeanValue>
- (NSString *)cellDisplay;
- (NSString *)controllerClassName;
- (BOOL)canBePlotted;
@end

@interface NSNull (MBeanValue) <MBeanValue>
- (NSString *)cellDisplay;
- (NSString *)controllerClassName;
- (BOOL)canBePlotted;
@end