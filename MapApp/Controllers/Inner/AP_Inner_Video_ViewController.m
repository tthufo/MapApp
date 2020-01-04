//
//  AP_Inner_Video_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/17/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Inner_Video_ViewController.h"

@interface AP_Inner_Video_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
}

@end

@implementation AP_Inner_Video_ViewController

@synthesize info;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [@[] mutableCopy];
    
    if([info responseForKey:@"videos"] && ![info[@"videos"] isKindOfClass:[NSString class]])
    {
        [dataList addObjectsFromArray:info[@"videos"]];
    }
    
    [tableView withCell:@"E_Empty_Music"];
    
    [tableView withCell:@"E_Search_Cell"];
    
    [tableView cellVisible];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? tableView.frame.size.height : 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier: dataList.count == 0 ? @"E_Empty_Music" : @"E_Search_Cell"];
    
    if (!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][2];
    }
    
    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách trống";
        
        return cell;
    }
    
//    [(UILabel*)[self withView:cell tag:11] setText:dataList[indexPath.row][@"layer_name"]];
    
    [(UILabel*)[self withView:cell tag:11] setText:dataList[indexPath.row][@"name"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        return;
    }
    
    NSString * url = dataList[indexPath.row][@"video_path"];
    
//    NSString * url = @"http://techslides.com/demos/sample-videos/small.mp4";

    //NSString * url = @"https://www.youtube.com/watch?v=lqVrILu61Is";
    
    if([url myContainsString:@"youtube"])
    {
        [self showSVHUD:@"Đang tải" andOption:0];
        
        NSString * ident = [[[[[[url componentsSeparatedByString:@"//"] lastObject] componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"="] lastObject];
        
        //NSLog(@"%@", ident);
        
        [[YouTube share] returnUrl:ident andCompletion:^(int index, NSDictionary *info) {
            
            [self hideSVHUD];
            
            if(index != 0)
            {
                [self alert:@"Thông báo" message:@"Video đang được cập nhật, mời bạn thử lại sau"];
                
                return;
            }
            
            if(index == 0)
            {
                MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:info[@"url"]];
                
                [self presentViewController:player animated:YES completion:^{
                    
                }];
                
                [player.moviePlayer prepareToPlay];
                
                [player.moviePlayer play];
            }
            
        }];
    }
    else
    {
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[url encodeUrl]]];
        
        [self presentViewController:player animated:YES completion:^{
            
        }];
        
        [player.moviePlayer prepareToPlay];
        
        [player.moviePlayer play];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
