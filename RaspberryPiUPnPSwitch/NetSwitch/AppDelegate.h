//
//  AppDelegate.h
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <Platinum/Platinum.h>
#include "UPnPDeviceManager/UPnPDeviceManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
	PLT_UPnP				_upnp;
	PLT_CtrlPointReference	_controlPointRef;
	CUPnPDeviceManager		_deviceManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

- (void)onQueryDeviceValue: (NSNotification*) notification;
- (void)onSetDeviceValue: (NSNotification*) notification;

@end
