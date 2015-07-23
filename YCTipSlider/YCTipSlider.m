//
//  YCTipSlider.m
//  YCTipSlider
//
//  Created by kk on 14-11-26.
//  Copyright (c) 2014年 kk. All rights reserved.
//

#import "YCTipSlider.h"
#import <AudioToolbox/AudioToolbox.h>

@interface YCTipSlider ()

@property (nonatomic,strong) UIView * holdView;

@property (nonatomic,strong) UIImage * thumbBgImg;
@property (nonatomic,strong) UIImage * thumbLabelBgImg;
@property (nonatomic,strong) UIImageView * thumbLabelBgImgView;

@end


@implementation YCTipSlider
{
    float speratePercent;
    BOOL isCanScroll;
    float step;
    
    UILabel * leftLabel;
    UILabel * rightLabel;
}



-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        isCanScroll = NO;
        _surpassTaxiFlag = NO;
        
        
        self.holdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.holdView.backgroundColor = [UIColor purpleColor];
        [self addSubview:self.holdView];

        //计算出租车预估费用和Max最大费用的比例
        speratePercent = 0.6;
        
        self.trackBgImageViewNorml = [[UIImageView alloc] init];
        self.trackBgImageViewNorml.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
        [self.holdView addSubview:self.trackBgImageViewNorml];
        
        self.trackBgImageViewTaxiNormal = [[UIImageView alloc] init];
        self.trackBgImageViewTaxiNormal.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
        
        //设置trackBgImageViewTaxiNormal 左右两边的价格提示
        leftLabel = [[UILabel alloc] init];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.text = @"0";
        [leftLabel sizeToFit];
        [self.trackBgImageViewTaxiNormal addSubview:leftLabel];
        
        rightLabel = [[UILabel alloc] init];
        rightLabel.text = [NSString stringWithFormat:@"%d",60];
        rightLabel.backgroundColor = [UIColor clearColor];
        [rightLabel sizeToFit];
        [self.trackBgImageViewTaxiNormal addSubview:rightLabel];
        [self.holdView addSubview:self.trackBgImageViewTaxiNormal];

        
        self.trackBgImageViewHighlighted = [[UIImageView alloc] init];
        self.trackBgImageViewHighlighted.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:73.0/255.0 blue:73/255.0 alpha:1];
        [self.holdView addSubview:self.trackBgImageViewHighlighted];
        
        
        //滑动按钮
        self.thumbImgV = [[UIImageView alloc] init];
        self.thumbBgImg = [UIImage imageNamed:@"thumb_bg_0yuan"];
        self.thumbImgV.image = self.thumbBgImg;
//        [self addLongPressed:self.thumbImgV];
        [self.holdView addSubview:self.thumbImgV];

        
        
        
        //价格Lable的背景
        self.thumbLabelBgImgView = [[UIImageView alloc] init];
        self.thumbLabelBgImg = [UIImage imageNamed:@"thumb_label_bg_top"];
        self.thumbLabelBgImgView.image = self.thumbLabelBgImg;
        self.thumbLabelBgImgView.alpha = 0;
        self.thumbLabelBgImgView.frame = CGRectMake((self.thumbImgV.frame.size.width - self.thumbLabelBgImg.size.width/2.0)/2.0+2.7,
                                                    0 -self.thumbImgV.center.y - self.thumbLabelBgImg.size.height+0.1,
                                                    self.thumbLabelBgImg.size.width,
                                                    self.thumbLabelBgImg.size.height);
        
        
        self.thumbLabel = [[UILabel alloc] init];
        self.thumbLabel.backgroundColor = [UIColor clearColor];
        self.thumbLabel.font = [UIFont systemFontOfSize:14];
        self.thumbLabel.textAlignment = NSTextAlignmentCenter;
        self.thumbLabel.text = @"0元";
        self.thumbLabel.alpha = 0;
        self.thumbLabel.frame = CGRectMake(1, 1, self.thumbLabelBgImgView.frame.size.width-2, self.thumbLabelBgImgView.frame.size.height-2);
        [self.thumbLabelBgImgView addSubview:self.thumbLabel];
        [self.thumbImgV addSubview:self.thumbLabelBgImgView];
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    //根据thumbImage的大小计算self.thumbImgV的frame
    CGRect thumbImgVFrame = CGRectMake(0, (CGRectGetHeight(self.bounds) - self.thumbBgImg.size.height)/2.0, self.thumbBgImg.size.width, self.thumbBgImg.size.height);
    self.thumbImgV.frame = thumbImgVFrame;

    
    //设置trackBgImageViewNorml、trackBgImageViewHighlighted、trackBgImageViewTaxiNormal的frame
    self.trackBgImageViewNorml.frame = CGRectMake(CGRectGetWidth(thumbImgVFrame)/2.0,
                                                  0,
                                                  CGRectGetWidth(self.bounds)-CGRectGetWidth(thumbImgVFrame),
                                                  CGRectGetHeight(self.bounds));
    self.trackBgImageViewHighlighted.frame = self.trackBgImageViewNorml.frame;
    
    
    self.trackBgImageViewTaxiNormal.frame = CGRectMake(CGRectGetWidth(thumbImgVFrame)/2.0,
                                                       0,
                                                       CGRectGetWidth(self.trackBgImageViewNorml.frame) * speratePercent,
                                                       CGRectGetHeight(self.bounds));;
    //设置left 和right两边的Label
    leftLabel.frame = CGRectMake(0, 0, 10, CGRectGetHeight(self.trackBgImageViewTaxiNormal.frame));
    rightLabel.frame = CGRectMake(CGRectGetWidth(self.trackBgImageViewTaxiNormal.frame) -20, 0, 20, CGRectGetHeight(leftLabel.frame));
    
    
    //设置thumbImgV的中心位置
