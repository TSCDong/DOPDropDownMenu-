//
//  DOPDropDownCollectionViewCell.m
//  NewButtonSelectDemo
//
//  Created by 野途 on 16/4/25.
//  Copyright © 2016年 阿里. All rights reserved.
//

#import "DOPDropDownCollectionViewCell.h"
#define kCellSelectBgColors [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1]
@implementation DOPDropDownCollectionViewCell

- (void)awakeFromNib {
    
    [self updateCheckImage];
}

- (void)updateCheckImage {
    if (self.selected) {
        self.backgroundColor = kCellSelectBgColors;
    } else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateCheckImage];
}

@end
