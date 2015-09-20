//
//  ProgressViewController.m
//  jboss-admin
//
//  Created by Christos Vasilakis on 04/07/2010.
//  Copyright 2010 forthnet S.A. All rights reserved.
//

#import "ProgressViewController.h"


@implementation ProgressViewController

@synthesize spinner;
@synthesize parentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParentView:(UIView *)view {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.parentView = view;
    }
    return self;
}


- (void)startAnimating {
    [self adjustOrientation];
    
    [parentView addSubview:self.view];
}

- (void)stopAnimating {
    [self.view removeFromSuperview];
}

- (void)adjustOrientation {
    // TODO: find a better way seems a hack
    CGRect newFrame = [[UIScreen mainScreen] applicationFrame];
    newFrame =  CGRectMake(0.0, 0.0, newFrame.size.width, newFrame.size.height+20);
    [self.view setFrame:newFrame];
    
    [self.view setNeedsDisplay];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.spinner = nil;
	self.parentView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
}

- (void)dealloc {
	[spinner release];
    [parentView release];
    
    [super dealloc];
}


@end
