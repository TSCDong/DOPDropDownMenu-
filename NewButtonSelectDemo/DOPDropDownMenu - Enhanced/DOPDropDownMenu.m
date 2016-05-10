//
//  DOPDropDownMenu.m
//  DOPDropDownMenuDemo
//
//  Created by weizhou on 9/26/14.
//  Modify by tanyang on 20/3/15.
//  Copyright (c) 2014 fengweizhou. All rights reserved.
//

#import "DOPDropDownMenu.h"
#import "DOPDropDownTableViewCell.h"
#import "DOPDropDownCollectionViewCell.h"
#import "PublicMethods.h"



static NSString *cellIdentifier = @"DOPDropDownCollectionViewCell";
@implementation DOPIndexPath
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
        _item = -1;
    }
    return self;
}

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row tem:(NSInteger)item {
    self = [self initWithColumn:column row:row];
    if (self) {
        _item = item;
    }
    return self;
}

+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row {
    DOPIndexPath *indexPath = [[self alloc] initWithColumn:col row:row];
    return indexPath;
}

+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row item:(NSInteger)item
{
    return [[self alloc]initWithColumn:col row:row tem:item];
}

@end

@implementation DOPBackgroundCellView

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画一条底部线
    
    CGContextSetRGBStrokeColor(context, 229.0/255, 229.0/255, 229.0/255, 1);//线条颜色
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width,0);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width,rect.size.height);
    CGContextStrokePath(context);
}

@end

#pragma mark - menu implementation

@interface DOPDropDownMenu (){
    struct {
        unsigned int numberOfRowsInColumn :1;
        unsigned int numberOfItemsInRow :1;
        unsigned int titleForRowAtIndexPath :1;
        unsigned int titleForItemsInRowAtIndexPath :1;
        unsigned int imageNameForRowAtIndexPath :1;
        unsigned int imageNameForItemsInRowAtIndexPath :1;
        unsigned int detailTextForRowAtIndexPath: 1;
        unsigned int detailTextForItemsInRowAtIndexPath: 1;
        
    }_dataSourceFlags;
}

@property (nonatomic, assign) NSInteger currentSelectedMenudIndex;  // 当前选中列

@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger numOfMenu;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIView *backGroundView;
/** 一级tableview */
@property (nonatomic, strong) UITableView *leftTableView;   // 一级列表
@property (nonatomic, strong) UITableView *rightTableView;  // 二级列表
@property (nonatomic, strong) UICollectionView *rightCollectionView;//二级collectionView
@property (nonatomic, strong) UICollectionView *locationCollectionView;//一级collectionView



/** 底下的线 */
@property (nonatomic, weak) UIView *bottomShadow;

//data source
@property (nonatomic, copy) NSArray *array;
//layers array
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *indicators;
@property (nonatomic, copy) NSArray *bgLayers;
//23级collection 默认选择
@property (nonatomic, assign) BOOL isRCollFirst;

//footView
@property (nonatomic, strong) UICollectionViewFlowLayout *Flowlayout;

@property (nonatomic, strong) UIView *footView;
//选择日期
@property (nonatomic, strong) UIView *pickView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSString *minStr;
@property (nonatomic, strong) NSString *maxStr;
//选择日期按钮的标识 起始 1 终点 2
@property int identify;
@property (nonatomic, assign) BOOL isAll;//全部：自行车 是否选中全部


@end

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define kTableViewCellHeight 43
#define kCollectionCellH 30
#define kCollectionCellHT 40
#define kTableViewHeight 300
#define kButtomImageViewHeight 21

#define kTextColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kSeparatorColor [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1]
#define kCellSelectBgColor [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]
#define kTextSelectColor [UIColor colorWithRed:126/255.0 green:200/255.0 blue:74/255.0 alpha:1]
/** 颜色RGB */
#define Color(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define CollectionCellW (int)((SCREEN_WIDTH * 2 / 3 - 40) / 3 )


@implementation DOPDropDownMenu {
    CGFloat _tableViewHeight;
    NSInteger tapIndex;
}

#pragma mark - getter
- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor blackColor];
    }
    return _indicatorColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        _separatorColor = [UIColor blackColor];
    }
    return _separatorColor;
}

- (NSString *)titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
    
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];
}

