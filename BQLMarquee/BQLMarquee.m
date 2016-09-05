//
//  BQLMarquee.m
//  跑马灯
//
//  Created by 毕青林 on 16/8/29.
//  Copyright © 2016年 毕青林. All rights reserved.
//

#import "BQLMarquee.h"

#define DefaultBackgroundColor [UIColor clearColor]
#define DefaultTextColor [UIColor blackColor]
#define DefaultTextFont [UIFont systemFontOfSize:12]
#define DefaultTextHeight 18
#define DefaultType 0
#define DefaultSpeed self.marqueeType == BQLMarqueeTypeLine?5:2;
#define Margin 15

// 获取随机颜色
#define BQLRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

@interface BQLMarquee ()
{
    CGFloat selfWidth;
    CGFloat selfHeight;
    CGPoint startPoint;
    CGPoint endPoint;
    NSInteger animationSpeed;
    
    // roll
    NSTimer *_timer;
    // 当前翻滚到的数组下标
    NSInteger currentIndex;
}

// 定义两个label就可以满足多条信息翻滚显示需求
@property (nonatomic, strong) UILabel *messageLabelOne;

@property (nonatomic, strong) UILabel *messageLabelTwo;

@end

@implementation BQLMarquee

- (instancetype)initWithType:(BQLMarqueeType )type Text:(NSString *)text Roll:(NSArray *)messages {
    
    if(self = [super init]) {
        
        _marqueeType = type;
        _marqueeText = text;
        _messages = messages;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Type:(BQLMarqueeType )type Text:(NSString *)text Roll:(NSArray *)messages {
    
    if(self = [super initWithFrame:frame]) {
        
        self.marqueeType = type;
        self.marqueeText = text;
        self.messages = messages;
        [self setup];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    selfWidth = frame.size.width;
    selfHeight = frame.size.height;
    if(frame.size.width != 0 && frame.size.height != 0) {
        [self setup];
    }
}

- (void)setup {
    
    /* 这里要注意：如果不设置self.layer.masksToBounds = YES 会让超出父类的部分显示，但那并不是我们想要的 */
    self.layer.masksToBounds = YES;
    self.backgroundColor = self.marqueeBackgroundColor?self.marqueeBackgroundColor:BQLRandomColor;
    selfWidth = selfWidth != 0?selfWidth:self.frame.size.width;
    selfHeight = selfHeight != 0?selfHeight:self.frame.size.height;
    self.marqueeType = self.marqueeType?self.marqueeType:DefaultType;
    animationSpeed = self.marqueeCustomSpeed?self.marqueeCustomSpeed:DefaultSpeed;
    
    switch (self.marqueeType) {
        case BQLMarqueeTypeLine: {
            [self addSubview:self.marqueeLabel];
        }
            break;
        case BQLMarqueeTypeRoll: {
            currentIndex = 0;
            [self setRollUp];
        }
            break;
            
        default:
            break;
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appHasGoneInForeground)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appHasGoneInBackground)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
}

// roll 布局
- (void)setRollUp {
    
    [self setMessageLabel];
    
    [self addSubview:self.messageLabelOne];
    [self addSubview:self.messageLabelTwo];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf:)];
    [self addGestureRecognizer:tap];
    // 翻滚时间一定要比执行动画时间长，不然会造成动画错乱
    _timer = [NSTimer timerWithTimeInterval:animationSpeed * 1.5 target:self selector:@selector(startRollAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)tapSelf:(UITapGestureRecognizer *)tap {
    
    if(self.didClickAtIndexBlock) {
        
        self.didClickAtIndexBlock(currentIndex);
    }
}

- (void)start {
    
    if(self.marqueeType == BQLMarqueeTypeLine) {
        [self startAnimation];
    }
}

- (void)restart {
    
    if(self.marqueeType == BQLMarqueeTypeLine) {
        self.isStop = NO;
    }
}

- (void)stop {
    
    if(self.marqueeType == BQLMarqueeTypeLine) {
        self.isStop = YES;
    }
    else {
        [_timer invalidate];
    }
}

- (void)startAnimation {
    
    switch (self.marqueeType) {
        case BQLMarqueeTypeLine: {
            
            CGSize size = [self.marqueeLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.marqueeLabel.font,NSFontAttributeName, nil]];
            _marqueeLabel.frame = CGRectMake(selfWidth, 0, size.width, selfHeight);
            startPoint = CGPointMake(selfWidth + self.marqueeLabel.frame.size.width / 2, selfHeight / 2);
            endPoint = CGPointMake(- self.marqueeLabel.frame.size.width / 2, selfHeight / 2);
            [self startLineAnimation];
        }
            break;
        case BQLMarqueeTypeRoll:
            [self startRollAnimation];
            break;
            
        default:
            break;
    }
}

- (void)startLineAnimation {
    
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:startPoint];
    [movePath addLineToPoint:endPoint];
    
    CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnimation.path = movePath.CGPath;
    moveAnimation.removedOnCompletion = YES;
    
    moveAnimation.duration = self.marqueeLabel.frame.size.width * animationSpeed * 0.01;
    [moveAnimation setDelegate:self];
    
    [self.marqueeLabel.layer addAnimation:moveAnimation forKey:nil];
}

