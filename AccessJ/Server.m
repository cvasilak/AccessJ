//
//  Server.m
//  AccessJ
//
//  Created by Christos Vasilakis on 14/06/2011.
//  Copyright 2011 All rights reserved.
//

#import "Server.h"

@implementation Server
@synthesize name;
@synthesize hostname;
@synthesize port;
@synthesize contextPath;
@synthesize keyPropertyList;
@synthesize isSSLSecured;
@synthesize username;
@synthesize password;

- (void)dealloc {
	[name release];
	[hostname release];
    [port release];
    [contextPath release];
    [keyPropertyList release];
	[username release];
	[password release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.name forKey:kServerNameKey];
	[aCoder encodeObject:self.hostname forKey:kServerHostnameKey];
   	[aCoder encodeObject:self.port forKey:kServerPortKey];
    [aCoder encodeObject:self.contextPath forKey:kServerContextPathKey];
   	[aCoder encodeObject:self.keyPropertyList forKey:kPropertyListKey];
    [aCoder encodeBool:self.isSSLSecured forKey:kisSSLSecured];
	[aCoder encodeObject:self.username forKey:kServerUsernameKey];
	[aCoder encodeObject:self.password forKey:kServerPasswordKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		self.name = [aDecoder decodeObjectForKey:kServerNameKey];
		self.hostname = [aDecoder decodeObjectForKey:kServerHostnameKey];
   		self.port = [aDecoder decodeObjectForKey:kServerPortKey];
        self.contextPath = [aDecoder decodeObjectForKey:kServerContextPathKey];
        self.keyPropertyList = [aDecoder decodeObjectForKey:kPropertyListKey];
        self.isSSLSecured = [aDecoder decodeBoolForKey:kisSSLSecured];
		self.username = [aDecoder decodeObjectForKey:kServerUsernameKey];
		self.password = [aDecoder decodeObjectForKey:kServerPasswordKey];
	}
	
	return self;
}

- (NSString *)hostport {
    NSMutableString *hostport = [NSMutableString stringWithCapacity:100];
    
    if (isSSLSecured)
        [hostport appendString:@"https://"];
    else
        [hostport appendString:@"http://"];
    
    if (username != nil && ![username isEqualToString:@""]) {
        [hostport appendFormat:@"%@:%@@", username, password];
    }

    [hostport appendFormat:@"%@:%@", hostname, port];
    
    if ([contextPath length] == 0)  {
        [hostport appendString:@"/jolokia"];
    } else {
        [hostport appendString:self.contextPath];
    }
    
    return hostport;
}

@end
