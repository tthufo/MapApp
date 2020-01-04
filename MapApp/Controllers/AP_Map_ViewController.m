//
//  AP_Map_ViewController.m
//  MapApp
//
//  Created by Thanh Hai Tran on 4/10/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

#import "AP_Map_ViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import "AP_Web_ViewController.h"

#import "AP_Intro_ViewController.h"

#import "GMUGeoJSONParser.h"

#import "GMUGeometryRenderer.h"

#import "GMUFeature.h"

@interface AP_Map_ViewController ()<GMSMapViewDelegate>
{
    IBOutlet UIImageView * hand;
    
    IBOutlet UIView * top, * bar;
    
    IBOutlet UITextField * search;
    
    IBOutlet NSLayoutConstraint * topBar;
    
    NSMutableArray * dataList, * dataPoly;
    
    NSArray * sign;
    
    IBOutlet GMSMapView * mapView;
    
    IBOutlet DropButton * menu;
    
    BOOL isStreet, isShow, isEnable;
    
    IBOutlet UIButton * changeMap, * menuMap;
    
    GMSMarker * mainMarker, * searchMarker, * polyMarker, * layerMarker;
    
    GMSURLTileLayer *layer;
    
    GMUGeometryRenderer *renderer, *rendererAll;
    
    GMUGeoJSONParser *parser, *parserAll;
    
    KeyBoard * kb;
    
    NSString * uniqueID;
    
    NSTimer * time;
    
    UIActivityIndicatorView * indicator;
    
    BOOL isOn;
    
    GMSPolygon *polyline;
}

@end

@implementation AP_Map_ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    //    kb = [[KeyBoard shareInstance] keyboardOn:@{@"bar":bar, @"host":self} andCompletion:^(CGFloat kbHeight, BOOL isOn) {
    //
    //        //dipdid[self hideShowSearch:isOn];
    //
    //        [menuMap setEnabled:!isOn];
    //
    //    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
    
    //[kb keyboardOff];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11"))
    {
        topBar.constant = [self isIphoneX] ? 3 : 20;
    }
    
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    
    indicator.transform = CGAffineTransformMakeScale(1.75, 1.75);
    
    [indicator hidesWhenStopped];
    
    [indicator stopAnimating];
    
    [indicator setColor:[UIColor blackColor]];
    
    [mapView addSubview:indicator];
    
    isStreet = YES;
    
    uniqueID = @"";
    
    isShow = [self getObject:@"setting"];
    
    dataList = [@[] mutableCopy];
    
    dataPoly = [@[] mutableCopy];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self lat]
                                                            longitude:[self lng]
                                                                 zoom:15];

    mapView.camera = camera;
    
    mapView.delegate = self;
    
    
    
//    [mapView setMinZoom:15 maxZoom:22];
    
    
    
    NSDictionary * dict = nil;

    if([self getObject:@"setting"])
    {
        dict = [self getObject:@"setting"];
    }
    else
    {
        dict = @{@"date":[[NSDate date] stringWithFormat:@"dd/MM/yyyy"], @"gender":@"0", @"show":@"0"};
    }
    
    [self didSetDate:[self getDateFromDateString:dict[@"date"]] andGender:dict[@"gender"]];
    
    if(isShow)
    {
        [changeMap setImage:[UIImage imageNamed:[dict[@"show"] boolValue] ? @"ic_off_compass_zodiac" : @"ic_show_compass_zodiac"] forState:UIControlStateNormal];
    }
    else
    {
        [changeMap setImage:[UIImage imageNamed:@"ic_show_compass_zodiac"] forState:UIControlStateNormal];
    }

    

    [[Permission shareInstance] didReturnHeading:^(float magneticHeading, float trueHeading) {
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation(DegreesToRadians(-magneticHeading));
        
        [hand setTransform:rotate];
        
        if(isShow)
        {
            [self didChangeAngle:magneticHeading];
        }
        
        if([[self getObject:@"setting"][@"show"] boolValue])
        {
            [mapView animateToBearing:-trueHeading];
        }
        
//        mainMarker.rotation = -trueHeading;
    }];
    
    
    [self didRequestForPoints];
    
    
    [menu actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self.view endEditing:YES];
        
        [[[EM_MenuView alloc] initWithMenu:@{}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
            switch (index) {
                case 0:
                {
                    [self.navigationController pushViewController:[AP_Intro_ViewController new] animated:YES];
                }
                    break;
                case 1:
                {
                    exit(0);
                }
                    break;
                case 2:
                {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    [self removeObject:@"setting"];
                }
                    break;
                case 3:
                {
                    [self didPressDate];
                }
                    break;
                default:
                    break;
            }
        }];
    }];
    
    
    [self didRender:@"" andLat:0 andLng:0 andInfo:@""];
    
    [self currentMaker:[self lat] andLong:[self lng]];
    
    
    
    CGRect rect = bar.frame;
    
    rect.size.width = screenWidth1;
    
    rect.origin.y = screenHeight1 ;
    
    rect.origin.x = 0;
    
    bar.frame = rect;
    
    [self.view addSubview:bar];
    
    
    
