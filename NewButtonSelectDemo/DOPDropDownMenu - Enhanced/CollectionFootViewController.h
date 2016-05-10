//
//  CollectionFootViewController.h
//  NewButtonSelectDemo
//
//  Created by 野途 on 16/4/29.
//  Copyright © 2016年 阿里. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CollectionFootViewController;

@protocol CollectionFootViewControllerDataSource <NSObject>

@required
- (NSString *)minTiem:(CollectionFootViewController *)footview;
- (NSString *)maxTime:(CollectionFootViewController *)footview;

@end

@protocol CollectionFootViewControllerDelegate <NSObject>

@optional
- (void)minSelectAction:(NSString *)menu;
- (void)maxSelectAction:(NSString *)menu;
- (void)confirmSelectActionMinTitle:(NSString *)mintitle maxTitle:(NSString *)maxtitle;

@end

@interface CollectionFootViewController : UIViewController
@property (nonatomic, weak) id<CollectionFootViewControllerDelegate> delegate;
@property (nonatomic, weak) id<CollectionFootViewControllerDataSource> dataSource;

@property (strong, nonatomic) IBOutlet UIButton *confirm;
@property (strong, nonatomic) IBOutlet UIButton *maxtime;
@property (strong, nonatomic) IBOutlet UIButton *mintime;

- (void)reloadFootView;
@end

