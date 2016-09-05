//
//  ViewController.m
//  跑马灯
//
//  Created by 毕青林 on 16/8/29.
//  Copyright © 2016年 毕青林. All rights reserved.
//

#import "ViewController.h"
#import "BQLMarquee.h"

@interface ViewController ()
{
    BQLMarquee *lineMarquee;
    BOOL stop;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 所有颜色不设置的话就是默认随机生成
    /******************************************************************************/
    lineMarquee = [[BQLMarquee alloc] initWithType:BQLMarqueeTypeLine Text:@"哈哈哈哈哈哈哈" Roll:nil];
    lineMarquee.marqueeCustomSpeed = 10;
    lineMarquee.frame = CGRectMake(10, 70, self.view.frame.size.width - 80, 40);
    [self.view addSubview:lineMarquee];
    [lineMarquee start];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(lineMarquee.frame.origin.x + lineMarquee.frame.size.width + 10, 70, 50, 40)];
    [self.view addSubview:button];
    [button setTitle:@"点我暂停" forState:0];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:[UIColor blackColor] forState:0];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    
    /******************************************************************************/
    BQLMarquee *lineMarquee1 = [[BQLMarquee alloc] initWithFrame:CGRectMake(10, lineMarquee.frame.origin.y + lineMarquee.frame.size.height + 10, self.view.frame.size.width - 20, 40) Type:BQLMarqueeTypeLine Text:@"恭喜你成为我们的幸运观众!" Roll:nil];
    [self.view addSubview:lineMarquee1];
    lineMarquee1.marqueeBackgroundColor = [UIColor whiteColor];
    lineMarquee1.marqueeTextColor = [UIColor blueColor];
    lineMarquee1.marqueeFont = [UIFont systemFontOfSize:16];
    [lineMarquee1 start];
    
    /******************************************************************************/
    BQLMarquee *roll0 = [[BQLMarquee alloc] initWithFrame:CGRectMake(10, lineMarquee1.frame.origin.y + lineMarquee1.frame.size.height + 10, self.view.frame.size.width - 20, 40) Type:BQLMarqueeTypeRoll Text:nil Roll:@[@"这是一个公告,请注意"]];
    [self.view addSubview:roll0];
    roll0.didClickAtIndexBlock = ^(NSInteger index) {
        
        NSLog(@"点击了第%ld个",index);
    };
    
    /******************************************************************************/
    BQLMarquee *roll1 = [[BQLMarquee alloc] initWithType:BQLMarqueeTypeRoll Text:nil Roll:@[@"蒙多~想去就去哪",@"无形之刃，最为致命",@"提莫队长，正在待命"]];
    roll1.frame = CGRectMake(10, roll0.frame.origin.y + roll0.frame.size.height + 10, self.view.frame.size.width - 20, 40);
    roll1.marqueeTextAlignment = NSTextAlignmentCenter;
    roll1.rollType = BQLMarqueeRollTypeUp;
    [self.view addSubview:roll1];
    roll1.didClickAtIndexBlock = ^(NSInteger index) {
        
        NSLog(@"点击了第%ld个",index);
    };
    
    /******************************************************************************/
    BQLMarquee *roll2 = [[BQLMarquee alloc] initWithFrame:CGRectMake(10, roll1.frame.origin.y + roll1.frame.size.height + 10, self.view.frame.size.width - 20, 40) Type:BQLMarqueeTypeRoll Text:nil Roll:@[@"犯我德邦者，虽远必诛",@"快去找点乐子吧",@"只要998，让你爽到家",@"还有谁？还有谁！"]];
    [self.view addSubview:roll2];
    roll2.rollType = BQLMarqueeRollTypeDown;
    roll2.marqueeTextColor = [UIColor redColor];
    roll2.didClickAtIndexBlock = ^(NSInteger index) {
        
        NSLog(@"点击了第%ld个",index);
    };
    
    /******************************************************************************/
    BQLMarquee *roll3 = [[BQLMarquee alloc] initWithFrame:CGRectMake(10, roll2.frame.origin.y + roll2.frame.size.height + 10, self.view.frame.size.width - 20, 40) Type:BQLMarqueeTypeRoll Text:nil Roll:@[@"我最喜欢薛之谦的两首歌",@"一首叫：演员",@"另一首叫：丑八怪"]];
    [self.view addSubview:roll3];
    roll3.marqueeTextAlignment = NSTextAlignmentRight;
    roll3.didClickAtIndexBlock = ^(NSInteger index) {
        
        NSLog(@"点击了第%ld个",index);
    };
}

- (void)click {
    
    stop = !stop;
    if(stop) [lineMarquee stop];
    else [lineMarquee restart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