//    [self registerForKeyboardNotifications:YES andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
//
//    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(didChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(didEndFrame:) name:UIKeyboardDidHideNotification object:nil];
}

//- (void)didChangeFrame:(NSNotification *)notification
//{
//    if(!isOn)
//    {
//        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//
//        NSLog(@"_____%f", keyboardSize.height);
//
//        CGRect rect = bar.frame;
//
//        rect.origin.y = screenHeight1 - (keyboardSize.height + rect.size.height);
//
//        bar.frame = rect;
//
////    isOn = YES;
//    }
//}

//- (void)keyboardWasShown:(NSNotification *)notification
//{
//    if(!isOn)
//    {
//        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//
//        CGRect rect = bar.frame;
//
//        rect.origin.y -= keyboardSize.height + rect.size.height - 40;
//
//        NSLog(@"%f", keyboardSize.height);
//
//        bar.frame = rect;
//
//        isOn = YES;
//    }
//}

//- (void)keyboardWillBeHidden:(NSNotification *)notification
//{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//
//    CGRect rect = bar.frame;
//
//    rect.origin.y = [self screenHeight];
//
//    bar.frame = rect;
//
//    isOn = NO;
//
//    isOn = YES;
//}
//
//- (void)didEndFrame:(NSNotification *)notification
//{
////    if(isOn)
////    {
//        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//
//        CGRect rect = bar.frame;
//
//        rect.origin.y = [self screenHeight];
//
//        bar.frame = rect;
//
//        isOn = NO;
////    }
//}

- (void)getAreaInfo
{
    if(time)
    {
        [time invalidate];
        
        time = nil;
    }
    
    time = [NSTimer scheduledTimerWithTimeInterval: 0.8 target:self selector:@selector(didRequestForAreaInfo) userInfo:nil repeats: NO];
}

- (NSDate *)getDateFromDateString:(NSString *)dateString
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

- (void)didGotoPosition:(float)lat andLong:(float)lng andZoom:(float)zoom
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lng
                                                                 zoom:zoom];
    [mapView animateToCameraPosition:camera];
}

- (void)didAddLayerTile
{
    NSDictionary * infoPlist = [self dictWithPlist:@"Info"];
    
    GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {
        
        int cor = pow(2, zoom) - 1 - y;
        
        //http://103.7.41.156:4231/wms.ashx?z=%lu&x=%lu&y=%lu&layer=%@"
        
        NSString *url = [NSString stringWithFormat:@"%@/wms.svc?z=%lu&x=%lu&y=%lu&layer=%@", infoPlist[@"host"],
                        (unsigned long)zoom, (unsigned long)x, (unsigned long)cor, uniqueID];
        
        return [NSURL URLWithString:url];
    };

    layer = [GMSURLTileLayer tileLayerWithURLConstructor:urls];

    layer.zIndex = -1;
}

