//
//  ServersManager.h
//  AccessJ
//
//  Created by Christos Vasilakis on 14/06/2011.
//  Copyright 2011 All rights reserved.
//

#import <Foundation/Foundation.h>

@class Server;

@interface ServersManager : NSObject {
	NSMutableArray *list;
}

@property (nonatomic, retain) NSMutableArray *list;

- (NSUInteger)count;

- (void)addServer:(Server *)server;
- (void)removeServerAtIndex:(NSUInteger)index;

- (Server *)serverAtIndex:(NSUInteger)index;

- (void)load;
- (void)save;

+ (ServersManager *)sharedServersManager;

@end
