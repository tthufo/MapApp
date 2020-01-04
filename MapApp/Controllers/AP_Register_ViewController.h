//
//  AP_Register_ViewController.h
//  MapApp
//
//  Created by Thanh Hai Tran on 4/10/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegisterDelegate <NSObject>

@optional

- (void)didUpdateData:(NSDictionary*)dict;

@end

@interface AP_Register_ViewController : UIViewController

@property (nonatomic, weak) id <RegisterDelegate> delegate;

@end

@interface NSObject (X)


@end
