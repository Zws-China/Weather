//
//  WSLocation.h
//  天气预报
//
//  Created by iMac on 17/3/20.
//  Copyright © 2017年 zws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef void(^saveLocationBlock)(double lat,double lon ,NSString *cityName);

@interface WSLocation : NSObject


+ (void)getUserLocation:(saveLocationBlock)locationBlock;


@end