- (void)didRender:(NSString*)geoJson andLat:(float)lat andLng:(float)lng andInfo:(NSString*)info
{
    NSData* data = [geoJson dataUsingEncoding:NSUTF8StringEncoding];

    if(parser)
    {
        parser = nil;
    }

    parser = [[GMUGeoJSONParser alloc] initWithData:data];

    [parser parse];

    if(renderer)
    {
        [renderer clear];

        renderer = nil;
    }

    renderer = [[GMUGeometryRenderer alloc] initWithMap:mapView
                                             geometries:parser.features];
    [renderer render];
    
//    NSString * geo = geoJson;//obj[@"geojson"];
//
//    NSDictionary * cors = [geo objectFromJSONString];
//
//    NSMutableArray * points = [NSMutableArray new];
//
//    for(NSArray * arr in cors[@"coordinates"][0][0])
//    {
//        NSDictionary * point = @{@"lat":arr[0], @"lng":arr[1]};
//
//        [points addObject:point];
//    }
//
//    GMSMutablePath *path = [GMSMutablePath path];
//
//    for(NSDictionary * dict in points)
//    {
//        [path addCoordinate:CLLocationCoordinate2DMake([dict[@"lng"] floatValue], [dict[@"lat"] floatValue])];
//    }
//
//    if(polyline)
//    {
//        polyline.map = nil;
//
//        polyline = nil;
//    }
//
//    polyline = [GMSPolygon polygonWithPath:path];
//
//    polyline.fillColor = [UIColor colorWithRed:255 green:204 blue:0 alpha:0.7];
//
//    polyline.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//
//    polyline.strokeWidth = 3;
//
//
//    polyline.map = mapView;
    
    
    
    if(![geoJson isEqualToString:@""])
    {
        [self didGotoPosition:lat andLong:lng andZoom:20];
    }
    
    if(polyMarker)
    {
        polyMarker.map = nil;
        
        polyMarker = nil;
    }
    
    polyMarker = [[GMSMarker alloc] init];
    polyMarker.position =  CLLocationCoordinate2DMake(lat, lng);
    polyMarker.accessibilityLabel = info;
    polyMarker.icon = [UIImage imageNamed:@"trans"];
    polyMarker.map = mapView;
    polyMarker.tappable = NO;
    mapView.selectedMarker = polyMarker;
}

- (void)didRequestPositionInfo:(NSString*)loId andLat:(float)lat andLng:(float)lng
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":[NSString stringWithFormat:@"point/lo/info/%@", loId],
                                                 @"overrideAlert":@(1),
                                                 @"method":@"GET"
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if([errorCode isEqualToString:@"200"])
                                                     {
                                                         NSString * loInfo = responseString;

                                                         [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":[NSString stringWithFormat:@"point/lo/geojson/%@", [responseString objectFromJSONString][@"gid"]],
                                                                                                      @"overrideAlert":@(1),
                                                                                                      @"method":@"GET"
                                                                                                      } withCache:^(NSString *cacheString) {

                                                                                                      } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {

                                                                                                          if([errorCode isEqualToString:@"200"])
                                                                                                          {
                                                                                                              [self didRender:responseString andLat:lat andLng:lng andInfo:loInfo];                                                                                   }
                                                                                                      }];
                                                     }
                                                     
                                                 }];
}

- (void)didRequestForAreaInfo
{
    if([[self getObject:@"setting"][@"show"] boolValue])
    {
        return;
    }
    
    if(mapView.camera.zoom >= 18)
    {
        CLLocationCoordinate2D topRight = [mapView.projection visibleRegion].farRight;
        
        CLLocationCoordinate2D bottomLeft = [mapView.projection visibleRegion].nearLeft;

        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"point/lo/inbound",
                                                     @"xmin":@(bottomLeft.longitude),
                                                     @"xmax":@(topRight.longitude),
                                                     @"ymin":@(bottomLeft.latitude),
                                                     @"ymax":@(topRight.latitude),
                                                     @"layer":uniqueID,
                                                     @"overrideAlert":@(1),
                                                     @"postFix":@"point/lo/inbound",
//                                                     @"host":self,
//                                                     @"overrideLoading":@(1)
                                                     } withCache:^(NSString *cacheString) {
                                                         
                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                         
                                                         [self hideSVHUD];
                                                         
                                                         if(!responseString)
                                                         {
                                                             return;
                                                         }
                                                         
                                                         if([errorCode isEqualToString:@"200"])
                                                         {
                                                             [self clearPolygon];
                                                             
                                                             NSArray * array = [responseString objectFromJSONString][@"array"];
                                                             
//                                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                                                                 for(NSDictionary * obj in array)
                                                                 {
                                                                     NSString * geo = obj[@"geojson"];
                                                                     
                                                                     NSDictionary * cors = [geo objectFromJSONString];
                                                                     
                                                                     NSMutableArray * points = [NSMutableArray new];
                                                                     
                                                                     for(NSArray * arr in cors[@"coordinates"][0][0])
                                                                     {
                                                                         NSDictionary * point = @{@"lat":arr[0], @"lng":arr[1]};
                                                                         
                                                                         [points addObject:point];
                                                                     }

                                                                     GMSMutablePath *path = [GMSMutablePath path];
                                                                     
                                                                     for(NSDictionary * dict in points)
                                                                     {
                                                                         [path addCoordinate:CLLocationCoordinate2DMake([dict[@"lng"] floatValue], [dict[@"lat"] floatValue])];
                                                                     }
                                                                     
                                                                     GMSPolygon *polyline = [GMSPolygon polygonWithPath:path];
                                                                     polyline.strokeWidth = 3;
                                                                     polyline.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                                                                     
                                                                     NSString * condition = [obj getValueFromKey:@"tinh_trang_id"];
                                                                     
                                                                     [polyline setFillColor:[condition isEqualToString:@"1"] ? [UIColor colorWithRed:0 green:255 blue:0 alpha:0.8] : [condition isEqualToString:@"2"] ? [UIColor colorWithRed:255 green:0 blue:0 alpha:0.8] : [UIColor colorWithRed:0 green:0 blue:255 alpha:0.8]];
                                                                     
                                                                     polyline.zIndex = -1;
                                                                     
                                                                     polyline.map = mapView;
                                                                     
                                                                     [dataPoly addObject:polyline];
                                                                 }
                                                                 
//                                                                 dispatch_async(dispatch_get_main_queue(), ^{
//                                                                     for(GMSPolygon * poly in dataPoly)
//                                                                     {
//                                                                         poly.map = mapView;
//                                                                     }
//                                                                 });
//                                                             });
                                                         }
                                                     }];
    }
    else
    {
        [self clearPolygon];
    }
}

