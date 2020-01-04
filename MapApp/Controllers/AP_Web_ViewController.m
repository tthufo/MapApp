//
//  AP_Web_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/12/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Web_ViewController.h"

#import "AP_Web_List_ViewController.h"

#import "AP_Inner_Web_ViewController.h"

#import "AP_Inner_Gallery_ViewController.h"

#import "AP_Inner_Video_ViewController.h"

#import "AP_Inner_Info_ViewController.h"

@interface AP_Web_ViewController ()<ViewPagerDataSource, ViewPagerDelegate>
{
    IBOutlet NSLayoutConstraint * topBar;
    
    NSArray *tabsName;
    
    NSMutableArray * controllers;
    
    IBOutlet UILabel * titleLabel;
    
    IBOutlet UIImageView * left, * right;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation AP_Web_ViewController

@synthesize info;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"___%@", info);
    
    titleLabel.text = [info responseForKey:@"ten_lo"] ? [NSString stringWithFormat:@"Lô %@", info[@"ten_lo"]] : [info responseForKey:@"text"] ? info[@"text"] : info[@"name_en"];
        
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11"))
    {
        topBar.constant = 44;
        
        self.topHeight = [self isIphoneX] ? @"88" : @"64";
    }
    else
    {
        self.topHeight = @"64";
    }
    
    self.dataSource = self;
    
    self.delegate = self;
    
    tabsName = @[@"Thông tin", @"Ảnh tiến độ", @"Video", @"Danh sách", @"Video 360"];
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(int i = 0; i < tabsName.count; i++)
    {
        [arr addObject:[NSString stringWithFormat:@"%f", (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) ? [[self modelLabel:i] sizeOfLabel].width + 5 : screenWidth1 / 4]];
    }
    
    self.offSetLeft = @"35";
    
    self.offSetRight = @"35";
    
    //if((IS_IPHONE_5 || IS_IPHONE_4_OR_LESS))
    {
        self.arr = arr;
    }
    
    
    AP_Inner_Web_ViewController * web = [AP_Inner_Web_ViewController new];
    
    NSMutableDictionary * webInfo = [[NSMutableDictionary alloc] initWithDictionary:self.info];
    
    webInfo[@"type"] = @"0";
    
    web.info = webInfo;;
    
    
    
    AP_Inner_Gallery_ViewController * gallery = [AP_Inner_Gallery_ViewController new];
    
    gallery.info = self.info;

    
    AP_Inner_Video_ViewController * video = [AP_Inner_Video_ViewController new];
    
    video.info = self.info;

    
    AP_Inner_Web_ViewController * link = [AP_Inner_Web_ViewController new];

    NSMutableDictionary * linkInfo = [[NSMutableDictionary alloc] initWithDictionary:self.info];
    
    linkInfo[@"type"] = @"1";
    
    link.info = linkInfo;

    AP_Inner_Info_ViewController * info = [AP_Inner_Info_ViewController new];
    
    controllers = [@[web, gallery, video, info, link] mutableCopy];
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
    
    [left actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self selectTabAtIndex:[self.indexSelected integerValue] - 1];
    }];
    
    [right actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self selectTabAtIndex:[self.indexSelected integerValue] + 1];
    }];
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    for(UIView * v in viewPager.tabsView.subviews)
    {
        for(UIView * tab in v.subviews)
        {
            if([tab isKindOfClass:[UILabel class]])
            {
                ((UILabel*)tab).textColor = [viewPager.tabsView.subviews indexOfObject:v] == index ? [UIColor whiteColor] : [UIColor darkGrayColor];
            }
        }
    }
    
    self.indexSelected = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    
    left.userInteractionEnabled = index != 0;
    right.userInteractionEnabled = index != 4;
    
    left.alpha = index == 0 ? 0.4 : 1;
    right.alpha = index == 4 ? 0.4 : 1;
}
#pragma mark - Setters
- (void)setNumberOfTabs:(NSUInteger)numberOfTabs
{
    _numberOfTabs = numberOfTabs;
    
    [self reloadData];
}

#pragma mark - Helpers
- (void)loadContent
{
    self.numberOfTabs = [tabsName count];
}

#pragma mark - Interface Orientation Changes
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self performSelector:@selector(setNeedsReloadOptions) withObject:nil afterDelay:duration];
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
    return self.numberOfTabs;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    return [self modelLabel:index];
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{
    UIViewController * control = controllers[index];
    
    return control;
}

- (void)didOpenWeb:(NSString*)url
{
    AP_Web_List_ViewController * ap = [AP_Web_List_ViewController new];
    
    ap.url = url;
    
    [self.navigationController pushViewController:ap animated:YES];
}

- (UILabel*)modelLabel:(NSUInteger)index
{
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    [self boldFontForLabel:label];
    label.text = tabsName[index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    [label sizeToFit];
    return label;
}

#pragma mark - ViewPagerDelegate

- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case ViewPagerOptionStartFromSecondTab:
            return 0;
        case ViewPagerOptionCenterCurrentTab:
            return 0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 35.0;
        case ViewPagerOptionTabOffset:
            return 0;
        case ViewPagerOptionTabWidth:
            return ((self.view.frame.size.width) / 5) + 10;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color
{
    switch (component)
    {
        case ViewPagerIndicator:
            return [UIColor orangeColor];
        case ViewPagerTabsView:
            return [UIColor colorWithRed:207.0/255.0 green:209.0/255.0 blue:211.0/255.0 alpha:1];
        case ViewPagerContent:
            [[UIColor blueColor] colorWithAlphaComponent:1];
        default:
            return color;
    }
}

-(void)boldFontForLabel:(UILabel *)label
{
    UIFont *currentFont = label.font;
    UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) ? 15 : 15];
    label.font = newFont;
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