- (void)reloadData
{
    [self animateBackGroundView:_backGroundView show:NO complete:^{
        [self animateTableView:nil show:NO complete:^{
            _show = NO;
            id VC = self.dataSource;
            self.dataSource = nil;
            self.dataSource = VC;
        }];
    }];
    
}
#pragma mark  ——————————————— 7 ————————————————
- (void)selectDefalutIndexPath
{
    [self selectIndexPath:[DOPIndexPath indexPathWithCol:0 row:0]];
}
#pragma mark  ——————————————— 9 ————————————————
- (void)selectIndexPath:(DOPIndexPath *)indexPath triggerDelegate:(BOOL)trigger {
    if (!_dataSource || !_delegate
        || ![_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        return;
    }
    
    if (_dataSourceFlags.numberOfRowsInColumn <= indexPath.column || [_dataSource menu:self numberOfRowsInColumn:indexPath.column] <= indexPath.row) {
        return;
    }
    
    CATextLayer *title = (CATextLayer *)_titles[indexPath.column];//接收传过来的字符串
    
    if (indexPath.item < 0 ) {
        if (!_isClickHaveItemValid && [_dataSource menu:self numberOfItemsInRow:indexPath.row column:indexPath.column] > 0){
            title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:[DOPIndexPath indexPathWithCol:indexPath.column row:self.isRemainMenuTitle ? 0 : indexPath.row item:0]];
            if (trigger) {
                [_delegate menu:self didSelectRowAtIndexPath:[DOPIndexPath indexPathWithCol:indexPath.column row:indexPath.row item:0]];
            }
        }else {
            
        }
        if (_currentSelectRowArray.count > indexPath.column) {
        }
        CGSize size = [self calculateTitleSizeWithString:title.string];
        CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
        title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    }else if ([_dataSource menu:self numberOfItemsInRow:indexPath.row column:indexPath.column] > indexPath.column) {
        title.string = [_dataSource menu:self titleForRowAtIndexPath:indexPath];
        
        if (trigger) {
            [_delegate menu:self didSelectRowAtIndexPath:indexPath];
        }
        if (_currentSelectRowArray.count > indexPath.column) {
            _currentSelectRowArray[indexPath.column] = @(indexPath.row);
        }
        CGSize size = [self calculateTitleSizeWithString:title.string];
        CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
        title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    }
}
#pragma mark  ——————————————— 8 ————————————————
- (void)selectIndexPath:(DOPIndexPath *)indexPath {
    [self selectIndexPath:indexPath triggerDelegate:YES];
}

#pragma mark - setter-----初始设置-------字 和 三角标的位置 --- 以及各个数值
- (void)setDataSource:(id<DOPDropDownMenuDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    
    //configure view
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfMenu = 1;
    }
    
    _currentSelectRowArray = [NSMutableArray arrayWithCapacity:_numOfMenu];
    
    for (NSInteger index = 0; index < _numOfMenu; ++index) {
        [_currentSelectRowArray addObject:@(0)];
    }
    
    _dataSourceFlags.numberOfRowsInColumn = [_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)];
    _dataSourceFlags.numberOfItemsInRow = [_dataSource respondsToSelector:@selector(menu:numberOfItemsInRow:column:)];
    _dataSourceFlags.titleForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)];
    _dataSourceFlags.titleForItemsInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForItemsInRowAtIndexPath:)];
    _dataSourceFlags.imageNameForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:imageNameForRowAtIndexPath:)];
    _dataSourceFlags.imageNameForItemsInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:imageNameForItemsInRowAtIndexPath:)];
    _dataSourceFlags.detailTextForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:detailTextForRowAtIndexPath:)];
    _dataSourceFlags.detailTextForItemsInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:detailTextForItemsInRowAtIndexPath:)];
    
    _bottomShadow.hidden = NO;//底下的线
    
    CGFloat textLayerInterval = self.frame.size.width / ( _numOfMenu * 2);
    CGFloat bgLayerInterval = self.frame.size.width / _numOfMenu;
    
    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    
    for (int i = 0; i < _numOfMenu; i++) {
        //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:[UIColor whiteColor] andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
        
        //title
        CGPoint titlePosition = CGPointMake( (i * 2 + 1) * textLayerInterval , self.frame.size.height / 2);
        
        NSString *titleString;
        if (!self.isClickHaveItemValid && _dataSourceFlags.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:0 column:i]>0) {
            titleString = [_dataSource menu:self titleForItemsInRowAtIndexPath:[DOPIndexPath indexPathWithCol:i row:0 item:0]];
        }else {
            titleString = _menuTitle[i];
        }
        
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
        
        //三角形的 方法
        //indicator
        CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:CGPointMake(title.frame.origin.x + title.frame.size.width + 10, self.frame.size.height / 2)];
        
        [self.layer addSublayer:indicator];
        [tempIndicators addObject:indicator];
        
