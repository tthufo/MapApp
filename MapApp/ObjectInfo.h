//
//  Object.h
//  MapApp
//
//  Created by Thanh Hai Tran on 4/12/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectInfo : NSObject

+ (ObjectInfo*)shareInstance;

@property(nonatomic, retain) NSString * token;

@property(nonatomic, retain) NSMutableDictionary * uInfo;

@property(nonatomic, retain) NSArray * tiles;

@end
