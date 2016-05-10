//
//  UIView+BundleExtension.m
//  CollectionViewSelect
//
//  Created by admin on 15/10/19.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "UIView+BundleExtension.h"

@implementation UIView (BundleExtension)

+ (id)newFromNib {
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    for (id object in objects) {
        if ([object isKindOfClass:self]) {
            return object;
            break;
        }
    }
    
    return nil;
}

@end