#pragma mark -.--------------- separator 分割线
        //        if (i != _numOfMenu - 1) {
        //            CGPoint separatorPosition = CGPointMake(ceilf((i + 1) * separatorLineInterval-1), self.frame.size.height / 2);
        //            CAShapeLayer *separator = [self createSeparatorLineWithColor:self.separatorColor andPosition:separatorPosition];
        //            [self.layer addSublayer:separator];
        //        }
    }
    _titles = [tempTitles copy];
    _indicators = [tempIndicators copy];
    _bgLayers = [tempBgLayers copy];
}
#pragma mark  ——————————————— 1 ————————————————
#pragma mark - init method ----第一次----初始化
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, height)];
    if (self) {
        _origin = origin;
        _currentSelectedMenudIndex = -1;
        _show = NO;
        _fontSize = 14;
        _cellStyle = UITableViewCellStyleDefault;
        _separatorColor = kSeparatorColor;
        _textColor = kTextColor;
        _textSelectedColor = kTextSelectColor;
        _detailTextFont = [UIFont systemFontOfSize:11];
        _indicatorColor = kTextColor;
        _tableViewHeight = IS_IPHONE_4_OR_LESS ? 200 : kTableViewHeight;
        _isClickHaveItemValid = YES;
        _isRCollFirst = YES;
        
#pragma mark -.-     lefttableView init
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width/3, 0) style:UITableViewStylePlain];
        _leftTableView.rowHeight = kTableViewCellHeight;
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        _leftTableView.delegate = self;
        _leftTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _leftTableView.scrollEnabled = NO;
        _leftTableView.tableFooterView = [[UIView alloc]init];
        
#pragma mark -.-    rightCollectionView init
        UICollectionViewFlowLayout *layout=[[ UICollectionViewFlowLayout alloc ] init ];
        
        layout.footerReferenceSize = CGSizeZero;
        
        _rightCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake( self.frame.size.width / 3, self.frame.origin.y + self.frame.size.height, self.frame.size.width * 2 / 3, 0) collectionViewLayout:layout];
        _rightCollectionView.backgroundColor = kCellSelectBgColor;
        _rightCollectionView.dataSource = self;
        _rightCollectionView.delegate = self;
        _rightCollectionView.scrollEnabled = NO;
        [_rightCollectionView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
        
#pragma mark -.-    footView init 日期选择
        _footView = [[UIView alloc]initWithFrame: CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height,SCREEN_MIN_LENGTH, 0)];
        _footView.backgroundColor = [UIColor whiteColor];
        
        _cFootView = [[CollectionFootViewController alloc]initWithNibName:@"CollectionFootViewController" bundle:nil];
        _cFootView.view.backgroundColor = [UIColor whiteColor];
        _cFootView.view.alpha = 0;
        _cFootView.delegate = self;
        _cFootView.dataSource = self;
        
#pragma mark -.-     self tapped  菜单栏阴影
        self.backgroundColor = [UIColor whiteColor];//背景颜色
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, screenSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];//隐藏
        [_backGroundView addGestureRecognizer:gesture];
        
        //add bottom shadow
        UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, screenSize.width, 0.5)];
        bottomShadow.backgroundColor = kSeparatorColor;
        bottomShadow.hidden = YES;
        [self addSubview:bottomShadow];
        _bottomShadow = bottomShadow;
    }
    return self;
}

