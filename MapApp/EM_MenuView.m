//
//  EM_MenuView.m
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_MenuView.h"

@interface EM_MenuView ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSMutableArray * dataList, * tempList;
    
    NSMutableDictionary * extraInfo, * multiSection;
    
    NSTimer * timer;
    
    NSString * gName, * uName;
    
    NSMutableArray *years;
}

@end

@implementation EM_MenuView

@synthesize menuCompletion;

- (id)initWithMenu:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateMenuView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateMenuView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 215)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][0];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    [(UIButton*)[self withView:contentView tag:10] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
        self.menuCompletion(0, nil, self);
        
    }];
    
    [(UIButton*)[self withView:contentView tag:11] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
        self.menuCompletion(1, nil, self);

    }];
    
    [(UIButton*)[self withView:contentView tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
        self.menuCompletion(2, nil, self);

    }];
    
    [(UIButton*)[self withView:contentView tag:14] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
        self.menuCompletion(3, nil, self);
        
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithLayers:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateLayersView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateLayersView:(NSDictionary*)dict
{
    dataList = [[NSMutableArray alloc] initWithArray:dict[@"data"]];
    
    uName = dict[@"uID"];
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 211)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][1];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    
    
    UITableView * tableView = (UITableView*)[self withView:contentView tag:11];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;

    
    
    [commentView addSubview:contentView];
    
    [tableView reloadData];
    
    return commentView;
}

- (id)initWithDate:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateDateView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (NSDate *)getDateFromDateString:(NSString *)dateString
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

- (UIView*)didCreateDateView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 247)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][3];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    UIDatePicker * datePicker = ((UIDatePicker*)[self withView:contentView tag:11]);

    if([dict responseForKey:@"date"])
    {
        [datePicker setDate:[self getDateFromDateString:dict[@"date"]] animated:YES];
    }
    
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    
//    [formatter setDateFormat:@"yyyy"];
//    
//    int i2  = [[formatter stringFromDate:[NSDate date]] intValue];
//    
//    years = [[NSMutableArray alloc] init];
//    
//    for (int i = 1900; i <= i2; i++)
//    {
//        [years addObject:[NSString stringWithFormat:@"%d",i]];
//    }
//    
//    UIPickerView * picker = (UIPickerView*)[self withView:contentView tag:11];
//    
//    picker.delegate = self;
//    
//    picker.dataSource = self;
//    
//    [picker selectRow:[years count] - 1 inComponent:0 animated:YES];
    
    UISwitch * show = (UISwitch*)[self withView:contentView tag:18];
    
    [show setOn:[[dict getValueFromKey:@"show"] isEqualToString:@"1"]];

    
    DropButton * gender = (DropButton*)[self withView:contentView tag:12];
    
    NSArray * data = @[@{@"title":@"Nam", @"id":@"0"}, @{@"title":@"Nữ", @"id":@"1"}];
    
    __block NSString * genderId = @"0";
    
    if([dict responseForKey:@"gender"])
    {
        int numb = [dict[@"gender"] intValue];
        
        [gender setTitle:data[numb][@"title"] forState:UIControlStateNormal];
        
        genderId = dict[@"gender"];
    }
    
    [gender actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [gender didDropDownWithData:@[@{@"title":@"Nam", @"id":@"0"}, @{@"title":@"Nữ", @"id":@"1"}] andCompletion:^(id object) {
            if(object)
            {
                [gender setTitle:object[@"data"][@"title"] forState:UIControlStateNormal];
                
                genderId = object[@"data"][@"id"];
            }
        }];
    }];
    
    [(UIButton*)[self withView:contentView tag:14] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
    }];
    
    [(UIButton*)[self withView:contentView tag:15] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {            
            self.menuCompletion(0, @{@"date":[datePicker.date stringWithFormat:@"dd/MM/yyyy"], @"gender":genderId, @"show": show.isOn ? @"1" : @"0"}, self);
        }
        
        [self close];
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (EM_MenuView*)showWithCompletion:(MenuCompletion)_completion
{
    menuCompletion = _completion;
    
    [self show];
    
    id tableView = [self withView:self tag:11];

    if([tableView isKindOfClass:[UITableView class]])
    {
        [self performSelector:@selector(didScroll:) withObject:tableView afterDelay:0.3];
    }
    
    return self;
}

- (void)didScroll:(UITableView*)tableView
{
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[extraInfo[@"active"] intValue] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)close
{
    [super close];
    
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
}

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [years count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [years objectAtIndex:row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? tableView.frame.size.height : tableView.tag == 11 ? 44 : 60;
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier: dataList.count == 0 ? @"E_Empty_Music" : @"presetCell"];
    
    if (!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][2];
    }

    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách trống";

        return cell;
    }
    
    NSDictionary * dict = dataList[indexPath.row];
    
    [(UILabel*)[self withView:cell tag:11] setText:dict[@"layer_name"]];
    
    [(UIButton*)[self withView:cell tag:15] setImage:[UIImage imageNamed: [dict[@"unique_name"] isEqualToString:uName] ? @"ic_checked" : @"trans"] forState:UIControlStateNormal];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        return;
    }

    NSDictionary * dict = dataList[indexPath.row];

    if(self.menuCompletion)
        self.menuCompletion(12, @{@"data":dict}, self);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 0 : dataList.count;
}

@end
