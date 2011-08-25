//
//  MBean.m
//  AccessJ
//
//  Created by Christos Vasilakis on 20/06/2011.
//  Copyright 2011 forthnet S.A. All rights reserved.
//

#import "MBean.h"


@implementation MBean

@synthesize domain;
@synthesize objectname;
@synthesize server;
@synthesize attr;
@synthesize op;

- (void)dealloc {
	[domain release];
	[objectName release];
	[server release];
   	[attr release];
	[op release];
    
	[super dealloc];
}
@end
