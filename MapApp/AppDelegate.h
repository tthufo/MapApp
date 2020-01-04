//
//  AppDelegate.h
//  MapApp
//
//  Created by Thanh Hai Tran on 4/9/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readwrite) BOOL isTurn;

@end


@interface UIView (ahihi)

- (void)selfVisible;

- (void)imageUrl:(NSString*)url;

- (void)imageUrlNoCache:(NSString*)url andCache:(UIImage*)image;

@end

@interface NSMutableAttributedString (color)

- (void)setColorForText:(NSString*) textToFind withColor:(UIColor*) color;

@end

@interface NSObject (XXX)

- (BOOL)isIphoneX;

@end
