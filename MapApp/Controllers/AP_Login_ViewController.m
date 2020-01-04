//
//  AP_Login_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/9/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Login_ViewController.h"

#import "AP_Map_ViewController.h"

#import "AP_Register_ViewController.h"

@interface AP_Login_ViewController ()<RegisterDelegate>
{
    IBOutlet UITextField * uName, * pass;
    
    IBOutlet UIButton * check;
}

@end

@implementation AP_Login_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(![self getValue:@"check"])
    {
        [self addValue:@"1" andKey:@"check"];
    }

    [check setImage:[UIImage imageNamed: [[self getValue:@"check"] isEqualToString:@"1"] ? @"on" : @"off"] forState:UIControlStateNormal];
    
    [self.view actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self.view endEditing:YES];
    }];
    
    if([[self getValue:@"check"] isEqualToString:@"1"])
    {
        uName.text = [self getValue:@"name"];
        
        pass.text = [self getValue:@"pass"];
        
        if([self getValue:@"name"] && [self getValue:@"pass"] && ![[self getValue:@"name"] isEqualToString:@""] && ![[self getValue:@"pass"] isEqualToString:@""])
        {
            [self didRequestLogin];
        }
    }
    
    [self didGoToMap];
    
    [self didRequestLayerList];
}

- (IBAction)didPressCheck:(UIButton*)sender
{
    [self addValue:[[self getValue:@"check"] isEqualToString:@"1"] ? @"0" : @"1" andKey:@"check"];

    [sender setImage:[UIImage imageNamed: [[self getValue:@"check"] isEqualToString:@"1"] ? @"on" : @"off"] forState:UIControlStateNormal];
}

//"Username": "testios",
//"Password": "123456"

- (IBAction)didPressLogIn:(id)sender
{
    [self.view endEditing:YES];
    
    if(![self isValid])
    {
        [self showToast:@"Bạn phải nhập đầy đủ thông tin đăng nhập" andPos:0];
        
        return;
    }
    
    [self didRequestLogin];
}

- (IBAction)didPressRegister:(id)sender
{
    [self.view endEditing:YES];

    AP_Register_ViewController * reg = [AP_Register_ViewController new];
    
    reg.delegate = self;
    
    [self.navigationController pushViewController:reg animated:YES];
}

- (void)didUpdateData:(NSDictionary*)dict
{
    uName.text = dict[@"uname"];
    
    pass.text = dict[@"pass"];
}

- (void)didRequestLayerList
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"layer/list",
                                                 @"method":@"GET",
                                                 @"overrideAlert":@(1)
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if([errorCode isEqualToString:@"200"])
                                                     {
                                                         [ObjectInfo shareInstance].tiles = [responseString objectFromJSONString][@"array"];
                                                     }
                                                     
//                                                     NSLog(@"%@", [ObjectInfo shareInstance].tiles);
                                                 }];
}

- (void)didRequestLogin
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"account/Token",
                                                 @"Username":uName.text,
                                                 @"Password":pass.text,
                                                 @"overrideLoading":@(1),
                                                 @"host":self,
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"account/Token"
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     switch ([errorCode intValue]) {
                                                         case 200:
                                                         {
//                                                             [self showToast:@"Đăng nhập thành công" andPos:0];
                                                                                                                          
                                                             [ObjectInfo shareInstance].uInfo = [responseString objectFromJSONString][@"user_info"];
                                                             
                                                             [ObjectInfo shareInstance].token = [responseString objectFromJSONString][@"access_token"];
                                                             
                                                             if([[self getValue:@"check"] isEqualToString:@"1"])
                                                             {
                                                                 [self addValue:uName.text andKey:@"name"];
                                                                 
                                                                 [self addValue:pass.text andKey:@"pass"];
                                                             }
                                                             else
                                                             {
                                                                 [self removeValue:@"name"];
                                                                 
                                                                 [self removeValue:@"pass"];
                                                             }
                                                             
                                                           //  [self didGoToMap];
                                                             
                                                             [self.navigationController pushViewController:[AP_Map_ViewController new] animated:YES];
                                                         }
                                                         
                                                         break;
                                                         
                                                         case 401:
                                                         {
                                                             [self showToast:@"Đăng nhập thất bại, sai thông tin tài khoản" andPos:0];
                                                         }
                                                         
                                                         break;
                                                         
                                                         case 403:
                                                         {
                                                             [self showToast:@"Đăng nhập thất bại, tài khoản hiện tạm bị khóa" andPos:0];
                                                         }
                                                         
                                                         break;
                                                         
                                                         default:
                                                         {
                                                             [self showToast:@"Đăng nhập không thành công, mời bạn thử lại" andPos:0];
                                                         }
                                                         break;
                                                     }
                                                 }];
}

- (BOOL)isValid
{
    return [uName hasText] && [pass hasText];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didGoToMap
{
    [[Permission shareInstance] initLocation:NO andCompletion:^(LocationPermisionType type) {
        switch (type) {
            case lAlways:
            {
                //[self.navigationController pushViewController:[AP_Map_ViewController new] animated:YES];
            }
            break;
            case lDenied:
            {
                [self showToast:@"Bản đồ cần sử dụng vị trí của bạn" andPos:0];
            }
            break;
            case lDisabled:
            {
                [self showToast:@"Bản đồ cần sử dụng vị trí của bạn" andPos:0];
            }
            break;
            case lWhenUse:
            {
                //[self.navigationController pushViewController:[AP_Map_ViewController new] animated:YES];
            }
            break;
            case lRestricted:
            {
                [self showToast:@"Bản đồ cần sử dụng vị trí của bạn" andPos:0];
            }
            break;
            case lNotSure:
            {
                
            }
            break;
            
            default:
            break;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
