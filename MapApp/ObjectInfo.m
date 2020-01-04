//
//  Object.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/12/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "ObjectInfo.h"

static ObjectInfo * shareInstan = nil;

@implementation ObjectInfo

@synthesize token, uInfo, tiles;

+ (ObjectInfo*)shareInstance
{
    if(!shareInstan)
    {
        shareInstan = [ObjectInfo new];
    }
    
    return shareInstan;
}

@end
