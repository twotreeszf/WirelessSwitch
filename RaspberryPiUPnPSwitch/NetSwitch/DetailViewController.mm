//
//  DetailViewController.m
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import "DetailViewController.h"
#import "NotficationDef.h"

#include "ErrorCheck.h"
#include "Misc/JsonCpp/json.h"

#define TAG_RELAY_ON				(0x01 << 8)
#define TAG_RELAY_OFF				(0x01 << 9)

#define TAG_RELAY_1					1
#define TAG_RELAY_2					2
#define TAG_RELAY_3					3
#define TAG_RELAY_4					4

@interface DetailViewController()

- (void)_configureButtonWithTag:(int)tag;
- (void)_queryDeviceState;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
        _detailItem = newDetailItem;
	
	[self _queryDeviceState];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReturnDeviceState:) name:NOTIFY_RETURN_DEVICE_STATE object:nil];
	
	_imgOn = [UIImage imageNamed:@"on"];
	_imgOff = [UIImage imageNamed:@"off"];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self setRelay1:nil];
	[self setRelay2:nil];
	[self setRelay3:nil];
	[self setRelay4:nil];
	_imgOff = nil;
	_imgOff = nil;
	
	[super viewDidUnload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	self.title = @"UPnP Switch";
    return self;
}
							
- (IBAction)onSwitch:(UIButton *)sender
{
	// init  status
	int tag = sender.tag;
	int relay = tag & ~(TAG_RELAY_ON | TAG_RELAY_OFF);
	int switchValue = (tag & TAG_RELAY_ON) ? 0 : 1;
	
	// send cmd
	NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
							 [_detailItem objectForKey:PARAM_DEVICE_ID], PARAM_DEVICE_ID,
							 [NSNumber numberWithInteger:relay - 1], PARAM_SWITCH_INDEX,
							 [NSNumber numberWithInteger:switchValue], PARAM_SWITCH_VALUE,
							 nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SET_DEVICE_VALUE object:nil userInfo:infoDic];

	// delay a while then query state
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
	[self _queryDeviceState];
}

- (void)onReturnDeviceState: (NSNotification*)notification
{
	NSString* deviceState = [[notification userInfo] objectForKey:PARAM_DEVICE_STATE];
	
	Json::Value stateArray;
	Json::Reader().parse([deviceState UTF8String], stateArray);
	XASSERT(stateArray.size() == 4);
	
	for (int i = 0; i < 4; ++i)
	{
		bool state = stateArray[i].asBool();
		
		int tag = (i + 1) | (state ? TAG_RELAY_ON : TAG_RELAY_OFF);
		[self _configureButtonWithTag:tag];
	}
}

- (void)_configureButtonWithTag:(int)tag
{
	int relay = tag & ~(TAG_RELAY_ON | TAG_RELAY_OFF);
	
	UIImage* image = nil;
	if (tag & TAG_RELAY_ON)
		image = _imgOn;
	else
		image = _imgOff;
	
	switch (relay) {
		case 1:
			[self.relay1 setTag: tag];
			[self.relay1 setImage:image forState:UIControlStateNormal];
			[self.relay1 setEnabled:YES];
			break;
		case 2:
			[self.relay2 setTag: tag];
			[self.relay2 setImage:image forState:UIControlStateNormal];
			[self.relay2 setEnabled:YES];
			break;
		case 3:
			[self.relay3 setTag: tag];
			[self.relay3 setImage:image forState:UIControlStateNormal];
			[self.relay3 setEnabled:YES];
			break;
		case 4:
			[self.relay4 setTag: tag];
			[self.relay4 setImage:image forState:UIControlStateNormal];
			[self.relay4 setEnabled:YES];
			break;
			
		default:
			break;
	}
}

- (void)_queryDeviceState
{
	NSString* deviceId = [_detailItem objectForKey:PARAM_DEVICE_ID];
	NSDictionary* infoDic = [NSDictionary dictionaryWithObject:deviceId forKey:PARAM_DEVICE_ID];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_QUERY_DEVICE_STATE object:nil userInfo:infoDic];
}

@end
