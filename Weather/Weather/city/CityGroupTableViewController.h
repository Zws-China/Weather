//
//  CityGroupTableViewController.h
//  天气预报
//
//  Created by iMac on 17/3/20.
//  Copyright © 2017年 zws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityGroup.h"

typedef void(^MyBlock)(NSString *cityName);

@interface CityGroupTableViewController : UITableViewController

//block传值
@property(nonatomic,copy)MyBlock block;

@end



