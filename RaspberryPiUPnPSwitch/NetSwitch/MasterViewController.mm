//
//  MasterViewController.m
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NotficationDef.h"

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	self.title = @"UPnP Switch";
	
	//
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onDeviceFounded:)
												 name:NOTIFY_DEVICE_FOUNDED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onDeviceLost:)
												 name:NOTIFY_DEVICE_LOST
											   object:nil];
		
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
}

- (void)onDeviceFounded:(NSNotification *)notification
{
	NSString* deviceName = [[notification userInfo] objectForKey:@"deviceName"];
	NSString* deviceId = [[notification userInfo] objectForKey:@"deviceId"];
	
	DeviceInfo dev;
	dev.deviceName = [deviceName UTF8String];
	dev.deviceId = [deviceId UTF8String];
	
	_deviceList.push_back(dev);
	
	[self.tableView reloadData];
}

- (void)onDeviceLost:(NSNotification *)notification
{
	NSString* deviceId = [[notification userInfo] objectForKey:@"deviceId"];

	std::vector<DeviceInfo>::iterator itRemove = std::remove_if(_deviceList.begin(), _deviceList.end(), [=](const DeviceInfo& dev)
	{
		return dev.deviceId == [deviceId UTF8String];
	});
	_deviceList.erase(itRemove, _deviceList.end());
	
	[self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _deviceList.size();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	cell.textLabel.text = [NSString stringWithUTF8String:_deviceList[indexPath.row].deviceName.c_str()];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
	
	NSDictionary* detailItem = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithUTF8String:_deviceList[indexPath.row].deviceName.c_str()], PARAM_DEVICE_NAME,
								[NSString stringWithUTF8String:_deviceList[indexPath.row].deviceId.c_str()], PARAM_DEVICE_ID, nil];
    self.detailViewController.detailItem = detailItem;
	
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