-(void)pauseLineLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLineLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = layer.timeOffset;
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

// 通过设置_messageLabelOne与_messageLabelTwo的Y值进行变换
- (void)startRollAnimation {
    
    NSInteger messageCount = self.messages.count;
    UILabel *showLabel = [self currentShowLabel];
    UILabel *hideLabel = [self currentHideLabel];
    showLabel.text = self.messages?[NSString stringWithFormat:@"%@",self.messages[currentIndex]]:@"";
    
    currentIndex = currentIndex == messageCount - 1?0:currentIndex + 1;
    if(messageCount > 1) {
        
        hideLabel.text = [NSString stringWithFormat:@"%@",self.messages[currentIndex]];
        CGRect tempOne = showLabel.frame;
        CGRect tempTwo = hideLabel.frame;
        switch (self.rollType) {
            case BQLMarqueeRollTypeUp: {
                
                tempOne.origin.y -= selfHeight;
                tempTwo.origin.y -= selfHeight;
                [UIView animateWithDuration:animationSpeed animations:^{
                    
                    showLabel.frame = tempOne;
                    hideLabel.frame = tempTwo;
                    
                } completion:^(BOOL finished) {
                    
                    showLabel.frame = CGRectMake(Margin, selfHeight, selfWidth - Margin * 2, selfHeight);
                }];
            }
                break;
            case BQLMarqueeRollTypeDown: {
                
                tempOne.origin.y += selfHeight;
                tempTwo.origin.y += selfHeight;
                [UIView animateWithDuration:animationSpeed animations:^{
                    
                    showLabel.frame = tempOne;
                    hideLabel.frame = tempTwo;
                    
                } completion:^(BOOL finished) {
                    
                    showLabel.frame = CGRectMake(Margin, -selfHeight, selfWidth - Margin * 2, selfHeight);
                }];
            }
                break;
                
            default:
                break;
        }
    }
    else {
        [_timer invalidate];
    }
}

- (UILabel *)currentShowLabel {
    
    switch (self.rollType) {
        case BQLMarqueeRollTypeUp: {
            if(self.messageLabelOne.frame.origin.y > 10) {
                return self.messageLabelTwo;
            }
            else {
                return self.messageLabelOne;
            }
        }
            break;
        case BQLMarqueeRollTypeDown: {
            if(self.messageLabelOne.frame.origin.y < -10) {
                return self.messageLabelTwo;
            }
            else {
                return self.messageLabelOne;
            }
        }
            break;
            
        default:
            break;
    }
}