- (void)clearPolygon
{
    for(GMSPolygon __strong * path in dataPoly)
    {
        path.map = nil;
        
        path = nil;
    }
    
    [dataPoly removeAllObjects];
}

- (void)didRequestArea:(float)lat andLng:(float)lng
{
    [renderer clear];
    
//    polyline.map = nil;
    
    //NSLog(@"%@",@"render");
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"point/lo",
                                                 @"lat":@(lat),
                                                 @"lng":@(lng),
                                                 @"overrideAlert":@(1),
//                                                 @"host":self,
//                                                 @"overrideLoading":@(1),
                                                 @"postFix":@"point/lo"
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [indicator stopAnimating];

                                                     [renderer clear];
                                                     
//                                                     polyline.map = nil;
                                                     
                                                     if([errorCode isEqualToString:@"200"])
                                                     {
                                                         [self didRequestPositionInfo:[responseString objectFromJSONString][@"gid"] andLat:lat andLng:lng];
                                                     }
                                                     else if([errorCode isEqualToString:@"204"])
                                                     {
                                                         
                                                     }
                                                     else
                                                     {
                                                         [self showToast:@"Lô bạn vừa chạm chưa có thông tin. Mời thử lại sau." andPos:0];
                                                         
                                                         [renderer clear];
                                                     }
                                                     
                                                     if(!responseString)
                                                     {
                                                         [renderer clear];
                                                     }
                                                 }];
}

- (void)didRequestUserTile
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":[NSString stringWithFormat:@"layer/user/%@", [ObjectInfo shareInstance].uInfo[@"id"]],
                                                 @"method":@"GET",
                                                 @"host":self,
                                                 @"overrideAlert":@(1),
                                                 @"overrideLoading":@(1)
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if([errorCode isEqualToString:@"200"])
                                                     {
                                                         [[[EM_MenuView alloc] initWithLayers:@{@"data":[responseString objectFromJSONString][@"array"], @"uID":uniqueID}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
                                                             
                                                             if(object)
                                                             {
                                                                 NSDictionary * info = object[@"data"];
                                                                 
                                                                 layer.map = nil;
                                                                 
                                                                 uniqueID = [uniqueID isEqualToString:@""] ? [info getValueFromKey:@"unique_name"] : [uniqueID isEqualToString:[info getValueFromKey:@"unique_name"]] ? @"" : [info getValueFromKey:@"unique_name"];
                                                                 
                                                                 layer.map = [uniqueID isEqualToString:@""] ? nil : mapView;

                                                                 if(![uniqueID isEqualToString:@""])
                                                                 {
                                                                     [self layerMarker:[[info getValueFromKey:@"lat"] floatValue] andLong:[[info getValueFromKey:@"lon"] floatValue] andInfo:info];
                                                                     
                                                                     [self didGotoPosition:[[info getValueFromKey:@"lat"] floatValue] andLong:[[info getValueFromKey:@"lon"] floatValue] andZoom:15];
                                                                     
                                                                     [self didRequestForAreaInfo];
                                                                 }
                                                                 else
                                                                 {
                                                                     [self showToast:@"Lớp layer đã tắt" andPos:0];
                                                                     
                                                                     if(layerMarker)
                                                                     {
                                                                         layerMarker.map = nil;
                                                                         
                                                                         layerMarker = nil;
                                                                     }
                                                                     
                                                                     [self clearPolygon];
                                                                 }
                                                             }
                                                             
                                                             [menu close];
                                                         }];
                                                     }
                                                     
                                                 }];
}