#pragma mark ------- collectionViewFootView   -------   日期代理方法-----
- (NSString *)minTiem:(CollectionFootViewController *)footview
{
    return self.minStr;
}
- (NSString *)maxTime:(CollectionFootViewController *)footview
{
    return self.maxStr;
}
- (void)minSelectAction:(NSString *)menu
{
    _identify = 1;
    [self showDatePickeView:menu];
}
- (void)maxSelectAction:(NSString *)menu
{
    _identify = 2;
    [self showDatePickeView:menu];
}
//  确定按钮
- (void)confirmSelectActionMinTitle:(NSString *)mintitle maxTitle:(NSString *)maxtitle
{
    _isStarTime = YES;
    
    if ([mintitle isEqualToString:@"不限"]) {
        mintitle = @"";
    }
    if ([maxtitle isEqualToString:@"不限"]) {
        maxtitle = @"";
    }
    [self.delegate dataPickerMinTime:mintitle MaxTime:maxtitle];
    
    [self hideMenuview:NO];
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_leftTableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];
    
}

#pragma mark -.-  -------showDatePickeView     出生日期选择
- (void)showDatePickeView:(NSString *)menu
{
    if (self.pickView != nil) {
        return;
    }
    
    self.pickView = [[UIView alloc]init];
    self.pickView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 260);
    self.pickView.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self.pickView];
    
    UIToolbar *toolBar=[UIToolbar new];
    toolBar.frame=CGRectMake(0, 0, SCREEN_WIDTH, 44);
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    CGRect frame = CGRectMake(10,0,80,30);
    
    UIButton *surebtn = [[UIButton alloc ]initWithFrame:frame];
    [surebtn setTitle:[NSString stringWithFormat:@"    %@",@"完成"] forState:UIControlStateNormal];
    [surebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [surebtn addTarget:self action:@selector(savePicker:) forControlEvents:UIControlEventTouchUpInside];
    surebtn.tag = [menu integerValue];
    
    UIBarButtonItem *sureBtn = [[UIBarButtonItem alloc] initWithCustomView:surebtn];
    toolBar.items = [NSArray arrayWithObjects:flexItem,sureBtn, nil];
    toolBar.tintColor=[UIColor blackColor];
    
    [self.pickView addSubview:toolBar];
    
    // 要转换的日期字符串
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *now = [NSDate date];
    NSString *dateString = [formatter stringFromDate:now];
    
    if ([menu intValue] == 1 && _minStr) {
        dateString = _minStr;
    }
    else if ([menu intValue] == 2 && _maxStr) {
        dateString = _maxStr;
    }
    
    long timess;
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromdate=[format dateFromString:dateString];
    timess = (long)[fromdate timeIntervalSince1970];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timess];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:confromTimesp];
    NSDate *localeDate = [confromTimesp  dateByAddingTimeInterval: interval];
    
    self.datePicker = [[UIDatePicker alloc]init];
    self.datePicker.frame = CGRectMake(0, toolBar.frame.size.height, SCREEN_WIDTH, 216);
    self.datePicker.timeZone = [NSTimeZone systemTimeZone];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker setDate:localeDate animated:YES];
    [self.datePicker  setMaximumDate:[NSDate date]];//日期最大值
    [self.pickView addSubview:self.datePicker];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.pickView.frame = CGRectMake(0, SCREEN_HEIGHT - 260, SCREEN_WIDTH, 260);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -.-  -------DatePickeView  取消
-(void)cancelPicker
{
    if (self.pickView == nil) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.pickView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 260);
    } completion:^(BOOL finished) {
        if (self.pickView != nil) {
            [self.pickView removeFromSuperview];
            self.pickView = nil;
        }
    }];
}

#pragma mark -.-  -------DatePickeView   确定
-(void)savePicker:(UIButton *)btn
{
    
    [self cancelPicker];
    NSDate* date_one = self.datePicker.date;
    NSString *dateStr = [GlobalPublicMethods formatTheTime:date_one];
    NSString *timestampStr = [GlobalPublicMethods timeStamp:dateStr];
    
    NSString *relaTimeStr = [GlobalPublicMethods formatTime:timestampStr format:@"yyyy-MM-dd"];
    if (relaTimeStr) {
        if (_identify == 1) {
            self.minStr = relaTimeStr;
        }
        else {
            self.maxStr = relaTimeStr;
        }
    }
    [_cFootView reloadFootView];
}

