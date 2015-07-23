//
//  ViewController.m
//  YCTipSlider
//
//  Created by kk on 14-11-26.
//  Copyright (c) 2014年 kk. All rights reserved.
//

#import "ViewController.h"
#import "YCTipSlider.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YCTipSlider * slider = [[YCTipSlider alloc] initWithFrame:CGRectMake(50, 100, 200, 20)];
    slider.miniValue = .0f;
    slider.maxValue = 1000.0f;
    slider.taxiValue = 800.f;
    
//    UIView * tipView = [[UIView alloc] initWithFrame:CGRectMake(130, 200, 80, 20)];
//    tipView.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:tipView];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"xinlang" forState:UIControlStateNormal];
    btn.frame = CGRectMake(130, 200, 80, 20);
    [btn  addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    
    
    [slider addTarget:self action:@selector(prit:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    
    
    
}

-(void)btnPressed:(id)obj
{
    
}


-(void)prit:(id)obj
{
    YCTipSlider * slider = (YCTipSlider *)obj;
    NSLog(@"-------currentValue - %lf",slider.currentValue);
    NSLog(@"-------flag = %d",slider.surpassTaxiFlag);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
