//
//  E_Overlay_Menu.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/5/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Overlay_Menu.h"

static E_Overlay_Menu * shareInstance = nil;

@interface E_Overlay_Menu ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * dataList, * tempList;
    
    NSMutableDictionary * dictInfo;
    
    NSTimer * time;
    
    BOOL isOn;
}

@end

@implementation E_Overlay_Menu

@synthesize onTapEvent;

- (void)registerForKeyboardNotifications:(BOOL)isRegister andHost:(UIView*)host andSelector:(NSArray*)selectors
{
    if(isRegister)
    {
        [[NSNotificationCenter defaultCenter] addUniqueObserver:host selector:NSSelectorFromString(selectors[0]) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addUniqueObserver:host selector:NSSelectorFromString(selectors[1]) name:UIKeyboardWillHideNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:host name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:host name:UIKeyboardWillHideNotification object:nil];
    }
}

+ (E_Overlay_Menu*)shareMenu
{
    if(!shareInstance)
    {
        shareInstance = [E_Overlay_Menu new];
    }
    
    return shareInstance;
}

- (void)didShowSearch:(NSDictionary*)info andCompletion:(OverLayAction)overLay
{
    self.onTapEvent = overLay;
    
    if(dictInfo)
    {
        [dictInfo removeAllObjects];
        
        [dictInfo addEntriesFromDictionary:info];
    }
    else
    {
        dictInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    }
    
    if(dataList)
    {
        [dataList removeAllObjects];
        
        dataList = nil;
    }
    
    if(tempList)
    {
        [tempList removeAllObjects];
        
        tempList = nil;
    }
    
    if(dataList)
    {
        [dataList removeAllObjects];
        
        dataList = nil;
    }
    
    dataList = [[NSMutableArray alloc] initWithArray:@[]];
    
    for(UIView * v in self.subviews)
    {
        [v removeFromSuperview];
    }
    
    [self registerForKeyboardNotifications:YES andHost:self andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(didChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [self didInitBase];
    
    [info[@"textField"] addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)theTextField
{
    if(time)
    {
        [time invalidate];
        
        time = nil;
    }
    
    time = [NSTimer scheduledTimerWithTimeInterval: 1.5 target:self selector:@selector(didRequestForSuggestion:) userInfo:theTextField repeats: NO];
}

- (void)endTimer
{
    if(time)
    {
        [time invalidate];

        time = nil;
    }
    
    time = [NSTimer scheduledTimerWithTimeInterval: 0.00001 target:self selector:@selector(didRequestForSuggestion:) userInfo:((UITextField*)dictInfo[@"textField"]) repeats: NO];
}

- (void)didRequestForSuggestion:(NSTimer*)timer
{
    if(![timer userInfo] || ((UITextField*)[timer userInfo]).text.length == 0)
    {
        return;
    }
        
    NSDictionary * infoPlist = [self dictWithPlist:@"Info"];
    
    NSMutableDictionary * dict = [@{@"absoluteLink":[NSString stringWithFormat:@"%@/point/search?q=%@", infoPlist[@"host"], [((UITextField*)[timer userInfo]).text encodeUrl]],
                                    @"method":@"GET",
                                    @"host":self.superview.parentViewController,
                                    @"overrideLoading":@(1),
                                    @"overrideAlert":@(1),
                                    } mutableCopy];

    [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        if(!responseString)
        {
            [self showToast:@"Không tìm thấy kết quả" andPos:1];
            
            return;
        }
        
        if([errorCode isEqualToString:@"200"])
        {
            [dataList removeAllObjects];

            if(((NSArray*)[responseString objectFromJSONString][@"array"]).count == 0)
            {
                [self showToast:@"Không tìm thấy kết quả" andPos:1];
            }
            else
            {
                [dataList addObjectsFromArray:[responseString objectFromJSONString][@"array"]];
            }
        }
        
        [((UITableView*)[self withView:self tag:11]) cellVisible];
        
        [((UITableView*)[self withView:self tag:11]) reloadData];
    }];
}

- (void)didChangeFrame:(NSNotification *)notification
{
    if(isOn)
    {
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        //[self changeFrame:keyboardSize.height];
        
        self.onTapEvent(@{@"menu":self, @"state":@(1), @"height":@(keyboardSize.height)});
    }
}

- (void)didEndFrame:(NSNotification *)notification
{
    isOn = NO;
}

- (void)didInitBase
{
    self.frame = CGRectMake(0, screenHeight1, screenWidth1, 0);
    
    UIView * base = [[NSBundle mainBundle] loadNibNamed:@"E_OverLay_View" owner:nil options:nil][0];
    
    base.tag = 1999;
    
    base.frame = CGRectMake(10, 0, screenWidth1 - 20, self.frame.size.height);
    
    [((UITableView*)[self withView:base tag:11]) withCell:@"E_Search_Cell"];
    
    [((UITableView*)[self withView:base tag:11]) withCell:@"E_Empty_Music"];
    
    ((UITableView*)[self withView:base tag:11]).delegate = self;
    
    ((UITableView*)[self withView:base tag:11]).dataSource = self;
    
    [self addSubview:base];
    
    [((UIViewController*)dictInfo[@"host"]).view addSubview:self];
    
    [((UITableView*)[self withView:base tag:11]) cellVisible];
}

- (void)changeFrame:(float)sizeHeight
{
    float gap = [self isIphoneX] ? 100 : 80;
    
    self.frame = CGRectMake(0, screenHeight1, screenWidth1, screenHeight1 - gap - 5 - sizeHeight - 44);
    
    CGRect rect = ((UIView*)[self withView:self tag:1999]).frame;
    
    rect.size.height = self.frame.size.height;
    
    ((UIView*)[self withView:self tag:1999]).frame = rect;
    
    [((UITableView*)[self withView:((UIView*)[self withView:self tag:1999]) tag:11]) cellVisible];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if(!isOn)
    {
        float gap = [self isIphoneX] ? 100 : 80;
        
        [self changeFrame:keyboardSize.height];

//        [((UITableView*)[self withView:base tag:11]) withCell:@"E_Search_Cell"];
//
//        [((UITableView*)[self withView:base tag:11]) withCell:@"E_Empty_Music"];
//
//        ((UITableView*)[self withView:base tag:11]).delegate = self;
//
//        ((UITableView*)[self withView:base tag:11]).dataSource = self;
//
//        [self addSubview:base];
//
//        [((UIViewController*)dictInfo[@"host"]).view addSubview:self];
//
//        [((UITableView*)[self withView:base tag:11]) cellVisible];
        
        [UIView animateWithDuration:0.0 animations:^{
            
            CGRect frame = self.frame;

            frame.origin.y = gap;
            
            self.frame = frame;
            
            self.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            isOn = YES;
            
        }];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    if(time)
    {
        [time invalidate];
        
        time = nil;
    }
    
    if(isOn)
    {
        isOn = NO;
        
        [UIView animateWithDuration:0.0 animations:^{
            
            CGRect frame = self.frame;
            
            frame.origin.y = screenHeight1;
            
            self.frame = frame;
            
        } completion:^(BOOL finished) {
            
            self.onTapEvent(@{@"menu":self, @"state":@(0)});
            
            for(UIView * v in self.subviews)
            {
                [v removeFromSuperview];
            }
            
            [self removeFromSuperview];
            
            [self registerForKeyboardNotifications:NO andHost:self andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
            
            if(![dictInfo responseForKey:@"clearText"])
            {
                ((UITextField*)dictInfo[@"textField"]).text = @"";
            }
        }];
    }
}

- (void)closeMenu
{
    [(UITextField*)dictInfo[@"textField"] resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        ((UIView*)[self withView:((UIViewController*)dictInfo[@"host"]).view tag:9981]).alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [((UIView*)[self withView:((UIViewController*)dictInfo[@"host"]).view tag:9981]) removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : 44;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = (UITableViewCell*)[_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : @"E_Search_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = @"🔍";
        
        return cell;
    }
    
    NSDictionary * dict = dataList[indexPath.row];
    
    ((UILabel*)[self withView:cell tag:11]).text = [[dict getValueFromKey:@"type"] isEqualToString:@"point"] ? [dict getValueFromKey:@"text"] : [NSString stringWithFormat:@"Lô: %@ - Mã lô: %@", [dict getValueFromKey:@"text"], [dict getValueFromKey:@"code"]];
    
     return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        [self closeMenu];
        
        return;
    }
    
    [self closeMenu];
    
    self.onTapEvent(@{@"menu":self, @"char":dataList[indexPath.row], @"index":@(indexPath.row)});

    [self registerForKeyboardNotifications:NO andHost:self andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
}

@end