- (UILabel *)currentHideLabel {
    
    switch (self.rollType) {
        case BQLMarqueeRollTypeUp: {
            if(self.messageLabelOne.frame.origin.y > 10) {
                return self.messageLabelOne;
            }
            else {
                return self.messageLabelTwo;
            }
        }
            break;
        case BQLMarqueeRollTypeDown: {
            if(self.messageLabelOne.frame.origin.y < -10) {
                return self.messageLabelOne;
            }
            else {
                return self.messageLabelTwo;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    if (flag && !self.isStop) {
        [self startLineAnimation];
    }
}

- (UILabel *)marqueeLabel {
    
    if(!_marqueeLabel) {
        
        _marqueeLabel = [[UILabel alloc] init];
        _marqueeLabel.text = self.marqueeText?self.marqueeText:@"你还没设置文字哦!";
        _marqueeLabel.font = self.marqueeFont?self.marqueeFont:DefaultTextFont;
        _marqueeLabel.textColor = self.marqueeTextColor?self.marqueeTextColor:BQLRandomColor;
        _marqueeLabel.frame = CGRectMake(selfWidth, 0, selfWidth, selfHeight);
    }
    return _marqueeLabel;
}

- (void)setMessageLabel {
    
    if(!_messageLabelOne) {
        
        _messageLabelOne = [[UILabel alloc] init];
        _messageLabelOne.text = self.messages?[NSString stringWithFormat:@"%@",[self.messages firstObject]]:@"你还没设置文字1";
        _messageLabelOne.font = self.marqueeFont?self.marqueeFont:DefaultTextFont;
        _messageLabelOne.textColor = self.marqueeTextColor?self.marqueeTextColor:BQLRandomColor;
        _messageLabelOne.frame = CGRectMake(Margin, 0, selfWidth - Margin * 2, selfHeight);
    }
    if(!_messageLabelTwo) {
        
        _messageLabelTwo = [[UILabel alloc] init];
        _messageLabelTwo.text = self.messages?(self.messages.count > 1?[NSString stringWithFormat:@"%@",self.messages[1]]:@"你还没设置文字2"):@"你还没设置文字2";
        _messageLabelTwo.font = self.marqueeFont?self.marqueeFont:DefaultTextFont;
        _messageLabelTwo.textColor = self.marqueeTextColor?self.marqueeTextColor:BQLRandomColor;
        _messageLabelTwo.frame = self.rollType == BQLMarqueeRollTypeUp?CGRectMake(Margin, selfHeight, selfWidth - Margin * 2, selfHeight):CGRectMake(Margin, -selfHeight, selfWidth - Margin * 2, selfHeight);
    }
}

- (void)setMarqueeBackgroundColor:(UIColor *)marqueeBackgroundColor {
    
    _marqueeBackgroundColor = marqueeBackgroundColor;
    self.backgroundColor = marqueeBackgroundColor;
}

- (void)setMarqueeFont:(UIFont *)marqueeFont {
    
    _marqueeFont = marqueeFont;
    self.marqueeLabel.font = marqueeFont;
}

- (void)setMarqueeText:(NSString *)marqueeText {
    
    _marqueeText = marqueeText;
    self.marqueeLabel.text = marqueeText;
}

- (void)setMarqueeCustomSpeed:(NSInteger)marqueeCustomSpeed {
    
    _marqueeCustomSpeed = marqueeCustomSpeed;
    animationSpeed = marqueeCustomSpeed;
}

- (void)setMarqueeTextColor:(UIColor *)marqueeTextColor {
    
    _marqueeTextColor = marqueeTextColor;
    self.messageLabelOne.textColor = marqueeTextColor;
    self.messageLabelTwo.textColor = marqueeTextColor;
}

- (void)setIsStop:(BOOL)isStop {
    
    _isStop = isStop;
    if(isStop) [self pauseLineLayer:self.marqueeLabel.layer];
    else [self resumeLineLayer:self.marqueeLabel.layer];
}

- (void)setMessages:(NSArray *)messages {
    
    _messages = messages;
    currentIndex = 0;
    [self startRollAnimation];
}

- (void)setRollType:(BQLMarqueeRollType)rollType {
    
    _rollType = rollType;
    switch (rollType) {
        case BQLMarqueeRollTypeUp: {
            _messageLabelTwo.frame = CGRectMake(Margin, selfHeight, selfWidth - Margin * 2, selfHeight);
        }
            break;
        case BQLMarqueeRollTypeDown: {
            _messageLabelTwo.frame = CGRectMake(Margin, -selfHeight, selfWidth - Margin * 2, selfHeight);
        }
            break;
            
        default:
            break;
    }
}

- (void)setMarqueeTextAlignment:(NSTextAlignment)marqueeTextAlignment {
    
    _marqueeTextAlignment = marqueeTextAlignment;
    _messageLabelOne.textAlignment = marqueeTextAlignment;
    _messageLabelTwo.textAlignment = marqueeTextAlignment;
}

//- (void)appHasGoneInForeground {
//    
//}
//
//- (void)appHasGoneInBackground {
//    
//}
//
//- (void)dealloc {
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
