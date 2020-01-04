//
//  AP_Web_ViewController.h
//  MapApp
//
//  Created by Thanh Hai Tran on 4/12/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewPagerController.h"

@interface AP_Web_ViewController : ViewPagerController

@property(nonatomic, retain) NSDictionary * info;

- (void)didOpenWeb:(NSString*)url;

@end
