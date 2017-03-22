//
//  WeatherModel.h
//  海绵城市
//
//  Created by iMac on 17/2/28.
//  Copyright © 2017年 zws. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherModel : NSObject

@property(nonatomic,strong)NSString *cityName;
@property(nonatomic,strong)NSDictionary *todayDic;
@property(nonatomic,strong)NSDictionary *tomorrowDic;
@property(nonatomic,strong)NSDictionary *afterTomorrowDic;

@end
