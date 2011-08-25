//
//  GraphSettingsController.h
//  AccessJ
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2011 All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GraphSettingsControllerDelegate;

@interface GraphSettingsController : UIViewController {
	id <GraphSettingsControllerDelegate> delegate;
    UISlider *updateIntervalSlider;
    UILabel  *updateIntervalLabel;
}

@property (nonatomic, assign) id <GraphSettingsControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UISlider *updateIntervalSlider;
@property (nonatomic, retain) IBOutlet UILabel  *updateIntervalLabel;

- (void)refreshFields;
- (IBAction)touchUpdateIntervalSlider;
- (IBAction)done:(id)sender;
@end


@protocol GraphSettingsControllerDelegate
- (void)graphSettingsControllerDidFinish:(GraphSettingsController *)controller;
@end

