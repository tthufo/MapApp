//
//  AP_Web_List_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 5/23/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Web_List_ViewController.h"

@interface AP_Web_List_ViewController ()
{
    IBOutlet NSLayoutConstraint * topBar;

    IBOutlet UIWebView * webView;
}
@end

@implementation AP_Web_List_ViewController

@synthesize url;

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11"))
    {
        topBar.constant = 44;
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
