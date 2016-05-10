//
//  JSDROPDownViewController.m
//  NewButtonSelectDemo
//
//  Created by 野途 on 16/4/26.
//  Copyright © 2016年 阿里. All rights reserved.
//

#import "JSDROPDownViewController.h"

@interface JSDROPDownViewController ()

@property(copy) id string;
//字体可以是CTFontRef,CGFontRef 或者字符串命名的字体。默认为Helvetica字体 只有在使用字符串的属性不是 NSAttributedString

@property CFTypeRef font;
//字体大小。默认为36. 只有在使用字符串的属性不是 NSAttributedString. Animatable (Mac OS X 10.6 and later.)
@property CGFloat fontSize;

//用foregroundColor颜色画string。默认为不透明的白色。只有在使用字符串的属性不是 NSAttributedString。Animatable (Mac OS X 10.6 and later.)
@property CGColorRef foregroundColor;

//默认为No.  当Yes时，字符串自动适应layer的bounds大小
@property(getter=isWrapped) BOOL wrapped;

//设置缩短的部位
@property(copy) NSString *truncationMode;

//设置字体的排列格式
@property(copy) NSString *alignmentMode;

@end

@implementation JSDROPDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
 
        //create a text layer
    CATextLayer *textLayer = [CATextLayer layer];
        textLayer.frame = self.view.bounds;
        [self.view.layer addSublayer:textLayer]; //set text attributes
    textLayer.foregroundColor = [UIColor blackColor].CGColor;
        textLayer.alignmentMode = kCAAlignmentJustified;
        textLayer.wrapped = YES; //choose a font
   
    UIFont *font = [UIFont systemFontOfSize:14]; //set layer font
    CFStringRef fontCFString = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontCFString);
        textLayer.font = fontRef;
        textLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef); //choose some text
    
    NSString *text = @"Lorem isit amet, consectetpit pretium nunc sit ame lobortis"; //set layer text
    textLayer.string = text;
    
    CATextLayer *lary = [CATextLayer layer];
    
    lary.string = @"dasfasa";
    
    lary.bounds = CGRectMake(0, 0, 320, 20);
    
    lary.font = (__bridge CFTypeRef _Nullable)(@"HiraKakuProN-W3");
    
    //字体的名字 不是 UIFont
    
    lary.fontSize = 12.f;
    
    //字体的大小
    
    lary.alignmentMode = kCAAlignmentCenter;//字体的对齐方式
    
    lary.position = CGPointMake(160, 410);
    
    lary.foregroundColor = [UIColor redColor].CGColor;//字体的颜色
     lary.contentsScale = [UIScreen mainScreen].scale;//解决文字模糊 以以Retina方式来渲染
    [self.view.layer addSublayer:lary];
    // Do any additional setup after loading the view from its nib.
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
