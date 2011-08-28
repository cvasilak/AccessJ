//
//  ServersManager.m
//  AccessJ
//
//  Created by Christos Vasilakis on 14/06/2011.
//  Copyright 2011 All rights reserved.
//

#import "ServersManager.h"
#import "Server.h"

static ServersManager *SharedServersManager = nil;

@implementation ServersManager

@synthesize list;

+ (ServersManager *)sharedServersManager {
	if (SharedServersManager == nil) {
		SharedServersManager = [[super allocWithZone:NULL] init];
	}
	
	return SharedServersManager;
}

-(id)init {
    [self load];
    
	return (self);
}

- (void)dealloc {
    DLog(@"ServersManager deAlloc");
    
    [list release];
    
	[super dealloc];
}

- (NSUInteger)count {
    return [self.list count];
}

- (void)addServer:(Server *)server {
    [self.list addObject:server];
}

- (void)removeServerAtIndex:(NSUInteger)index {
    [self.list removeObjectAtIndex:index];
}

- (Server *)serverAtIndex:(NSUInteger)index {
    return [self.list objectAtIndex:index];
}

-(NSString *)dataFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"Servers.archive"];
}

- (void)load {
    NSString *filePath = [self dataFilePath];
    
    // if file exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // load data
        NSData *data;
        NSKeyedUnarchiver *unarchiver;
        
        data = [[NSData alloc] initWithContentsOfFile:filePath];
        unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        self.list = [unarchiver decodeObjectForKey:@"Servers"];
        
        [unarchiver finishDecoding];
        [unarchiver release];
        [data release];
    } else {
        // initialize an empty list
        // and add the AccessJ-demo site 
        // as a showcase for new users
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        self.list = array;

        [array release];

        Server *server = [[Server alloc] init];
        server.name = @"AccessJ-Demo";
        server.hostname = @"cvasilak.org";
        server.keyPropertyList = @"type, service";
        server.port = @"8080";
        server.username = @"";
        server.password = @"";
        
        [self addServer:server];
        
        [server release];
        
        [self save];
    }
}

// TODO: If there are no updates do not save  (Called in applicationWillTerminate at AccessJAppDelegate)
- (void)save {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:list forKey:@"Servers"];
    [archiver finishEncoding];
    
    [data writeToFile:[self dataFilePath] atomically:YES];
    
    [archiver release];
    [data release];
}

#pragma mark -
#pragma mark Singleton methods

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedServersManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
