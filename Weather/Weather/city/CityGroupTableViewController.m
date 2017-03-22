//
//  CityGroupTableViewController.m
//  天气预报
//
//  Created by iMac on 17/3/20.
//  Copyright © 2017年 zws. All rights reserved.
//

#import "CityGroupTableViewController.h"

@interface CityGroupTableViewController ()

@property (nonatomic, strong) NSArray *cityGroupArray;

@end

@implementation CityGroupTableViewController

- (NSArray *)cityGroupArray {
    if (!_cityGroupArray) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"cityGroups.plist" ofType:nil];
        NSArray *cityGroupArray = [NSArray arrayWithContentsOfFile:plistPath];
        //所有字典对象转成模型对象
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dic in cityGroupArray) {
            //声明一个空的CityGroup对象
            CityGroup *cityGroup = [CityGroup new];
            //KVC绑定模型对象属性和字典key的关系
            [cityGroup setValuesForKeysWithDictionary:dic];
            [mutableArray addObject:cityGroup];
        }
        _cityGroupArray = mutableArray;
    }
    return _cityGroupArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"城市列表";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(clickBackItem)];
    self.navigationItem.leftBarButtonItem = backItem;
    

}

- (void)clickBackItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cityGroupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CityGroup *cityGroup = self.cityGroupArray[section];
    return cityGroup.cities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    // Configure the cell...
    CityGroup *cityGroup = self.cityGroupArray[indexPath.section];
    cell.textLabel.text = cityGroup.cities[indexPath.row];
    
    return cell;
}
//返回section的头部文本
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CityGroup *cityGroup = self.cityGroupArray[section];
    return cityGroup.title;
}

//返回tableViewIndex数组
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //方式一
    //    NSMutableArray *titleMutablArray = [NSMutableArray array];
    //    for (TRCityGroup *cityGroup in self.cityGroupArray) {
    //        [titleMutablArray addObject:cityGroup.title];
    //    }
    //    return [titleMutablArray copy];
    //方式二
    return [self.cityGroupArray valueForKeyPath:@"title"];
    
}

//选中那一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityGroup *cityGroup = self.cityGroupArray[indexPath.section];
    NSString *cityName = cityGroup.cities[indexPath.row];
    //发送通知，包含参数
    //回调Block
    if (_block != nil) {
        
        _block(cityName);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:^{
//        [self showViewController:[UIApplication sharedApplication]  sender:nil];
//    }];
    
}



@end
