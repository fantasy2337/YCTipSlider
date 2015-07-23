//
//  YCTipSlider.h
//  YCTipSlider
//
//  Created by kk on 14-11-26.
//  Copyright (c) 2014年 kk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCTipSlider : UIControl


@property (nonatomic,strong) UIImageView * thumbImgV;
@property (nonatomic,strong) UIImageView * trackBgImageViewNorml;
@property (nonatomic,strong) UIImageView * trackBgImageViewHighlighted;
@property (nonatomic,strong) UIImageView * trackBgImageViewTaxiNormal;
@property (nonatomic,strong) UILabel * thumbLabel;


@property (nonatomic,assign) float miniValue;
@property (nonatomic,assign) float maxValue;
@property (nonatomic,assign) float taxiValue;
@property (nonatomic,assign) float currentValue;

@property (nonatomic,assign) BOOL surpassTaxiFlag;
@end
