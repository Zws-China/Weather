//
//  WSLocation.m
//  天气预报
//
//  Created by iMac on 17/3/20.
//  Copyright © 2017年 zws. All rights reserved.
//

#import "WSLocation.h"
#import <UIKit/UIKit.h>

@interface WSLocation ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) saveLocationBlock savelocationBlock;
@property (nonatomic, strong) NSString *cityName;
@end

@implementation WSLocation

+ (id)sharedLoactionManager{
    static WSLocation *locationManager = nil;
    if (!locationManager) {
        locationManager = [[WSLocation alloc]init];
    }
    return locationManager;
}
//重写init方法初始化manager对象/征求用户同意
- (instancetype)init
{
    if (self = [super init]) {
        self.manager = [[CLLocationManager alloc]init];
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [self.manager requestWhenInUseAuthorization];
        }
        self.manager.delegate = self;
    }
    return self;
}

+ (void)getUserLocation:(saveLocationBlock)locationBlock
{
    
    WSLocation *locationMangaer = [WSLocation sharedLoactionManager];
    return[locationMangaer getUserLoaction:locationBlock];
}

- (void)getUserLoaction:(saveLocationBlock)locationBlock
{
    if (![CLLocationManager locationServicesEnabled]) {
        return;
    }
    if ([CLLocationManager locationServicesEnabled]  //确定用户的位置服务启用
        &&[CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
        //位置服务是在设置中禁用
        _savelocationBlock = [locationBlock copy];
        _savelocationBlock(39.9110130000,116.4135540000,@"北京");

        
        return;
    }
    _savelocationBlock = [locationBlock copy];
    self.manager.distanceFilter = 100;
    [self.manager startUpdatingLocation];
}

#pragma mark -
#pragma mark - CLLocatoinManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            NSString *cityName = placemarks.lastObject.addressDictionary[@"City"];
            NSString *str = [cityName substringToIndex:cityName.length -1];
            _savelocationBlock(location.coordinate.latitude,location.coordinate.longitude,str);
            
        }
        
    }];
    
}
@end