- (void)didChangeAngle:(float)heading
{
    NSString *geoDirectionString = [[NSString alloc] init];
    if(heading >=337.5 || heading <= 22.5){
        geoDirectionString = sign[0]; //@"1"; //Bắc
    } else if(heading >22.5 && heading <= 67.5){
        geoDirectionString = sign[1]; //@"6";    // Đông Bắc
    } else if(heading >67.5 && heading <= 112.5){
        geoDirectionString = sign[2]; //@"7";    //Đông
    } else if(heading >112.5 && heading <= 157.5){
        geoDirectionString = sign[3]; //@"4";   //Đông Nam
    } else if(heading >157.5 && heading <= 202.5){
        geoDirectionString = sign[4]; // @"5";   //Nam
    } else if(heading >202.5 && heading <= 247.5){
        geoDirectionString = sign[5]; // @"3";  // Tây Nam
    } else if(heading >248 && heading <= 293){
        geoDirectionString = sign[6]; // @"0";  //Tây
    } else if(heading >247.5 && heading <= 337.5){
        geoDirectionString = sign[7]; // @"2"; //Tây Bắc
    }
    
    mainMarker.icon = [UIImage imageNamed:[[self getObject:@"setting"][@"show"] boolValue] ? geoDirectionString : @"blue"];
}

- (float)lat
{
    return  [[[Permission shareInstance] currentLocation][@"lat"] floatValue];
}

- (float)lng
{
    return [[[Permission shareInstance] currentLocation][@"lng"] floatValue];
}

- (void)currentMaker:(float)lat andLong:(float)lng
{
    mainMarker = [[GMSMarker alloc] init];
    mainMarker.position = CLLocationCoordinate2DMake(lat, lng);
    mainMarker.icon = [UIImage imageNamed:@"blue"];
    mainMarker.map = mapView;
}

- (void)layerMarker:(float)lat andLong:(float)lng andInfo:(NSDictionary*)info
{
    if(layerMarker)
    {
        layerMarker.map = nil;
        
        layerMarker = nil;
    }
    
    layerMarker = [[GMSMarker alloc] init];
    layerMarker.accessibilityLabel = [info bv_jsonStringWithPrettyPrint:YES];
    layerMarker.position = CLLocationCoordinate2DMake(lat, lng);
    layerMarker.title = @"";
    layerMarker.snippet = @"";
    layerMarker.map = mapView;
    
    mapView.selectedMarker = nil;
}

- (void)searchMaker:(float)lat andLong:(float)lng andInfo:(NSDictionary*)info
{
    if(searchMarker)
    {
        searchMarker.map = nil;
        
        searchMarker = nil;
    }
    
    searchMarker = [[GMSMarker alloc] init];
    searchMarker.accessibilityLabel = [info bv_jsonStringWithPrettyPrint:YES];
    searchMarker.position = CLLocationCoordinate2DMake(lat, lng);
    searchMarker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:255 green:255 blue:0 alpha:1]];
    searchMarker.title = @"";
    searchMarker.snippet = @"";
    searchMarker.map = mapView;
}

- (IBAction)didPressMap:(UIButton*)sender
{
    if(!isShow)
    {
        [self didShowDate];
    }
    else
    {
        [changeMap setImage:[UIImage imageNamed:![[self getObject:@"setting"][@"show"] boolValue] ? @"ic_off_compass_zodiac" : @"ic_show_compass_zodiac"] forState:UIControlStateNormal];
        
        NSMutableDictionary * dict = [[self getObject:@"setting"] reFormat];
        
        dict[@"show"] = [dict[@"show"] boolValue] ? @"0" : @"1";
        
        [self addObject:dict andKey:@"setting"];
        
        if([dict[@"show"] boolValue])
        {
            [self clearPolygon];
        }
        else
        {
            [self didRequestForAreaInfo];
        }
    }
}

- (IBAction)didPressDismiss:(UIButton*)sender
{
    bar.hidden = YES;
    
    [self.view endEditing:YES];
}

- (IBAction)didPressLocation:(UIButton*)sender
{
    mainMarker.position = CLLocationCoordinate2DMake([self lat], [self lng]);
    
    [self didGotoPosition:[self lat] andLong:[self lng] andZoom:15];
}

- (IBAction)didPressMapLayer:(UIButton*)sender
{
    [self didRequestUserTile];
}

