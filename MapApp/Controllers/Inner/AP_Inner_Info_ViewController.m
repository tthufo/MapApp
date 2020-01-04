//
//  AP_Info_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 5/22/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Inner_Info_ViewController.h"

#import "AP_Web_ViewController.h"


@interface AP_Inner_Info_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
}
@end

@implementation AP_Inner_Info_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [@[@{@"name":@"Bảng hàng cập nhật mới nhất", @"link":@"https://goo.gl/f5KEQw"}, @{@"name":@"Giá - Chính sách giao dịch (CSBH)", @"link":@"https://goo.gl/EKqG8R"}, @{@"name":@"Phim Dự án + Ảnh thực tế:", @"link":@"https://goo.gl/icmKWm"}, @{@"name":@"Concept Design của dự án", @"link":@"https://goo.gl/c2qJsh"}, @{@"name":@"Mặt bằng QH-TK", @"link":@"https://goo.gl/RQTRXL"}, @{@"name":@"Tiến độ dự án", @"link":@"https://goo.gl/Jt4QnT"}, @{@"name":@"Mẫu hợp đồng", @"link":@"https://goo.gl/N3Na75"}, @{@"name":@"Tài liệu in ấn - Tờ gấp, Short Brochure", @"link":@"https://goo.gl/PTTKBq"}, @{@"name":@"File training dự án", @"link":@"https://goo.gl/iuFCQj"}] mutableCopy];
    
    [tableView withCell:@"E_Empty_Music"];
    
    [tableView withCell:@"E_Search_Cell"];
    
    [tableView cellVisible];
    
    [self didRequestForList];
}

- (void)didRequestForList
{
    NSDictionary * infoPlist = [self dictWithPlist:@"Info"];
    
    NSMutableDictionary * dict = [@{@"absoluteLink":[NSString stringWithFormat:@"%@/POint/lo/info/1", infoPlist[@"host"]],
                                    @"method":@"GET",
                                    @"host":self,
                                    @"overrideLoading":@(1),
                                    @"overrideAlert":@(1),
                                    } mutableCopy];
    
    [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        if(!responseString)
        {
            return;
        }
        
        if([errorCode isEqualToString:@"200"])
        {
//            [dataList removeAllObjects];
            
            //NSLog(@"%@", responseString);
            
//            if(((NSArray*)[responseString objectFromJSONString][@"array"]).count == 0)
//            {
//                [self showToast:@"Không tìm thấy kết quả" andPos:1];
//            }
//            else
//            {
//                [dataList addObjectsFromArray:[responseString objectFromJSONString][@"array"]];
//            }
        }
        
        [tableView cellVisible];
    }];
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
    
    NSString * url = dataList[indexPath.row][@"link"];
    
    [(AP_Web_ViewController*)self.parentViewController.parentViewController didOpenWeb:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
