//
//  AP_Inner_Gallery_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/17/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Inner_Gallery_ViewController.h"

@interface AP_Inner_Gallery_ViewController ()<MHFacebookImageViewerDatasource>
{
    IBOutlet UICollectionView * collectionView;

    NSMutableArray * dataList;
}

@end

@implementation AP_Inner_Gallery_ViewController

@synthesize info;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [@[] mutableCopy];
    
    if([info responseForKey:@"images"] && ![info[@"images"] isKindOfClass:[NSString class]])
    {
        [dataList addObjectsFromArray:info[@"images"]];
    }
    
    [collectionView withCell:@"AP_Gallery"];
    
    [collectionView withCell:@"E_Empty_Cell"];
    
    [collectionView cellVisible];
}

- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer*) imageViewer
{
    return dataList.count;
}

- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    return [NSURL URLWithString:dataList[index][@"image_path"]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    return [UIImage imageNamed:@""];
}

- (NSMutableDictionary*) inforImageAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    return [@{} mutableCopy];
}


#pragma CollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:dataList.count == 0 ? @"E_Empty_Cell" : @"AP_Gallery" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách trống";
        
        return cell;
    }
    
    [(UIImageView*)[self withView:cell tag:11] imageUrl:dataList[indexPath.item][@"image_path"]];
    
    [(UIImageView*)[self withView:cell tag:11] setupImageViewerWithDatasource:self andInfo:@{@"done":@{@"rect":NSStringFromCGRect(CGRectMake(10, 40, 40, 40)), @"img":@"back"}} initialIndex:indexPath.item onOpen:^{
        
    } onClose:^{
        
    }];
    
    return cell;
}

#pragma Collection

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? CGSizeMake(screenWidth1 - 10.0, _collectionView.frame.size.height) : CGSizeMake(((screenWidth1 - 0.0) / 3) - 10, ((screenWidth1 - 0.0) / 3) - 10);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