- (IBAction)didPressMapType:(UIButton*)sender
{
    [sender setImage:[UIImage imageNamed: isStreet ? @"icon_vetinh" : @"icon_strees"] forState:UIControlStateNormal];
    
    mapView.mapType = isStreet ? 2 : 1;
    
    isStreet = !isStreet;
}

- (IBAction)didPressSearch:(UIButton*)sender
{
    [search becomeFirstResponder];
}

- (void)hideShowSearch:(BOOL)isShow
{
    [UIView animateWithDuration:0.3 animations:^{
        
        top.alpha = isShow;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didShowDate
{
    NSDictionary * dict = nil;
    
    if([self getObject:@"setting"])
    {
        dict = [self getObject:@"setting"];
    }
    else
    {
        dict = @{@"date":[[NSDate date] stringWithFormat:@"dd/MM/yyyy"], @"gender":@"0", @"show":@"0"};
    }
    
    [[[EM_MenuView alloc] initWithDate:@{@"date":dict[@"date"], @"gender":dict[@"gender"], @"show":dict[@"show"]}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
        
        if(object)
        {
            NSMutableDictionary * data = [@{@"date":object[@"date"], @"gender":object[@"gender"], @"show":dict[@"show"]}  mutableCopy];
            
            if(!isShow)
            {
                [changeMap setImage:[UIImage imageNamed:@"ic_off_compass_zodiac"] forState:UIControlStateNormal];
                
                data[@"show"] = @"1";
            }
            else
            {
                //data[@"show"] = [data[@"show"] boolValue] ? @"0": @"1";
            }
            
            [self addObject:data andKey:@"setting"];
            
            if([data[@"show"] boolValue])
            {
                [self clearPolygon];
            }
            else
            {
                [self didRequestForAreaInfo];
            }
            
            isShow = [self getObject:@"setting"];
            
            [self didSetDate:[self getDateFromDateString:object[@"date"]] andGender:object[@"gender"]];
            
            [[Permission shareInstance].locationManager stopUpdatingHeading];
            
            [[Permission shareInstance].locationManager startUpdatingHeading];
        }
    }];
}

- (void)didPressDate
{
    NSDictionary * dict = nil;
    
    if([self getObject:@"setting"])
    {
        dict = [self getObject:@"setting"];
    }
    else
    {
        dict = @{@"date":[[NSDate date] stringWithFormat:@"dd/MM/yyyy"], @"gender":@"0", @"show":@"0"};
    }
    
    [[[EM_MenuView alloc] initWithDate:@{@"date":dict[@"date"], @"gender":dict[@"gender"], @"show":dict[@"show"]}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
        
        if(object)
        {
            NSMutableDictionary * data = [@{@"date":object[@"date"], @"gender":object[@"gender"], @"show":dict[@"show"]}  mutableCopy];
            
            [self addObject:data andKey:@"setting"];
            
            isShow = [self getObject:@"setting"];
            
            [self didSetDate:[self getDateFromDateString:object[@"date"]] andGender:object[@"gender"]];
            
            [[Permission shareInstance].locationManager stopUpdatingHeading];
            
            [[Permission shareInstance].locationManager startUpdatingHeading];
        }
    }];
}

- (void)didSetDate:(NSDate*)date andGender:(NSString*)gender
{
    NSString *tempDigit = [date stringWithFormat:@"yyyy"] ;
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempDigit enumerateSubstringsInRange:[tempDigit rangeOfString:tempDigit]
                                  options:NSStringEnumerationByComposedCharacterSequences
                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                   [tempArray addObject:substring] ;
                               }] ;
    int sum = 0;
    
    for (NSString *string in tempArray)
    {
        sum += [string integerValue];
    }
    
    [self sign:sum % 9 andGender:gender];
}

- (void)sign:(int)numb andGender:(NSString*)gender
{
    // 0 : ngũ quỷ,
    
    // 1 : phục vị
    
    // 2 : lục sát
    
    // 3 : tuyệt maạng
    
    // 4 : họa hại
    
    //5 : sanh khí
    
    // 6: phước đức
    
    // 7: thiện y
    
    NSArray * signsMale = @[@[@"3", @"5", @"4", @"0", @"2", @"1", @"7", @"6"], // khôn
                        @[@"1", @"0", @"7", @"5", @"6", @"3", @"4", @"2"], //khảm
                        @[@"6", @"4", @"5", @"7", @"1", @"2", @"0", @"3"], //ly
                        @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7"], //cấn
                        @[@"4", @"6", @"3", @"2", @"0", @"7", @"1", @"5"], //đối
                        @[@"2", @"7", @"0", @"4", @"3", @"6", @"5", @"1"], //càn
                        @[@"3", @"5", @"4", @"0", @"2", @"1", @"7", @"6"], //khôn
                        @[@"5", @"3", @"6", @"1", @"7", @"0", @"2", @"4"], //tốn
                        @[@"7", @"2", @"1", @"6", @"5", @"4", @"3", @"0"] //chấn
                        ];

    NSArray * signsFemale = @[@[@"5", @"3", @"6", @"1", @"7", @"0", @"2", @"4"],
                              @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7"],
                              @[@"2", @"7", @"0", @"4", @"3", @"6", @"5", @"1"],
                              @[@"4", @"6", @"3", @"2", @"0", @"7", @"1", @"5"],
                              @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7"],
                              @[@"6", @"4", @"5", @"7", @"1", @"2", @"0", @"3"],
                              @[@"1", @"0", @"7", @"5", @"6", @"3", @"4", @"2"],
                              @[@"3", @"5", @"4", @"0", @"2", @"1", @"7", @"6"],
                              @[@"7", @"2", @"1", @"6", @"5", @"4", @"3", @"0"]
                              ];
                             
    sign = [gender isEqualToString:@"0"] ? signsMale[numb] : signsFemale[numb];
}

- (void)didRequestForPoints
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"point/list",
                                                 @"method":@"GET",
                                                 @"overrideLoading":@(1),
                                                 @"host":self,
                                                 @"overrideAlert":@(1)
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(![errorCode isEqualToString:@"200"])
                                                     {
                                                         [self showToast:@"Lỗi xảy ra, mời bạn thử lại sau" andPos:0];
                                                         
                                                         return ;
                                                     }
                                                                                                          
                                                     [dataList removeAllObjects];

                                                     [dataList addObjectsFromArray:[responseString objectFromJSONString][@"array"]];
                                                     
                                                     [self didLayoutPoints];
                                                 }];
}