#pragma mark -------UICollectionViewDataSource  自行车级别、地区、赛事时间
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (tapIndex == 0) {
        if (_dataSourceFlags.numberOfItemsInRow) {
            NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
            return [_dataSource menu:self
                  numberOfItemsInRow:currentSelectedMenudRow column:_currentSelectedMenudIndex];
        } else {
            return 0;
        }
        
    } else {
        
        if (_dataSourceFlags.numberOfRowsInColumn) {//从上界面获取个数
            return [_dataSource menu:self
                numberOfRowsInColumn:_currentSelectedMenudIndex];
        } else {
            return 0;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DOPDropDownCollectionViewCell *cell = (DOPDropDownCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = Color(225, 225, 225);
    cell.backgroundColor = [UIColor whiteColor];
    
    if (tapIndex == 0) {
        cell.layer.borderWidth = 1;//边框
        cell.layer.borderColor = Color(229, 229, 229).CGColor;
        cell.layer.cornerRadius = 3;
        cell.contentView.layer.cornerRadius = 3.0f;
        cell.contentView.layer.masksToBounds = YES;
        
        NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
        cell.titlename.text = [_dataSource menu:self titleForItemsInRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:currentSelectedMenudRow item:indexPath.row]];
        
        
        if ([cell.titlename.text isEqualToString:[(CATextLayer *)[_titles objectAtIndex:_currentSelectedMenudIndex] string]]) {
            cell.selected = YES;
        }
        else {
            if(indexPath.row == 0 && _isRCollFirst)
            {
                cell.selected = YES;
            } else if(indexPath.row == 0 && _isAll) {
                cell.selected = YES;
            }
        }
    }
    else {
        cell.layer.borderWidth = 0;//边框
        cell.layer.cornerRadius = 0;
        cell.contentView.layer.cornerRadius = 0.0f;
        cell.contentView.layer.masksToBounds = NO;
        
        NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
        
        cell.titlename.text = [_dataSource menu:self titleForRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]];
        
        if ([cell.titlename.text isEqualToString:[(CATextLayer *)[_titles objectAtIndex:_currentSelectedMenudIndex] string]]) {
            cell.selected = YES;
        }
        else if (indexPath.row == currentSelectedMenudRow && !_isStarMessage ) {
            cell.selected = YES;
        }
        if (tapIndex == 2) {
            if (indexPath.row == currentSelectedMenudRow && !_isStarTime ) {
                cell.selected = YES;
            }
            
        }
        
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (tapIndex == 0) {
        _isRCollFirst = NO;
        if (self.delegate && [_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
            
            NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
            
            [self.delegate menu:self didSelectRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:currentSelectedMenudRow item:indexPath.row]];
            
            if (indexPath.item == 0) {//是否选择了全部。选择全部 菜单栏要显示 自行车
                _isAll = YES;
            } else {
                _isAll = NO;
            }
            
            [self confiMenuWithSelectItem:indexPath.item];
        } else {
        }
    } else {
        
        
        BOOL haveItem = [self confiMenuWithSelectRow:indexPath.row];// 是否 有下一级
        BOOL isClickHaveItemValid = self.isClickHaveItemValid ? YES : haveItem;
        
        if (isClickHaveItemValid && _delegate && [_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
            [self.delegate menu:self didSelectRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]];
        } else {
        }
    }
    if (tapIndex == 2) {
        self.maxStr = nil;
        self.minStr = nil;
        _isStarTime = YES;
    }
    
    [self.cFootView reloadFootView];
}

// cell点击变色
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (tapIndex == 0) {
        return CGSizeMake(CollectionCellW, kCollectionCellH);
    } else {
        return CGSizeMake(SCREEN_WIDTH / 4 - 1, kCollectionCellHT);
    }
    
}
//定义每个UICollectionView 的边距

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (tapIndex == 0) {
        return UIEdgeInsetsMake ( 10 ,10, 0, 10 );
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
}
//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (tapIndex != 0) {
        return 1;
    }
    else {
        return 10;
    }
    
}

//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (tapIndex != 0) {
        return 1;
    }
    else {
        return 10;
    }
}

