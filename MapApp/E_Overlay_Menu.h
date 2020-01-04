//
//  E_Overlay_Menu.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/5/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OverLayAction)(NSDictionary * actionInfo);

@interface E_Overlay_Menu : UIView

@property (nonatomic, copy) OverLayAction onTapEvent;

+ (E_Overlay_Menu*)shareMenu;

- (void)didShowSearch:(NSDictionary*)info andCompletion:(OverLayAction)overLay;

- (void)closeMenu;

- (void)endTimer;

@end