- (void)didLayoutPoints
{
    for(NSDictionary * dict in dataList)
    {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([dict[@"y"] floatValue], [dict[@"x"] floatValue]);
        marker.title = [dict getValueFromKey:@"name"];
        marker.snippet = [dict getValueFromKey:@"description"];
        marker.map = mapView;
        marker.accessibilityLabel = [dict bv_jsonStringWithPrettyPrint:YES];
    }
    
    [self didAddLayerTile];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    bar.hidden = NO;
    
    [[E_Overlay_Menu shareMenu] didShowSearch:@{@"host":self, @"textField":search/*, @"clearText":@(0)*/} andCompletion:^(NSDictionary *actionInfo) {
                
        if([actionInfo responseForKey:@"state"])
        {
            CGRect rect = bar.frame;
            
            rect.origin.y = [actionInfo[@"state"] boolValue] ? (screenHeight1 - ([actionInfo[@"height"] intValue] + rect.size.height)) : screenHeight1;
            
            bar.frame = rect;
            
            [menuMap setEnabled:![actionInfo[@"state"] boolValue]];
        }
        else
        {
            NSDictionary * searchInfo = actionInfo[@"char"];
            
            if([searchInfo[@"type"] isEqualToString:@"point"])
            {
                [self searchMaker:[searchInfo[@"lat"] floatValue] + 0 andLong:[searchInfo[@"lng"] floatValue] andInfo:searchInfo];
                
                [self didGotoPosition:[searchInfo[@"lat"] floatValue] andLong:[searchInfo[@"lng"] floatValue] andZoom:15];
            }
            else
            {
                [self didRequestArea:[searchInfo[@"lat"] floatValue] andLng:[searchInfo[@"lng"] floatValue]];
            }
        }
        
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[E_Overlay_Menu shareMenu] endTimer];
    
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker;
{
    AP_Web_ViewController * web = [AP_Web_ViewController new];
    
    web.info = [[marker.accessibilityLabel objectFromJSONString] reFormat];
    
    [self.navigationController pushViewController:web animated:YES];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    mainMarker.position = coordinate;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    CGPoint locationInView = [mapView.projection pointForCoordinate:coordinate];
    
    //if(mapView.camera.zoom >= 18)
    {
        indicator.frame = CGRectMake(locationInView.x, locationInView.y, 20, 20);
        
        [indicator startAnimating];
    }
    
//    if (GMSGeometryContainsLocation(coordinate, renderer.polyTemp.path , YES))
//    {
//        mapView.selectedMarker = polyMarker;
//    }
//    else
    {
        [self didRequestArea:coordinate.latitude andLng:coordinate.longitude];
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    if(mapView.camera.zoom >= 18)
    {
        if([[self getObject:@"setting"][@"show"] boolValue])
        {
            return;
        }
        
        [self showSVHUD:@"Đang tải" andOption:0];
        
        [self getAreaInfo];
    }
    else
    {
        [self clearPolygon];
    }
}

- (nullable UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    if(marker == mainMarker)
    {
        return nil;
    }
    
    NSMutableDictionary * markerInfo = [[marker.accessibilityLabel objectFromJSONString] reFormat];
    
    //NSLog(@"%@", markerInfo);
    
    int indexing = 1;
    
    if([markerInfo responseForKey:@"images"] && ![markerInfo[@"images"] isKindOfClass:[NSString class]])
    {
        indexing = 0;
        
        if([markerInfo[@"images"] isKindOfClass:[NSArray class]] && ((NSArray*)markerInfo[@"images"]).count == 0)
        {
            indexing = 1;
        }
    }
    
    UIView * view = [[NSBundle mainBundle] loadNibNamed:@"Annotation" owner:nil options:nil][indexing];
    
    ((UIView*)[self withView:view tag:15]).transform = CGAffineTransformMakeRotation(150);
    
    UILabel * des = ((UILabel*)[self withView:view tag:12]);
    
    if(marker == polyMarker)
    {
        ((UILabel*)[self withView:view tag:10]).text = [NSString stringWithFormat:@"Lô: %@", [markerInfo getValueFromKey:@"ten_lo"]];

        NSString * condition = [markerInfo getValueFromKey:@"tinh_trang_id"];
        
        [((UILabel*)[self withView:view tag:10]) setTextColor:[condition isEqualToString:@"1"] ? [UIColor colorWithRed:0 green:255 blue:0 alpha:0.8] : [condition isEqualToString:@"2"] ? [UIColor colorWithRed:255 green:0 blue:0 alpha:0.8] : [UIColor colorWithRed:0 green:0 blue:255 alpha:0.8]];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Mã lô: %@ \nTrạng thái: %@ \nDiện tích: %@ m2 \n%@", [markerInfo getValueFromKey:@"ki_hieu"], [self status:[markerInfo getValueFromKey:@"tinh_trang_id"]][@"status"], [markerInfo getValueFromKey:@"dien_tich"], [markerInfo getValueFromKey:@"description"]]];
        
        [string setColorForText:[self status:[markerInfo getValueFromKey:@"tinh_trang_id"]][@"status"] withColor:[self status:[markerInfo getValueFromKey:@"tinh_trang_id"]][@"color"]];
        
        des.attributedText = string;
    }
    else if(marker == searchMarker)
    {
        ((UILabel*)[self withView:view tag:10]).text = [NSString stringWithFormat:@"%@", [markerInfo getValueFromKey:@"text"]];
        
//        [(UIImageView*)[self withView:view tag:11] imageUrl:[markerInfo[@"images"] firstObject]];

        des.text = [markerInfo getValueFromKey:@"description"];
    }
    else
    {
        ((UILabel*)[self withView:view tag:10]).text = [NSString stringWithFormat:@"%@", [markerInfo getValueFromKey:@"name"]];
        
//        [(UIImageView*)[self withView:view tag:11] imageUrl:[markerInfo[@"images"] firstObject]];

        des.text = [markerInfo getValueFromKey:@"description"];
    }
    
    marker.tracksInfoWindowChanges = YES;

    float height = [des sizeOfMultiLineLabel].height;
    
    [view setHeight:height + (indexing ? 95 : 250) animated:NO];
    
    if(indexing == 0)
    {
        [view setWidth:230 animated:NO];
    }

    if(indexing == 0)
        [(UIImageView*)[self withView:view tag:100] imageUrl:[markerInfo[@"images"] firstObject][@"image_path"]];
    
    return view;
}

- (NSDictionary*)status:(NSString*)statusId
{
    return @{@"color":[statusId isEqualToString:@"1"] ? [UIColor colorWithRed:0 green:255 blue:0 alpha:0.8] : [statusId isEqualToString:@"2"] ? [UIColor colorWithRed:255 green:0 blue:0 alpha:0.8] : [UIColor colorWithRed:0 green:0 blue:255 alpha:0.8], @"status":[statusId isEqualToString:@"1"] ? @"Chưa bán" : [statusId isEqualToString:@"2"] ? @"Đã bán" : @"Đã đặt cọc"};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