#pragma mark - init support -------最底层上面的背景-----
- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CALayer *layer = [CALayer layer];
    
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numOfMenu, self.frame.size.height - 1);
    layer.backgroundColor = color.CGColor;
    
    return layer;
}
#pragma mark - init support 三角形---赛贝尔画的
- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(4, 4)];
    [path addLineToPoint:CGPointMake(8, 0)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;//画笔大小
    layer.fillColor = [UIColor clearColor].CGColor;//填充颜色 ps：无填充色 是空心的三角形
    layer.strokeColor = color.CGColor;//线的颜色
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;//改变三角的位置
    
    return layer;
}
#pragma mark ---- init support 分隔的竖线
- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, 20)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    return layer;
}
#pragma mark ---- init support 字初始的颜色
- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point {
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);//大小
    layer.string = string;
    layer.fontSize = _fontSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.truncationMode = kCATruncationEnd;
    layer.foregroundColor = color.CGColor;//字体颜色
    
    layer.contentsScale = [[UIScreen mainScreen] scale];//高清
    
    layer.position = point;//layer在view的位置
    
    return layer;
}
#pragma mark  ——————————————— 点击上面的-- 4 ————————————————
#pragma mark - init support 字体大小
- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    CGFloat fontSize = 14.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return CGSizeMake(ceilf(size.width)+2, size.height);
}
#pragma mark  ——————————————— 点击上面的--1 ————————————————
#pragma mark - gesture handle  手势处理
- (void)menuTapped:(UITapGestureRecognizer *)paramSender {
    if (_dataSource == nil) {
        return;
    }
    CGPoint touchPoint = [paramSender locationInView:self];
    //calculate index
    tapIndex = touchPoint.x / (self.frame.size.width / _numOfMenu);//判断点击菜单的哪一栏 方便菜单界面多的时候用
    
//    [self.delegate removeKeyBord];//回收键盘
    
    if (tapIndex == 2) {//这里要添加 collectionView的footview 但是没弄好 可以优化
        self.Flowlayout.footerReferenceSize = CGSizeMake(SCREEN_WIDTH, 50);
        [_rightCollectionView reloadData];
    }
    
    for (int i = 0; i < _numOfMenu; i++) {// 选中的不走 没选中的走
        if (i != tapIndex) {
            
            [self animateIndicator:_indicators[i] Forward:NO complete:^{
                [self animateTitle:_titles[i] show:NO complete:^{
                    
                }];
            }];
        }
    }
    // == 先 0  && 0 假  判断是否展示
    if (tapIndex == _currentSelectedMenudIndex && _show) {
        [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_leftTableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
            _currentSelectedMenudIndex = tapIndex;
            _show = NO;
        }];
    } else {
        _currentSelectedMenudIndex = tapIndex;
        [_leftTableView reloadData];
        //1&&1 真
        if (_dataSource && _dataSourceFlags.numberOfItemsInRow) {
            [_rightCollectionView reloadData];
        }
        
        [self animateIdicator:_indicators[tapIndex] background:_backGroundView tableView:_leftTableView title:_titles[tapIndex] forward:YES complecte:^{
            _show = YES;
        }];
    }
}
#pragma mark -.- --------点击背景隐藏
- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_leftTableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];
}
#pragma mark  ——————————————— 点击上面的-- 2 ————————————————
#pragma mark - animation method 动画方法
- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];//三角旋转的时间，时间段旋转快
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];//设置动画的一些效果
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    if (forward) {
        // 展开
        indicator.strokeColor = _textSelectedColor.CGColor;
    } else {
        // 收缩
        indicator.strokeColor = _textColor.CGColor;
    }
    
    complete();
}
#pragma mark -.- 背景
- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

