//
//  BQLMarquee.h
//  跑马灯
//
//  Created by 毕青林 on 16/8/29.
//  Copyright © 2016年 毕青林. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  类型
 */
typedef NS_ENUM(NSInteger, BQLMarqueeType) {
    /**
     *  线型(常见的:从右至左移动)
     */
    BQLMarqueeTypeLine = 0,
    /**
     *  上下翻滚型
     */
    BQLMarqueeTypeRoll,
};

/**
 *  翻滚类型
 */
typedef NS_ENUM(NSInteger, BQLMarqueeRollType) {
    /**
     *  向上翻滚
     */
    BQLMarqueeRollTypeUp = 0,
    /**
     *  向下翻滚
     */
    BQLMarqueeRollTypeDown,
};

@interface BQLMarquee : UIView

/**
 *  跑马灯类型
 */
@property (nonatomic) BQLMarqueeType marqueeType;

/**
 *  自定义跑马灯速度
 */
@property (nonatomic, assign) NSInteger marqueeCustomSpeed;

/**
 *  跑马灯文本Label
 */
@property (nonatomic, strong) UILabel *marqueeLabel;

/**
 *  跑马灯文本
 */
@property (nonatomic, copy) NSString *marqueeText;

/**
 *  跑马灯背景颜色
 */
@property (nonatomic) UIColor *marqueeBackgroundColor;

/**
 *  跑马灯文本颜色
 */
@property (nonatomic) UIColor *marqueeTextColor;

/**
 *  跑马灯文本字号
 */
@property (nonatomic) UIFont *marqueeFont;

/**
 *  动画停止与播放
 */
@property (nonatomic, assign) BOOL isStop;

/**
 *  翻滚样式信息数组
 */
@property (nonatomic, strong) NSArray *messages;

/**
 *  设置翻滚类型(向上or向下,默认向上翻滚)
 */
@property (nonatomic) BQLMarqueeRollType rollType;

/**
 *  翻滚类型文本样式(居左、居中、居右,默认居左)
 */
@property (nonatomic) NSTextAlignment marqueeTextAlignment;

@property (nonatomic, copy) void (^didClickAtIndexBlock)(NSInteger index);

/**
 *  该方法提供线型样式和翻滚样式
 *
 *  @param frame frame
 *  @param type  类型
 *  @param text  文本(Line型需填)
 *  @param messages  消息数组(Roll型需填)
 */
- (instancetype)initWithFrame:(CGRect)frame Type:(BQLMarqueeType )type Text:(NSString *)text Roll:(NSArray *)messages;

/**
 *  该方法提供线型样式和翻滚样式
 *
 *  @param type  类型
 *  @param text  文本(Line型需填)
 *  @param messages  消息数组(Roll型需填)
 */
- (instancetype)initWithType:(BQLMarqueeType )type Text:(NSString *)text Roll:(NSArray *)messages;

/**
 *  开始动画(作用于Line型)
 */
- (void)start;

/**
 *  继续动画(作用于Line型)
 */
- (void)restart;

/**
 *  停止动画
 */
- (void)stop;

@end



