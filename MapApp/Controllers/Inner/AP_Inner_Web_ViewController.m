//
//  AP_Inner_Web_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/17/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Inner_Web_ViewController.h"

@interface AP_Inner_Web_ViewController ()
{
    IBOutlet UIWebView * webView;
}

@end

@implementation AP_Inner_Web_ViewController

@synthesize info;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    if([info[@"type"] isEqualToString:@"0"])
    {
        [webView loadHTMLString:![info responseForKey:@"ten_lo"] ? [info getValueFromKey:@"description"] : [self html:[NSString stringWithFormat:@"Mã lô: %@ <br />Trạng thái: <font style=\"color:%@;\">%@</font><br />Diện tích: %@ m2<br />%@<br />%@", [info getValueFromKey:@"ki_hieu"], [self status:[info getValueFromKey:@"tinh_trang_id"]][@"color"], [self status:[info getValueFromKey:@"tinh_trang_id"]][@"status"], [info getValueFromKey:@"dien_tich"], [info getValueFromKey:@"description"], [info[@"info"] isEqualToString:@""] ? @"Trạng thái đang được cập nhật" : [[info getValueFromKey:@"info"] stringByReplacingOccurrencesOfString:@"/n"
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                withString:@"<br />"]]] baseURL:nil];
    }
    else 
    {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[info getValueFromKey:@"url_360"]]]];
    }
    
//    NSLog(@"%@", [info getValueFromKey:@"url_360"]);
}

- (NSDictionary*)status:(NSString*)statusId
{
    return @{@"color":[statusId isEqualToString:@"1"] ? @"Green" : [statusId isEqualToString:@"2"] ? @"Red" : @"Blue", @"status":[statusId isEqualToString:@"1"] ? @"Chưa bán" : [statusId isEqualToString:@"2"] ? @"Đã bán" : @"Đã đặt cọc"};
}

- (NSString*)html:(NSString*)text
{
    return [NSString stringWithFormat:@"<html>%@</html>", text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self showSVHUD:@"Đang tải" andOption:0];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideSVHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideSVHUD];
    
    [self showToast:@"Lỗi xảy ra, mời bạn thử lại" andPos:0];
}

@end