- (BOOL)isHaveSecondCollectionView
{
    NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
    NSInteger  cont = [_dataSource menu:self
                     numberOfItemsInRow:currentSelectedMenudRow column:_currentSelectedMenudIndex];
    
    if (!cont) {
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark -.- 列表-----展示
- (void)animateTableView:(UITableView *)tableView show:(BOOL)show complete:(void(^)())complete {
    
    BOOL haveItems = NO;
    
    if (_dataSource) {
        NSInteger num = [_leftTableView numberOfRowsInSection:0];//lefttableview有几个数据
        
        for (NSInteger i = 0; i<num;++i) {
            if (_dataSourceFlags.numberOfItemsInRow
                && [_dataSource menu:self numberOfItemsInRow:i column:_currentSelectedMenudIndex]/**等于零的时候没有二级界面 先判断是否大于零 */ > 0) {
                haveItems = YES;
                break;
            }
        }
    }
    
    if (show) {//展示tableview
        
        if (haveItems) {//是否 有二级界面
            _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width/3, 0);
            
            _rightCollectionView.frame = CGRectMake(self.origin.x + self.frame.size.width / 3 - 0.5, self.frame.origin.y + self.frame.size.height, self.frame.size.width * 2 / 3, 0);
            [self.superview addSubview:_leftTableView];
            [self.superview addSubview:_rightCollectionView];
            
            [self showTableView];
            
        } else {
            _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width/3, 0);
            _rightCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width , 0);
            if (tapIndex == 2) {
                _footView.frame = CGRectMake(self.origin.x,self.frame.origin.y + self.frame.size.height  , self.frame.size.width, 0);
                
                [self.superview addSubview:_footView];
            }
            
            [self.superview addSubview:_rightCollectionView];
            
            [self showRightCollectionView];
        }
    } else {//隐藏tableview
        [self hideMenuview:haveItems];
        
    }
    complete();
}

- (void)hideMenuview:(BOOL)haveItems
{
    [UIView animateWithDuration:0.2 animations:^{
        if (haveItems) {
            _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width/3, 0);
            
            _rightCollectionView.frame = CGRectMake(self.origin.x + self.frame.size.width / 3, self.frame.origin.y + self.frame.size.height, self.frame.size.width * 2 / 3, 0);
        } else {
            _rightCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            [_footView removeFromSuperview];
        }
    } completion:^(BOOL finished) {
        if (_leftTableView.superview) {
            [_leftTableView removeFromSuperview];
        }
        [_rightCollectionView removeFromSuperview];
        [_footView removeFromSuperview];
        [self cancelPicker];
        
    }];
}

- (void)showRightCollectionView
{
    NSInteger numC = [_rightCollectionView numberOfItemsInSection:0] ;
    int numCT = ceil([[NSString stringWithFormat:@"%ld",numC] floatValue] / 4) ;
    
    CGFloat collectionViewHeight = numCT * kCollectionCellHT ;
    [UIView animateWithDuration:0.15 animations:^{
        
        if (tapIndex == 2) {
            
            _footView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height + kCollectionCellHT, self.frame.size.width, 50);
            [_footView addSubview:_cFootView.view];
            _cFootView.view.alpha = 1;
        }
        else
        {
            [_footView removeFromSuperview];
            [self cancelPicker];
        }
        _rightCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width , collectionViewHeight + numCT - 1);
    }];
}

- (void)showTableView
{
    [self cancelPicker];
    [_footView removeFromSuperview];
    NSInteger num = [_leftTableView numberOfRowsInSection:0];
    CGFloat tableViewHeight = num * kTableViewCellHeight > _tableViewHeight ? _tableViewHeight:num*kTableViewCellHeight;
    
    NSInteger haveItem;
    if (_dataSourceFlags.numberOfItemsInRow) {
        NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
        haveItem = [_dataSource menu:self
                  numberOfItemsInRow:currentSelectedMenudRow column:_currentSelectedMenudIndex];
    }
    [UIView animateWithDuration:0.2 animations:^{
        if (haveItem) {
            
            _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width / 3, tableViewHeight);
            
            _rightCollectionView.frame = CGRectMake(self.origin.x + self.frame.size.width / 3 - 0.5, self.frame.origin.y + self.frame.size.height, self.frame.size.width * 2 / 3, tableViewHeight);
        }
        else {
            _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width / 3, tableViewHeight);
        }
    }];
}

#pragma mark  ——————————————— 点击上面的--3 ———————————————— 5
#pragma mark -.- 选择后的字的颜色
- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)())complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    if (!show) {
        title.foregroundColor = _textColor.CGColor;
    } else {
        title.foregroundColor = _textSelectedColor.CGColor;
    }
#pragma mark -.- -----------根据字的宽度 改变三角号的位置
    CAShapeLayer *indicator =(CAShapeLayer *)_indicators[tapIndex];
    indicator.position = CGPointMake(title.frame.origin.x + title.frame.size.width + 10, self.frame.size.height / 2);
    
    complete();
}
#pragma mark  ——————————————— 点击上面的-- 6 ————————————————
#pragma mark -.- 点击按钮走的方法
- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background tableView:(UITableView *)tableView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{
    
    //    NSLog(@"222asdasddsfadsfasfsfasdfadsfds");
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateTableView:tableView show:forward complete:^{
                }];
            }];
        }];
    }];
    
    complete();
}

