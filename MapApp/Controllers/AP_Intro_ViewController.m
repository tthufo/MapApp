//
//  AP_Intro_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/19/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Intro_ViewController.h"

@interface AP_Intro_ViewController ()
{
    IBOutlet NSLayoutConstraint * topBar;
    
    IBOutlet UIWebView * webView;
    
    IBOutlet UITextView * textView;
}

@end

@implementation AP_Intro_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11"))
    {
        topBar.constant = 44;
    }
    
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://3dart.vn/#gioi-thieu"]]];
    
    NSError *error;
    NSString *strFileContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                                   pathForResource: @"text" ofType: @"txt"] encoding:NSUTF8StringEncoding error:&error];
    
    if(error)
    {
        
    }
    
    //NSLog(@"File content : %@ ", strFileContent);
    
    textView.text = strFileContent;
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
