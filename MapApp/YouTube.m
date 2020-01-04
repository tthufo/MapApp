//
//  YouTube.m
//  Trending
//
//  Created by thanhhaitran on 8/27/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "YouTube.h"

#import "XCDYouTubeClient.h"

#import "XCDYouTubeVideo.h"

static YouTube * instance = nil;

@implementation YouTube

@synthesize completion;

+ (YouTube*)share
{
    if(!instance)
    {
        instance = [YouTube new];
    }
    return  instance;
}

- (NSArray *)preferredVideoQualities
{
    return @[ XCDYouTubeVideoQualityHTTPLiveStreaming,@(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240), @(XCDYouTubeVideoQualityHD720)];
}

- (void)returnUrl:(NSString*)vid andCompletion:(UrlCompletion)complete_
{
    self.completion = complete_;
    
    [self showSVHUD:@"Loading" andOption:0];
    
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:vid completionHandler:^(XCDYouTubeVideo *video, NSError *error)
     {
         if (video)
         {
             NSURL *streamURL = nil;
             
             for (NSNumber *videoQuality in self.preferredVideoQualities)
             {
                 streamURL = video.streamURLs[videoQuality];
                 
                 if (streamURL)
                 {
                     self.completion(0, @{@"url":streamURL,@"link":[streamURL absoluteString]});
                     
                     break;
                 }
             }
             
             if (!streamURL)
             {
                 self.completion(-1, @{@"url":@(0)});

                 //[self showToast:@"Video is not available, please try again later" andPos:0];
             }
         }
         else
         {
             self.completion(-1, @{@"url":@(0)});

             //[self showToast:@"Video is not available, please try again later" andPos:0];
         }
         
         [self hideSVHUD];
         
//         self.completion(1, @{});
     }];
}

#define MB (1024*1024)
#define GB (MB*1024)

#pragma mark - Formatter

+ (NSString *)memoryFormatter:(long long)diskSpace {
    NSString *formatted;
    double bytes = 1.0 * diskSpace;
    double megabytes = bytes / MB;
    double gigabytes = bytes / GB;
    if (gigabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f GB", gigabytes];
    else if (megabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f MB", megabytes];
    else
        formatted = [NSString stringWithFormat:@"%.2f bytes", bytes];
    
    return formatted;
}

#pragma mark - Methods

+ (NSString *)totalDiskSpace {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return [self memoryFormatter:space];
}

+ (NSString *)freeDiskSpace {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return [self memoryFormatter:freeSpace];
}

+ (NSString *)usedDiskSpace {
    return [self memoryFormatter:[self usedDiskSpaceInBytes]];
}

+ (CGFloat)totalDiskSpaceInBytes {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return space;
}

+ (CGFloat)freeDiskSpaceInBytes {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return freeSpace;
}

+ (CGFloat)usedDiskSpaceInBytes {
    long long usedSpace = [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
    return usedSpace;
}

/*! WORK IN PROGRESS */
+ (CGFloat)numberOfNodes {
    long long numberOfNodes = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemNodes] longLongValue];
    return numberOfNodes;
}


@end
