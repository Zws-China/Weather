//
//  WeatherView.h
//  海绵城市
//
//  Created by iMac on 17/2/28.
//  Copyright © 2017年 zws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherModel.h"


@interface WeatherView : UIImageView

@property (nonatomic,strong)WeatherModel *model;
@property (nonatomic,strong)UIButton *cityBt;


@end
