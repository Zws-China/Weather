//
//  WeatherView.m
//  海绵城市
//
//  Created by iMac on 17/2/28.
//  Copyright © 2017年 zws. All rights reserved.
//

#import "WeatherView.h"



@implementation WeatherView

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


#define widthPix kScreenWidth/320
#define heightPix kScreenHeight/568

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        [self creatUI];
    }
    
    return self;
}

- (void)creatUI {

    _cityBt = [UIButton buttonWithType:UIButtonTypeCustom];//城市名称
    _cityBt.frame = CGRectMake(80, 20, kScreenWidth-160, 44);
    _cityBt.tag = 10;
    _cityBt.titleLabel.textAlignment = NSTextAlignmentCenter;
    _cityBt.titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [self addSubview:_cityBt];
    
    UIImageView *weatherImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2-50*widthPix, CGRectGetMaxY(_cityBt.frame)+30, 100*widthPix, 100*heightPix)];//当前天气图标
    weatherImg.tag = 11;
    [self addSubview:weatherImg];
    
    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, CGRectGetMaxY(weatherImg.frame), (kScreenWidth-100), 40*heightPix)];
    tempLabel.font = [UIFont boldSystemFontOfSize:30*heightPix];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.textColor = [UIColor whiteColor];
    tempLabel.tag = 12;
    [self addSubview:tempLabel];
    
    
    for (NSInteger i = 0; i < 2; i++) {
        
        UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth/2-100*widthPix)/2+kScreenWidth/2*i, CGRectGetMaxY(tempLabel.frame)+50, 100*widthPix, 30*heightPix)];
        dayLabel.font = [UIFont boldSystemFontOfSize:15*heightPix];
        dayLabel.textColor = [UIColor whiteColor];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.tag = 20+i;
        [self addSubview:dayLabel];
        
        UIImageView *smallWeatherImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth/2-70*widthPix)/2+kScreenWidth/2*i, CGRectGetMaxY(dayLabel.frame), 70*widthPix, 70*heightPix)];
        smallWeatherImg.tag = 30+i;
        [self addSubview:smallWeatherImg];
        
        UILabel *samllTempLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth/2-100*widthPix)/2+kScreenWidth/2*i, CGRectGetMaxY(smallWeatherImg.frame), 100*widthPix, 30*heightPix)];
        samllTempLabel.font = [UIFont boldSystemFontOfSize:15*heightPix];
        samllTempLabel.textColor = [UIColor whiteColor];
        samllTempLabel.tag = 40+i;
        samllTempLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:samllTempLabel];
        
        
        UILabel *windLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth/2-100*widthPix)/2+kScreenWidth/2*i, CGRectGetMaxY(samllTempLabel.frame), 100*widthPix, 30*heightPix)];
        windLabel.font = [UIFont boldSystemFontOfSize:15*heightPix];
        windLabel.textColor = [UIColor whiteColor];
        windLabel.tag = 50+i;
        windLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:windLabel];
    }
    
    
}

-(void)setModel:(WeatherModel *)model {
    _model = model;
    
    UIButton *cityBt = (UIButton *)[self viewWithTag:10];
    UIImageView *weatherImg = (UIImageView *)[self viewWithTag:11];
    UILabel *tempLabel = (UILabel *)[self viewWithTag:12];
    
    UILabel *dayLabel1 = (UILabel *)[self viewWithTag:20];
    UILabel *dayLabel2 = (UILabel *)[self viewWithTag:21];
    UIImageView *smallWeatherImg1 = (UIImageView *)[self viewWithTag:30];
    UIImageView *smallWeatherImg2 = (UIImageView *)[self viewWithTag:31];
    UILabel *samllTempLabel1 = (UILabel *)[self viewWithTag:40];
    UILabel *samllTempLabel2 = (UILabel *)[self viewWithTag:41];
    UILabel *windLabel1 = (UILabel *)[self viewWithTag:50];
    UILabel *windLabel2 = (UILabel *)[self viewWithTag:51];

    
    [cityBt setTitle:model.cityName forState:UIControlStateNormal];
//    weatherImg.image = [UIImage imageNamed:[model.todayDic objectForKey:@"code_day"]];
    [self changeImageAnimatedWithView:weatherImg AndImage: [UIImage imageNamed:[model.todayDic objectForKey:@"code_day"]]];

    
    tempLabel.text = [NSString stringWithFormat:@"%@℃ / %@℃",[model.todayDic objectForKey:@"high"],[model.todayDic objectForKey:@"low"]];
    dayLabel1.text =[model.tomorrowDic objectForKey:@"date"];
//    smallWeatherImg1.image = [UIImage imageNamed:[model.tomorrowDic objectForKey:@"code_day"]];
    [self changeImageAnimatedWithView:smallWeatherImg1 AndImage: [UIImage imageNamed:[model.tomorrowDic objectForKey:@"code_day"]]];
    
    samllTempLabel1.text = [NSString stringWithFormat:@"%@℃/%@℃",[model.tomorrowDic objectForKey:@"high"],[model.tomorrowDic objectForKey:@"low"]];
    windLabel1.text = [NSString stringWithFormat:@"%@风 风速:%@",[model.tomorrowDic objectForKey:@"wind_direction" ],[model.tomorrowDic objectForKey:@"wind_speed"]];

    
    dayLabel2.text =[model.afterTomorrowDic objectForKey:@"date"];
//    smallWeatherImg2.image = [UIImage imageNamed:[model.afterTomorrowDic objectForKey:@"code_day"]];
    [self changeImageAnimatedWithView:smallWeatherImg2 AndImage: [UIImage imageNamed:[model.afterTomorrowDic objectForKey:@"code_day"]]];

    samllTempLabel2.text = [NSString stringWithFormat:@"%@℃/%@℃",[model.afterTomorrowDic objectForKey:@"high"],[model.afterTomorrowDic objectForKey:@"low"]];
    windLabel2.text = [NSString stringWithFormat:@"%@风 风速:%@",[model.afterTomorrowDic objectForKey:@"wind_direction" ],[model.afterTomorrowDic objectForKey:@"wind_speed"]];
}

//动画切换天气图标
- (void)changeImageAnimatedWithView:(UIImageView *)imageV AndImage:(UIImage *)image {
    CATransition *transition = [CATransition animation];
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [imageV.layer addAnimation:transition forKey:@"a"];
    [imageV setImage:image];
    
}

@end