#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSAssert(_dataSource != nil, @"menu's dataSource shouldn't be nil");
    if (_leftTableView == tableView) {
        if (_dataSourceFlags.numberOfRowsInColumn) {
            return [_dataSource menu:self
                numberOfRowsInColumn:_currentSelectedMenudIndex];
        } else {
            return 0;
        }
    } else {
        if (_dataSourceFlags.numberOfItemsInRow) {
            NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
            return [_dataSource menu:self
                  numberOfItemsInRow:currentSelectedMenudRow column:_currentSelectedMenudIndex];
        } else {
            //NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
            return 0;
        }
    }
}

-(void)viewDidLayoutSubviews
{
    if ([_leftTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_leftTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_leftTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [_leftTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"DOPDropDownTableViewCell";
    DOPDropDownTableViewCell *cell = (DOPDropDownTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil] objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _isRCollFirst = YES;
    
    if (tableView == _leftTableView) {
        
        cell.titlename.textColor = _textColor;
        cell.titlename.font = [UIFont systemFontOfSize:_fontSize];
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH /3, 43)];
        cell.selectedBackgroundView.backgroundColor = Color(240, 240, 240);
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        cell.layer.borderWidth = 0.5;//边框
        cell.layer.borderColor = Color(229, 229, 229).CGColor;
        
        if (_dataSourceFlags.titleForRowAtIndexPath) {
            cell.titlename.text = [_dataSource menu:self titleForRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]];
            
        } else {
        }
        NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
        
        if (indexPath.row == currentSelectedMenudRow )
        {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        
        cell.backgroundColor = [UIColor whiteColor];
        
    } //leftTabeview
    return cell;
}

#pragma mark - tableview delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [_delegate respondsToSelector:@selector(menu:willSelectRowAtIndexPath:)]) {
        return [self.delegate menu:self willSelectRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]];
    } else {
        //TODO: delegate is nil
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (_leftTableView == tableView) {
        BOOL haveItem = [self confiMenuWithSelectRow:indexPath.row];//判断是否有下一级界面
        BOOL isClickHaveItemValid = self.isClickHaveItemValid ? YES : haveItem;
        
        if (isClickHaveItemValid && _delegate && [_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
            [self.delegate menu:self didSelectRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]];
            [self showTableView];
        } else {
            //TODO: delegate is nil
        }
    } else {
        [self confiMenuWithSelectItem:indexPath.item];//选择隐藏
        if (self.delegate && [_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
            NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
            [self.delegate menu:self didSelectRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:currentSelectedMenudRow item:indexPath.row]];
        } else {
            //TODO: delegate is nil
            
        }
    }
}

//
- (BOOL )confiMenuWithSelectRow:(NSInteger)row {
    
    _currentSelectRowArray[_currentSelectedMenudIndex] = @(row);
    
    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedMenudIndex];
    
    if (_dataSourceFlags.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:row column:_currentSelectedMenudIndex]> 0) {
        
        // 有双列表 有item数据
        if (self.isClickHaveItemValid) {
            title.string = [_dataSource menu:self titleForRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:row]];
            NSLog(@"%@",[title string]);
            //改变字的颜色 字
            [self animateTitle:title show:YES complete:^{
                [_rightCollectionView reloadData];
            }];
        } else {
            [_rightCollectionView reloadData];
        }
        return NO;
        
    } else {
        //没有下一级的数据时候
        title.string = [_dataSource menu:self titleForRowAtIndexPath:
                        [DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:self.isRemainMenuTitle ? 0 : row]];
        [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_leftTableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
            _show = NO;
        }];
        return YES;
    }
}
- (void)confiMenuWithSelectItem:(NSInteger)item {
    
    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedMenudIndex];
    NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
    
    if (_isAll) {
        
    } else {
        title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:[DOPIndexPath indexPathWithCol:_currentSelectedMenudIndex row:currentSelectedMenudRow item:item]];
    }
    
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_leftTableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];
}
#pragma mark -.- ---------赛事时间----------------

@end

