//
//  AppDelegate.m
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"

#include "NotficationDef.h"
#include "ErrorCheck.h"

@interface AppDelegate ()

-(void) _sendActionQueryDeviceState: (NSString*)deviceId;
-(void) _sendActionSetDeviceValue:(NSString *)deviceId :(NSInteger)index :(NSInteger)isOn;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// register notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onQueryDeviceValue:) name:NOTIFY_QUERY_DEVICE_STATE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSetDeviceValue:) name:NOTIFY_SET_DEVICE_VALUE object:nil];
	
	// init upnp
	_controlPointRef = new PLT_CtrlPoint();
	_controlPointRef->AddListener(&_deviceManager);
	
	_upnp.AddCtrlPoint(_controlPointRef);
	_upnp.Start();
	
	// init master view
	MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
	self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_upnp.Stop();
	_upnp.RemoveCtrlPoint(_controlPointRef);
	
	_controlPointRef->RemoveListener(&_deviceManager);
	_controlPointRef = NULL;
}

- (void)onQueryDeviceValue: (NSNotification*) notification;
{
	NSString* deviceId = [[notification userInfo] objectForKey:PARAM_DEVICE_ID];
	
	[self _sendActionQueryDeviceState:deviceId];
}

- (void)onSetDeviceValue: (NSNotification*) notification
{
	NSString* deviceId = [[notification userInfo] objectForKey:PARAM_DEVICE_ID];
	NSNumber* switchIndex = [[notification userInfo] objectForKey:PARAM_SWITCH_INDEX];
	NSNumber* switchValue = [[notification userInfo] objectForKey:PARAM_SWITCH_VALUE];
	
	[self _sendActionSetDeviceValue:deviceId :[switchIndex integerValue] :[switchValue integerValue]];
}

- (void)_sendActionQueryDeviceState:(NSString *)deviceId
{
	{
		PLT_DeviceDataReference destDevice = _deviceManager.QueryDevice([deviceId UTF8String]);
		XASSERT(!destDevice.IsNull());
		
		// make action
		PLT_ActionReference action;
		_controlPointRef->CreateAction(
									   destDevice,
									   SERVICE_TYPE,
									   ACTION_NAME_QUERY_STATE,
									   action);
		ERROR_CHECK_BOOL(!action.IsNull());
		
		NPT_Result nptRet = _controlPointRef->InvokeAction(action, NULL);
		ERROR_CHECK_BOOL(NPT_SUCCESS == nptRet);
	}
	
Exit0:
	;
}

- (void)_sendActionSetDeviceValue:(NSString *)deviceId :(NSInteger)index :(NSInteger)isOn
{
	{
		PLT_DeviceDataReference destDevice = _deviceManager.QueryDevice([deviceId UTF8String]);
		XASSERT(!destDevice.IsNull());
		
		// make action
		PLT_ActionReference action;
		_controlPointRef->CreateAction(
									   destDevice,
									   SERVICE_TYPE,
									   ACTION_NAME_SET_VALUE,
									   action);
		ERROR_CHECK_BOOL(!action.IsNull());
		
		NPT_Result nptRet = action->SetArgumentValue(ACTION_ARG_INDEX, [[[NSNumber numberWithInteger:index + 4] stringValue] UTF8String]);
        ERROR_CHECK_BOOL(NPT_SUCCESS == nptRet);
        nptRet = action->SetArgumentValue(ACTION_ARG_VALUE, [[[NSNumber numberWithInteger:isOn] stringValue] UTF8String]);
        ERROR_CHECK_BOOL(NPT_SUCCESS == nptRet);
		
		nptRet = _controlPointRef->InvokeAction(action, NULL);
		ERROR_CHECK_BOOL(NPT_SUCCESS == nptRet);
	}
	
Exit0:
	;
}

@end
