//
//  MBeanAttributePlotController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapkuLibrary.h"

#import "GraphSettingsController.h"

#import "ASIHTTPRequestDelegate.h"

@class MBean;

@interface MBeanAttributePlotController : TKGraphController <GraphSettingsControllerDelegate, ASIHTTPRequestDelegate> {
    MBean *mbean;
    
    NSString *currentDisplayedAttributeName;
    id currentValue;
    
    NSString *path;

    GraphSettingsController *settingsController;
    UINavigationController *parentNavigationController;
    
    NSTimer *updateTimer;
    float secs;
    
    NSMutableArray *dataForPlot;
}

@property (nonatomic, retain) MBean *mbean;
@property (nonatomic, retain) NSString *currentDisplayedAttributeName;
@property (nonatomic, retain) id currentValue;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) UINavigationController *parentNavigationController;
@property (nonatomic, retain) GraphSettingsController *settingsController;
@property (nonatomic, retain) NSTimer *updateTimer;

@property(readwrite, retain, nonatomic) NSMutableArray *dataForPlot;

- (IBAction)showGraphSettings:(id)sender;
@end

@interface GraphPoint : NSObject <TKGraphViewPoint> {
	NSNumber *timestamp;
	NSNumber *value;
}

- (id) initWithTimestamp:(NSNumber *)theTimestamp value:(NSNumber *)theValue;

@end

