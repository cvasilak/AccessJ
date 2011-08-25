//
//  MBean.h
//  AccessJ
//
//  Created by Christos Vasilakis on 20/06/2011.
//  Copyright 2011 forthnet S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Server;

@interface MBean : NSObject {
    NSString *domain;   
    NSString *objectName;
    Server *server;  // the server that this mbean belongs to
    NSDictionary *attr;  // the attributes of this mbean
    NSDictionary *op;    // the operations of this mbean    
}

@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *objectname;
@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) NSDictionary *attr;
@property (nonatomic, retain) NSDictionary *op;

@end
