//
//  CollectionFootViewController.m
//  NewButtonSelectDemo
//
//  Created by 野途 on 16/4/29.
//  Copyright © 2016年 阿里. All rights reserved.
//

#import "CollectionFootViewController.h"

@interface CollectionFootViewController ()

@end

@implementation CollectionFootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_maxtime addTarget:self action:@selector(maxSelect) forControlEvents:UIControlEventTouchUpInside];
    
    [_mintime addTarget:self action:@selector(minSelect) forControlEvents:UIControlEventTouchUpInside];
    [_confirm setTitle:@"确定" forState:UIControlStateNormal];
    [_confirm addTarget:self action:@selector(confirmSelect) forControlEvents:UIControlEventTouchUpInside];
    
    [self reloadFootView];
    
    
    
    
    // Do any additional setup after loading the view from its nib.
}
- (void)reloadFootView
{
//    NSLog(@"%@",[self.dataSource maxTime:self]);
    
    if ([self.dataSource maxTime:self] ) {
        [_maxtime setTitle:[self.dataSource maxTime:self] forState:UIControlStateNormal];
    } else {
        [_maxtime setTitle:@"不限" forState:UIControlStateNormal];
    }
    
    if ([self.dataSource minTiem:self]) {
        [_mintime setTitle:[self.dataSource minTiem:self]  forState:UIControlStateNormal];
    } else {
        [_mintime setTitle:@"不限" forState:UIControlStateNormal];
    }
    
    BOOL s = [self.dataSource maxTime:self];
    NSLog(@"%@",s?@"YES":@"NO");
    
    if([self compareDate:[self.dataSource minTiem:self] withDate:[self.dataSource maxTime:self]] == -1) {
        _confirm.userInteractionEnabled = NO;
        [_confirm setBackgroundColor:[UIColor grayColor]];

    } else if ([self.dataSource maxTime:self] || [self.dataSource minTiem:self] ) {
        _confirm.userInteractionEnabled = YES;
        [_confirm setBackgroundColor:[UIColor greenColor]];
    } else {
        _confirm.userInteractionEnabled = NO;
        [_confirm setBackgroundColor:[UIColor grayColor]];
    }
}

-(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date01];
    dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            //date02=date01
        case NSOrderedSame: ci=0; break;
        default: NSLog(@"erorr dates %@, %@", dt2, dt1); break;
    }
    return ci;
}

- (void)maxSelect
{
    [self.delegate maxSelectAction:@"2"];
    NSLog(@"maxSelect");
}

- (void)minSelect
{
    [self.delegate minSelectAction:@"1"];
    NSLog(@"minSelect");
}
- (void)confirmSelect
{
  //  NSLog(@"confirmSelect");
    [self.delegate confirmSelectActionMinTitle:_mintime.titleLabel.text maxTitle:_maxtime.titleLabel.text];
//    NSLog(@"min:%@--max:%@",_mintime.titleLabel.text,_maxtime.titleLabel.text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
