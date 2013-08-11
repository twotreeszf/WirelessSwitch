//
//  MasterViewController.h
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import <UIKit/UIKit.h>

#include <string>
#include <vector>

@class DetailViewController;

struct DeviceInfo
{
	std::string deviceId;
	std::string deviceName;
};

@interface MasterViewController : UITableViewController <UINavigationControllerDelegate>
{
	std::vector<DeviceInfo>	_deviceList;	
}

@property (strong, nonatomic) DetailViewController *detailViewController;

- (void)onDeviceFounded: (NSNotification*) notification;
- (void)onDeviceLost: (NSNotification*) notification;

@end
