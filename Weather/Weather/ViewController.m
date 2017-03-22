//
//  ViewController.m
//  Weather
//
//  Created by iMac on 17/3/22.
//  Copyright © 2017年 zws. All rights reserved.
//

#import "ViewController.h"

#import "WSLocation.h"
#import "AFNetworking.h"
#import "WeatherModel.h"
#import "WeatherView.h"
#import "CityGroupTableViewController.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


#define widthPix kScreenWidth/320
#define heightPix kScreenHeight/568


@interface ViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView  *backgroudView;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property(nonatomic,strong)WeatherView *weatherV;

//多云动画
@property (nonatomic, strong) NSMutableArray *imageArr;//鸟图片数组
@property (nonatomic, strong) UIImageView *birdImage;//鸟本体
@property (nonatomic, strong) UIImageView *birdRefImage;//鸟倒影
@property (nonatomic, strong) UIImageView *cloudImageViewF;//云
@property (nonatomic, strong) UIImageView *cloudImageViewS;//云
//晴天动画
@property (nonatomic, strong) UIImageView *sunImage;//太阳
@property (nonatomic, strong) UIImageView *sunshineImage;//太阳光
@property (nonatomic, strong) UIImageView *sunCloudImage;//晴天云
//雨天动画
@property (nonatomic, strong) UIImageView *rainCloudImage;//乌云
@property (nonatomic, strong) NSArray *jsonArray;
@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
    
}
- (WeatherView *)weatherV {
    if (!_weatherV) {
        _weatherV = [[WeatherView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    }
    return _weatherV;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //创建背景视图
    [self createBackgroundView];
    
    [self.view addSubview:self.weatherV];
    [self.weatherV.cityBt addTarget:self action:@selector(changeCity) forControlEvents:UIControlEventTouchUpInside];
    
    //获取用户的位置并发送请求
    [self getLoactionAndSendRequest];
    
}

- (void)changeCity {
    
    CityGroupTableViewController *cityCtrl = [[CityGroupTableViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cityCtrl];
    [self presentViewController:nav animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    [cityCtrl setBlock:^void (NSString *cityName){
        
        [weakSelf.weatherV.cityBt setTitle:cityName forState:UIControlStateNormal];
        
        [self sendRequestToServer:cityName];//更换地址重新获取天气
    }];
    
}


//创建背景视图
- (void)createBackgroundView {
    self.backgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_normal.jpg"]];
    _backgroudView.frame = self.view.bounds;
    [self.view addSubview:self.backgroudView];
}


- (void)getLoactionAndSendRequest
{
    
    __weak typeof(self) weakSelf = self;
    [WSLocation getUserLocation:^(double lat, double lon,NSString *cityName) {
        NSLog(@"cityName = %@",cityName);
        CLLocation *location = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
        weakSelf.userLocation = location;
        //定位后查询
        [weakSelf sendRequestToServer:cityName];
        
    }];
}

//发送请求数据
- (void)sendRequestToServer:(NSString *)cityName {
    
    _manager = [AFHTTPSessionManager manager];
    
    NSString *url = [NSString stringWithFormat:@"https://api.thinkpage.cn/v3/weather/daily.json?key=osoydf7ademn8ybv&location=%@&language=zh-Hans&start=0&days=3",cityName];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [_manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSLog(@"response=%@",responseObject);
        
        NSArray *resultArray = responseObject[@"results"];
        for (NSDictionary *dic in resultArray) {
            
            WeatherModel *model = [[WeatherModel alloc]init];
            model.cityName = dic[@"location"][@"name"];
            model.todayDic = (NSDictionary *)[dic[@"daily"] objectAtIndex:0];
            model.tomorrowDic = (NSDictionary *)[dic[@"daily"] objectAtIndex:1];
            model.afterTomorrowDic = (NSDictionary *)[dic[@"daily"] objectAtIndex:2];
            
            self.weatherV.model = model;
            
            [self addAnimationWithType:[dic[@"daily"] objectAtIndex:0][@"code_day"]];
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}



- (void)changeImageAnimated:(UIImage *)image {
    CATransition *transition = [CATransition animation];
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.backgroudView.layer addAnimation:transition forKey:@"a"];
    [self.backgroudView setImage:image];
    
}

- (void)removeAnimationView {
    //先将所有的动画移除
    [self.birdImage removeFromSuperview];
    [self.birdRefImage removeFromSuperview];
    [self.cloudImageViewF removeFromSuperview];
    [self.cloudImageViewS removeFromSuperview];
    [self.sunImage removeFromSuperview];
    [self.sunshineImage removeFromSuperview];
    [self.sunCloudImage removeFromSuperview];
    
    [self.rainCloudImage removeFromSuperview];
    
    for (NSInteger i = 0; i < _jsonArray.count; i++) {
        UIImageView *rainLineView = (UIImageView *)[self.view viewWithTag:100+i];
        [rainLineView removeFromSuperview];
    }
    
}
//添加动画
- (void)addAnimationWithType:(NSString *)weatherType{
    
    //先将所有的动画移除
    [self removeAnimationView];
    
    NSInteger type = [weatherType integerValue];
    if (type >= 0 && type < 4) { //晴天
        [self changeImageAnimated:[UIImage imageNamed:@"bg_sunny_day.jpg"]];
        [self sun];//动画
    }
    else if (type >= 4 && type < 10) { //多云
        [self changeImageAnimated:[UIImage imageNamed:@"bg_normal.jpg"]];
        [self wind];//动画
    }
    else if (type >= 10 && type < 20) { //雨
        [self changeImageAnimated:[UIImage imageNamed:@"bg_rain_day.jpg"]];
        [self rain];
    }
    else if (type >= 20 && type < 26) { //雪
        [self changeImageAnimated:[UIImage imageNamed:@"bg_snow_night.jpg"]];
        
    }
    else if (type >= 26 && type < 30) { //沙尘暴
        [self changeImageAnimated:[UIImage imageNamed:@"bg_sunny_day.jpg"]];
        
    }
    else if (type >= 30 && type < 32) { //雾霾
        [self changeImageAnimated:[UIImage imageNamed:@"bg_haze.jpg"]];
        
    }
    else if (type >= 32 && type < 37) { //风
        [self changeImageAnimated:[UIImage imageNamed:@"bg_sunny_day.jpg"]];
        
    }
    else if (type == 37) { //冷
        [self changeImageAnimated:[UIImage imageNamed:@"bg_fog_day.jpg"]];
        
    }
    else if (type == 38) { //热
        [self changeImageAnimated:[UIImage imageNamed:@"bg_sunny_day.jpg"]];
        
    }
    else if (type == 99) { //未知
        
        
    }
    
    [self.view bringSubviewToFront:self.weatherV];
}

//晴天动画
- (void)sun {
    //太阳
    _sunImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnySun"]];
    CGRect frameSun = _sunImage.frame;
    frameSun.size = CGSizeMake(200, 200*579/612.0);
    _sunImage.frame = frameSun;
    _sunImage.center = CGPointMake(kScreenHeight * 0.1, kScreenHeight * 0.1);
    [self.view addSubview:_sunImage];
    [_sunImage.layer addAnimation:[self sunshineAnimationWithDuration:40] forKey:nil];
    
    //太阳光
    _sunshineImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnySunshine"]];
    CGRect _sunImageFrame = _sunshineImage.frame;
    _sunImageFrame.size = CGSizeMake(400, 400);
    _sunshineImage.frame = _sunImageFrame;
    _sunshineImage.center = CGPointMake(kScreenHeight * 0.1, kScreenHeight * 0.1);
    [self.view addSubview:_sunshineImage];
    [_sunshineImage.layer addAnimation:[self sunshineAnimationWithDuration:40] forKey:nil];
    
    
    //晴天云
    _sunCloudImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnyCloud2"]];
    CGRect frame = _sunCloudImage.frame;
    frame.size = CGSizeMake(kScreenHeight *0.7, kScreenWidth*0.5);
    _sunCloudImage.frame = frame;
    _sunCloudImage.center = CGPointMake(kScreenWidth * 0.25, kScreenHeight*0.5);
    [_sunCloudImage.layer addAnimation:[self birdFlyAnimationWithToValue:@(kScreenWidth+30) duration:50] forKey:nil];
    [self.view addSubview:_sunCloudImage];
    
    
}

//多云动画
- (void)wind {
    
    //鸟 本体
    _birdImage = [[UIImageView alloc]initWithFrame:CGRectMake(-30, kScreenHeight * 0.2, 70, 50)];
    [_birdImage setAnimationImages:self.imageArr];
    _birdImage.animationRepeatCount = 0;
    _birdImage.animationDuration = 1;
    [_birdImage startAnimating];
    [self.view addSubview:_birdImage];
    [_birdImage.layer addAnimation:[self birdFlyAnimationWithToValue:@(kScreenWidth+30) duration:10  ] forKey:nil];
    
    //鸟 倒影
    _birdRefImage = [[UIImageView alloc]initWithFrame:CGRectMake(-30, kScreenHeight * 0.8, 70, 50)];
    [self.backgroudView addSubview:self.birdRefImage];
    [_birdRefImage setAnimationImages:self.imageArr];
    _birdRefImage.animationRepeatCount = 0;
    _birdRefImage.animationDuration = 1;
    _birdRefImage.alpha = 0.4;
    [_birdRefImage startAnimating];
    
    [_birdRefImage.layer addAnimation:[self birdFlyAnimationWithToValue:@(kScreenWidth+30) duration:10] forKey:nil];
    
    
    //云朵效果
    _cloudImageViewF = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnyCloud2"]];
    CGRect frame = _cloudImageViewF.frame;
    frame.size = CGSizeMake(kScreenHeight *0.7, kScreenWidth*0.5);
    _cloudImageViewF.frame = frame;
    _cloudImageViewF.center = CGPointMake(kScreenWidth * 0.25, kScreenHeight*0.7);
    [_cloudImageViewF.layer addAnimation:[self birdFlyAnimationWithToValue:@(kScreenWidth+30) duration:70] forKey:nil];
    [self.view addSubview:_cloudImageViewF];
    
    
    _cloudImageViewS = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnyCloud1"]];
    _cloudImageViewS.frame = self.cloudImageViewF.frame;
    _cloudImageViewS.center = CGPointMake(kScreenWidth * 0.05, kScreenHeight*0.7);
    [_cloudImageViewS.layer addAnimation:[self birdFlyAnimationWithToValue:@(kScreenWidth+30) duration:70] forKey:nil];
    [self.view addSubview:_cloudImageViewS];
    
}

//雨天动画
- (void)rain {
    //加载JSON文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"rainData.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    //将JSON数据转为NSArray或NSDictionary
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    _jsonArray = dict[@"weather"][@"image"];
    
    for (NSInteger i = 0; i < _jsonArray.count; i++) {
        
        NSDictionary *dic = [_jsonArray objectAtIndex:i];
        UIImageView *rainLineView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:dic[@"-imageName"]]];
        rainLineView.tag = 100+i;
        NSArray *sizeArr = [dic[@"-size"] componentsSeparatedByString:@","];
        NSArray *originArr = [dic[@"-origin"] componentsSeparatedByString:@","];
        rainLineView.frame = CGRectMake([originArr[0] integerValue]*widthPix , [originArr[1] integerValue], [sizeArr[0] integerValue], [sizeArr[1] integerValue]);
        [self.view addSubview:rainLineView];
        [rainLineView.layer addAnimation:[self rainAnimationWithDuration:2+i%5] forKey:nil];
        [rainLineView.layer addAnimation:[self rainAlphaWithDuration:2+i%5] forKey:nil];
    }
    
    
    
    //乌云
    _rainCloudImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"night_rain_cloud"]];
    CGRect frame = _rainCloudImage.frame;
    frame.size = CGSizeMake(768/371.0* kScreenWidth*0.5, kScreenWidth*0.5);
    _rainCloudImage.frame = frame;
    _rainCloudImage.center = CGPointMake(kScreenWidth * 0.25, kScreenHeight*0.1);
    [_rainCloudImage.layer addAnimation:[self birdFlyAnimationWithToValue:@(kScreenWidth+30) duration:50] forKey:nil];
    [self.view addSubview:_rainCloudImage];
    
    
    
}




//动画横向移动方法
- (CABasicAnimation *)birdFlyAnimationWithToValue:(NSNumber *)toValue duration:(NSInteger)duration{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.toValue = toValue;
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.repeatCount = MAXFLOAT;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

//动画旋转方法
- (CABasicAnimation *)sunshineAnimationWithDuration:(NSInteger)duration{
    //旋转动画
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = MAXFLOAT;//你可以设置到最大的整数值
    rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    return rotationAnimation;
}

//下雨动画方法
- (CABasicAnimation *)rainAnimationWithDuration:(NSInteger)duration{
    
    CABasicAnimation* caBaseTransform = [CABasicAnimation animation];
    caBaseTransform.duration = duration;
    caBaseTransform.keyPath = @"transform";
    caBaseTransform.repeatCount = MAXFLOAT;
    caBaseTransform.removedOnCompletion = NO;
    caBaseTransform.fillMode = kCAFillModeForwards;
    caBaseTransform.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-170, -620, 0)];
    caBaseTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(kScreenHeight/2.0*34/124.0, kScreenHeight/2, 0)];
    
    return caBaseTransform;
    
}
//透明度动画
- (CABasicAnimation *)rainAlphaWithDuration:(NSInteger)duration {
    
    CABasicAnimation *showViewAnn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showViewAnn.fromValue = [NSNumber numberWithFloat:1.0];
    showViewAnn.toValue = [NSNumber numberWithFloat:0.1];
    showViewAnn.duration = duration;
    showViewAnn.repeatCount = MAXFLOAT;
    showViewAnn.fillMode = kCAFillModeForwards;
    showViewAnn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    showViewAnn.removedOnCompletion = NO;
    
    return showViewAnn;
}


//--getter----------------------------------------------------
-(NSMutableArray *)imageArr {
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
        for (int i = 1; i < 9; i++) {
            NSString *fileName = [NSString stringWithFormat:@"ele_sunnyBird%d.png",i];
            NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [_imageArr addObject:image];
        }
        
    }
    return _imageArr;
}

//----------------------------------------------------------


#pragma mark Will Show ViewController
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL needHideNaivgaionBar = NO;
    
    if ([viewController isKindOfClass: [self class]]) {
        needHideNaivgaionBar = YES;
    }
    
    
    [self.navigationController setNavigationBarHidden:needHideNaivgaionBar animated: animated];
}




@end
