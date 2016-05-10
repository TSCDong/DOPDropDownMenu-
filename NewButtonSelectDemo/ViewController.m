//
//  ViewController.m
//  NewButtonSelectDemo
//
//  Created by 野途 on 16/4/22.
//  Copyright © 2016年 阿里. All rights reserved.
//

#import "ViewController.h"
#import "DOPDropDownMenu.h"
#import "JSDROPDownViewController.h"

@interface ViewController ()<DOPDropDownMenuDataSource,DOPDropDownMenuDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *classifys;
@property (nonatomic, strong) NSArray *cates;
@property (nonatomic, strong) NSArray *menuTitleArr;
@property (nonatomic, strong) NSArray *hostels;
@property (nonatomic, strong) NSArray *areas;

@property (nonatomic, strong) NSArray *sorts;
@property (nonatomic, weak) DOPDropDownMenu *menu;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *areaCollection;
@property (nonatomic, strong) NSMutableArray *otherAddressArray;
@property (nonatomic, strong) NSString *minTime;//起始时间
@property (nonatomic, strong) NSString *maxTime;//终点时间

@end

@implementation ViewController

- (NSMutableArray *)otherAddressArray
{
    
    return _otherAddressArray;
}
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"text";
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 数据
    self.classifys = @[@"全部",@"自行车",@"铁三"];
    self.cates = @[@"全部",@"A级",@"B级",@"C级",@"D级",@"小轮",@"速降",@"活动"];
    self.menuTitleArr = @[@"赛事类型",@"所在地区",@"赛事时间"];
    self.sorts = @[@"不限",@"一周内",@"一个月内",@"三个月内"];
    if (!_otherAddressArray) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"province" ofType:@"plist"];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSMutableArray * array = [[NSMutableArray alloc]init];
        [array addObject:@"全国"];
        for (NSInteger i = 0; i<[data allKeys].count; i++) {
            NSDictionary * dic =[data objectForKey:[NSString stringWithFormat:@"%ld",i]];
            [array addObject:[dic allKeys][0]];
            
        }
        
        _otherAddressArray = array;
        
    }

    // 添加下拉菜单
    DOPDropDownMenu *menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:44];
    menu.delegate = self;
    menu.dataSource = self;
    menu.menuTitle = self.menuTitleArr;
    [self.view insertSubview:menu atIndex:9];
    _menu = menu;
    [menu selectDefalutIndexPath];
    [self menuReloadData];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    
    [btn setTitle:@"sssssdfdsfasd" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(createTableView) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor blackColor]];
    
    
//    [self.view addSubview:btn];
    
    
//    [self.tableView.header beginRefreshing];

}
//日期选择
- (void)dataPickerMinTime:(NSString *)mintime MaxTime:(NSString *)maxtime
{
    
    self.minTime = mintime;
    self.maxTime = maxtime;
    
//    [_menuTitleArr replaceObjectAtIndex:2 withObject:@"自定义"]; // 改变菜单栏的字 如果需要你菜单栏的那个数组要用可变的
    
    [_menu reloadData];
//    [self requestData];//数据请求
}
- (void)createTableView{

    JSDROPDownViewController *jsd = [[JSDROPDownViewController alloc]init];
  [self presentViewController:jsd animated:YES completion:^{
      
  }];
}

#pragma mark - tableView的几个方法

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 20;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *ID = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (!cell) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
//    }
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"%ld ... ",indexPath.row];
//    return cell;
//}



#pragma mark - DropDownMenu的几个方法

- (void)menuReloadData
{
    self.classifys = @[@"全部",@"自行车",@"铁三"];
    [_menu reloadData];
}

- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu
{
    return 3;
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column
{
    if (column == 0) {
        return self.classifys.count;
    }else if (column == 1){
        return _otherAddressArray.count;
    }else {
        return self.sorts.count;
    }
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        return self.classifys[indexPath.row];
    } else if (indexPath.column == 1){
        return _otherAddressArray[indexPath.row];
    } else {
        return self.sorts[indexPath.row];
    }
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column
{
    if (column == 0) {
        if (row == 1) {
            return self.cates.count;
        }
    }
    return 0;
}
//选择跳默认选项

- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        if (indexPath.row == 1) {
            return self.cates[indexPath.item];
        }
    }
    return nil;
}

- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.item >= 0) {
        NSLog(@"点击了 %ld - %ld - %ld 项目",indexPath.column,indexPath.row,indexPath.item);
    }else {
        NSLog(@"点击了 %ld - %ld 项目",indexPath.column,indexPath.row);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