//    CGPoint thumbImgVCenter = CGPointMake([self computeXWithValue:self.miniValue], self.trackBgImageViewNorml.center.y);
//    self.thumbImgV.center =  thumbImgVCenter;
    [self updateTrack];
    
}


-(void)updateTrack
{
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc] init];
    CGFloat thumbMidX = CGRectGetMidX([self convertRect:self.thumbImgV.frame fromView:self.holdView]);
    CGRect maskRect =  CGRectMake(0, 0, thumbMidX, CGRectGetHeight(self.trackBgImageViewNorml.frame));
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, maskRect);
    [maskLayer setPath:path];
    CGPathRelease(path);
    self.trackBgImageViewHighlighted.layer.mask = maskLayer;
}


- (void)drawRect:(CGRect)rect {
    
    [self updateTrack];
}

-(void)setMiniValue:(float)miniValue
{
    _miniValue = miniValue;
}

-(void)setMaxValue:(float)maxValue
{
    _maxValue = maxValue;
}

-(void)setTaxiValue:(float)taxiValue
{
    _taxiValue = taxiValue;
}

//根据当前价格计算thumb的x位置
-(float)computeXWithValue:(float)value
{
    float totalWidth = CGRectGetWidth(self.bounds);
    return totalWidth * (value - self.miniValue) / (self.maxValue - self.miniValue);
}

//根据thumb的x位置计算当前的价格
-(float)getValueWithX:(float) x
{
    float totalWidth = CGRectGetWidth(self.bounds);
    float currentPercent = self.thumbImgV.center.x / totalWidth;
    
    if (currentPercent <= speratePercent) {
        return self.miniValue + (self.taxiValue - self.miniValue)/speratePercent * currentPercent;
    }
    
   return self.taxiValue + ((self.maxValue - self.taxiValue)/(1 - speratePercent))*(currentPercent - speratePercent);
}

-(BOOL)isSurpassTaxiPrice
{
    float currentPercent = self.thumbImgV.center.x / CGRectGetWidth(self.bounds);
    
    if (currentPercent >= speratePercent) {
        return YES;
    }
    return NO;
}

#pragma mark --- animation --

//-(void)addLongPressed:(UIImageView *)view
//{
//    [view setUserInteractionEnabled:YES];
//    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
//    longPressGr.minimumPressDuration = 1.0;
//    [view addGestureRecognizer:longPressGr];
//}
//
//-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
//{
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        [self showThumbLabel];
//    }
//    else if(gesture.state == UIGestureRecognizerStateEnded) {
//        [self hideThumbLabel];
//    }
//}


-(void)showThumbLabel
{
    self.thumbImgV.image = [UIImage imageNamed:@"thumb_bg_pause"];
    [UIView animateWithDuration:0.2 animations:^{
        self.thumbLabelBgImgView.alpha = 1;
        self.thumbLabel.alpha = 1;
    }];
}

-(void)hideThumbLabel:(long int)value
{
    
    self.thumbImgV.image = [UIImage imageNamed:@"thumb_bg_paused"];
    if (value == 0) {
        self.thumbImgV.image = [UIImage imageNamed:@"thumb_bg_0yuan"];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.thumbLabel.alpha = 0;
        self.thumbLabelBgImgView.alpha = 0;

    }];
}

#pragma mark --- 提示音乐 ---
-(void)playSound
{
    NSString *urlPath = [[NSBundle mainBundle] pathForResource:@"yd" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:urlPath];
    SystemSoundID ID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
    AudioServicesPlaySystemSound(ID);
}

#pragma mark -- touch delegate ---

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.thumbImgV.frame, touchPoint)) {
        isCanScroll = YES;
        
    }else{
        isCanScroll = NO;
    }
    return YES;
}


-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!isCanScroll) {
        return YES;
    }
    CGPoint touchPoint = [touch locationInView:self];
    
    //使x规范在正确的范围内
    float thumbImageVPoint_X = MIN(MAX(touchPoint.x, [self computeXWithValue:self.miniValue]), [self computeXWithValue:self.maxValue]);
    self.surpassTaxiFlag = [self isSurpassTaxiPrice];
    self.thumbImgV.center = CGPointMake(lroundf(thumbImageVPoint_X),self.thumbImgV.center.y);
    self.currentValue = [self getValueWithX:self.thumbImgV.center.x];
    self.thumbLabel.text = [NSString stringWithFormat:@"%ld元",lroundf(self.currentValue)];
    [self playSound];
    [self showThumbLabel];
    [self updateTrack];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
 
    isCanScroll = NO;
    CGPoint touchPoint = [touch locationInView:self];
    float thumbImageVPoint_X = MIN(MAX(touchPoint.x, [self computeXWithValue:self.miniValue]), [self computeXWithValue:self.maxValue]);
    self.currentValue = [self getValueWithX:thumbImageVPoint_X];
    long int currentValue = lroundf(self.currentValue);
    [self hideThumbLabel:currentValue];
}



@end

