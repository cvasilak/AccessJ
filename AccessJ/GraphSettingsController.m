//
//  GraphSettingsController.m
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import "GraphSettingsController.h"

@implementation GraphSettingsController

@synthesize delegate;
@synthesize updateIntervalSlider;
@synthesize updateIntervalLabel;

- (void)dealloc {
    [updateIntervalSlider release];
    [updateIntervalLabel release];
    
    DLog(@"GraphSettingsController dealloc");    
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    self.updateIntervalSlider = nil;
    self.updateIntervalLabel = nil;
    
    DLog(@"GraphSettingsController viewDidUnLoad");    
    [super viewDidUnload];	
}

- (void)viewDidLoad {
    DLog(@"GraphSettingsController viewDidLoad");    
    
    // set to the default
    updateIntervalLabel.text = @"2 seconds";
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Actions
- (void)refreshFields {
    //updateIntervalSlider.value = [defaults floatForKey:kWarpFactorKey];
}

- (IBAction)touchUpdateIntervalSlider {
    updateIntervalLabel.text =[ NSString stringWithFormat:@"%.0f seconds", updateIntervalSlider.value];
}

- (IBAction)done:(id)sender {
	[self.delegate graphSettingsControllerDidFinish:self];	
}

@end
