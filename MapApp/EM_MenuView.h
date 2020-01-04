//
//  EM_MenuView.h
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "CustomIOS7AlertView.h"

@class EM_MenuView;

typedef void (^MenuCompletion)(int index, id object, EM_MenuView * menu);

@interface EM_MenuView : CustomIOS7AlertView

- (id)initWithMenu:(NSDictionary*)info;

- (id)initWithLayers:(NSDictionary*)info;

- (id)initWithDate:(NSDictionary*)info;

- (EM_MenuView*)showWithCompletion:(MenuCompletion)_completion;

@property(nonatomic,copy) MenuCompletion menuCompletion;

@end
