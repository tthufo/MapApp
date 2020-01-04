//
//  YouTube.h
//  Trending
//
//  Created by thanhhaitran on 8/27/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UrlCompletion)(int index, NSDictionary* info);

@interface YouTube : NSObject

@property(nonatomic,copy) UrlCompletion completion;

+ (YouTube*)share;

- (void)returnUrl:(NSString*)vid andCompletion:(UrlCompletion)complete_;

+ (NSString *)totalDiskSpace;

/*!
 The free disk space
 @return String which represents the free disk space
 */
+ (NSString *)freeDiskSpace;

/*!
 The used disk space
 @return String which represents the used disk space
 */
+ (NSString *)usedDiskSpace;

/*!
 The total disk space in bytes
 @return CGFloat represents the total disk space in bytes
 */
+ (CGFloat)totalDiskSpaceInBytes;

/*!
 The free disk space in bytes
 @return CGFloat represents the free disk space in bytes
 */
+ (CGFloat)freeDiskSpaceInBytes;

/*!
 The used disk space in bytes
 @return CGFloat represents the used disk space in bytes
 */
+ (CGFloat)usedDiskSpaceInBytes;

@end
