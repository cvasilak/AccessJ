//
//  Server.h
//  AccessJ
//
//  Created by Christos Vasilakis on 14/06/2011.
//  Copyright 2011 All rights reserved.
//

#import <Foundation/Foundation.h>

#define kServerNameKey          @"Name"
#define kServerHostnameKey      @"Hostname"
#define kServerPortKey          @"Port"
#define kServerContextPathKey   @"contextPath"
#define kPropertyListKey        @"keyPropertyList"
#define kisSSLSecured           @"isSSLSecured"
#define kServerUsernameKey      @"Username"
#define kServerPasswordKey      @"Password"


@interface Server : NSObject <NSCoding> {
	NSString *name;
	NSString *hostname;
    NSString *port;
    NSString *contextPath;
    BOOL     isSSLSecured;
    NSString *keyPropertyList;
	NSString *username;
	NSString *password;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *hostname;
@property (nonatomic, retain) NSString *port;
@property (nonatomic, retain) NSString *contextPath;
@property (nonatomic, retain) NSString *keyPropertyList;
@property (nonatomic) BOOL     isSSLSecured;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

- (NSString *)hostport;

@end
