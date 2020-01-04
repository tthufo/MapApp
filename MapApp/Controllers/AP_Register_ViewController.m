//
//  AP_Register_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/10/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Register_ViewController.h"

#define list @[@"Username",@"Password",@"Email",@"GivenName",@"PhoneNumber"]

@interface AP_Register_ViewController ()<UITextFieldDelegate>
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UIView * bottom, * top;
    
    NSMutableDictionary * info;
    
    NSMutableArray * dataList;
    
    KeyBoard * kb;
    
    IBOutlet NSLayoutConstraint * topBar;
}

@end

@implementation AP_Register_ViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableView withCell:@"AP_TextField_Cell"];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11"))
    {
        topBar.constant = 44;
    }
    
    dataList = [@[@{@"Username":[@{@"Username":@"Tên đăng nhập", @"content":@""} mutableCopy]},
                  @{@"Password":[@{@"Password":@"Mật khẩu", @"content":@""} mutableCopy]},
                  @{@"Email":[@{@"Email":@"Email", @"content":@""} mutableCopy]},
                  @{@"GivenName":[@{@"GivenName":@"Biệt danh", @"content":@""} mutableCopy]},
                  @{@"PhoneNumber":[@{@"PhoneNumber":@"Số điện thoại", @"content":@""} mutableCopy]}] mutableCopy];
    
    info = [@{@"Username":[@{@"Username":@"Tên đăng nhập", @"content":@""} mutableCopy],
                  @"Password":[@{@"Password":@"Mật khẩu", @"content":@""} mutableCopy],
                  @"Email":[@{@"Email":@"Email", @"content":@""} mutableCopy],
                  @"GivenName":[@{@"GivenName":@"Biệt danh", @"content":@""} mutableCopy],
              @"PhoneNumber":[@{@"PhoneNumber":@"Số điện thoại", @"content":@""} mutableCopy]} mutableCopy];
    
    [tableView actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self.view endEditing:YES];
    }];
    
    [self.view actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self.view endEditing:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    kb = [[KeyBoard shareInstance] keyboardOn:@{} andCompletion:^(CGFloat kbHeight, BOOL isOn) {
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, isOn ? kbHeight : 0, 0);
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [kb keyboardOff];
}

- (IBAction)didPressRegister:(id)sender
{
    [self.view endEditing:YES];
    
    if(![self isValid])
    {
        [self showToast:@"Bạn phải nhập đủ thông tin đăng ký" andPos:0];
        
        return;
    }
    
    [self didRequestRegister];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isValid
{
    BOOL found = YES;
    
    BOOL email = YES;

    for(NSDictionary * dict in info.allValues)
    {
        if([(NSString*)dict[@"content"] isEqualToString:@""])
        {
            found = NO;
            
            break;
        }
        
        for(NSString * key in dict)
        {
            if([key isEqualToString:@"Email"])
            {
                email = [dict[@"content"] isEmail];
                
                break;
            }
        }
    }
    
    return found && email;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField_ shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * data = [textField_.text stringByReplacingCharactersInRange:range withString:string];

    NSString * name = textField_.accessibilityLabel;
    
    info[name][@"content"] = data;
    
    return YES;
}

- (void)didRequestRegister
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"account/MobileRegister",
                                                 @"Username":info[@"Username"][@"content"],
                                                 @"Password":info[@"Password"][@"content"],
                                                 @"Email":info[@"Email"][@"content"],
                                                 @"GivenName":info[@"GivenName"][@"content"],
                                                 @"PhoneNumber":info[@"PhoneNumber"][@"content"],
                                                 @"overrideLoading":@(1),
                                                 @"host":self,
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"account/MobileRegister"
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(![errorCode isEqualToString:@"200"])
                                                     {
                                                         [self showToast:@"Đăng ký thất bại, mời bạn thử lại" andPos:0];
                                                     }
                                                     else
                                                     {
                                                         [self.navigationController popViewControllerAnimated:YES];
                                                         
                                                         if(delegate && [delegate respondsToSelector:@selector(didUpdateData:)])
                                                         {
                                                             [delegate didUpdateData:@{@"uname":info[@"Username"][@"content"],@"pass":info[@"Password"][@"content"]}];
                                                         }
                                                         
                                                         [self showToast:@"Đăng ký thành công" andPos:0];
                                                     }
                                                 }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 70;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return bottom;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AP_TextField_Cell" forIndexPath:indexPath];

    NSString * name = list[indexPath.row];
    
    UITextField * txtField = ((UITextField*)[self withView:cell tag:11]);
    
    txtField.placeholder = info[name][name];
    
    txtField.accessibilityLabel = name;
    
    txtField.delegate = self;
    
    txtField.keyboardType = indexPath.row == 4 ? UIKeyboardTypePhonePad : indexPath.row == 2 ? UIKeyboardTypeEmailAddress : UIKeyboardTypeDefault;
    
    txtField.secureTextEntry = indexPath.row == 1;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

@implementation NSObject (X)

- (BOOL)isIphoneX
{
//    BOOL iphoneX = NO;
//    if #available(iOS 11.0, *)
//    {
//        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
//        if (mainWindow.safeAreaInsets.top > 0.0)
//        {
//            iphoneX = YES;
//        }
//    }
    
    return NO;
}

@end

