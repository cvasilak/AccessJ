//
//  ProgressViewController.h
//  jboss-admin
//
//  Created by Christos Vasilakis on 04/07/2010.
//  Copyright 2010 forthnet S.A. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressViewController : UIViewController {
    UIView *parentView;
	UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIView *parentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParentView:(UIView *)view;
    
- (void)adjustOrientation;

- (void)startAnimating;
- (void)stopAnimating;

@end
