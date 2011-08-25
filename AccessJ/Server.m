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
@synthesize keyPropertyList;
@synthesize username;
@synthesize password;

- (void)dealloc {
	[name release];
	[hostname release];
    [port release];
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
   	[aCoder encodeObject:self.keyPropertyList forKey:kPropertyList];
	[aCoder encodeObject:self.username forKey:kServerUsernameKey];
	[aCoder encodeObject:self.password forKey:kServerPasswordKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		self.name = [aDecoder decodeObjectForKey:kServerNameKey];
		self.hostname = [aDecoder decodeObjectForKey:kServerHostnameKey];
   		self.port = [aDecoder decodeObjectForKey:kServerPortKey];
        self.keyPropertyList = [aDecoder decodeObjectForKey:kPropertyList];
		self.username = [aDecoder decodeObjectForKey:kServerUsernameKey];
		self.password = [aDecoder decodeObjectForKey:kServerPasswordKey];
	}
	
	return self;
}

- (NSString *)hostport {
    if ([username isEqualToString:@""] && [password isEqualToString:@""]) {
        return [NSString stringWithFormat:@"http://%@:%@/jolokia", self.hostname, self.port];        
    } 

    return [NSString stringWithFormat:@"https://%@:%@@%@:%@/jolokia", self.username, self.password, self.hostname, self.port];        
}

@end
