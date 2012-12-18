//
//  MasterViewController.m
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#define PORT_FIND_ARDUINOS 29979

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	self.title = @"Arduinos";
	
	_objects = [[NSMutableArray alloc] init];
	_UdpFindArduinos = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	BOOL ret = [_UdpFindArduinos enableBroadcast:YES error:nil];
	NSAssert(ret, nil);
	[_UdpFindArduinos setIPv6Enabled:NO];
	
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[_objects removeAllObjects];
	[self.tableView reloadData];
	
	BOOL ret = [_UdpFindArduinos bindToPort:PORT_FIND_ARDUINOS error:nil];
	NSAssert(ret, @"bind UDP port failed");
	
	ret = [_UdpFindArduinos beginReceiving:nil];
	NSAssert(ret, nil);
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_UdpFindArduinos pauseReceiving];
	[_UdpFindArduinos close];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
	  fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString* arduinoName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString* arduinoHost;
	uint16_t port;
	
	[GCDAsyncUdpSocket getHost:&arduinoHost port:&port fromAddress:address];
	
	BOOL nameNotFound = YES;
	for (NSDictionary* obj in _objects)
	{
		if([arduinoName isEqualToString:[obj objectForKey:@"name"]])
		{
			nameNotFound = NO;
			break;
		}
	}
	
	if (nameNotFound)
	{
		NSMutableDictionary* infoDic = [[NSMutableDictionary alloc] init];
		[infoDic setValue:arduinoName forKey:@"name"];
		[infoDic setValue:arduinoHost forKey:@"host"];
		
		[_objects insertObject:infoDic atIndex:0];
		
		[self.tableView reloadData];
	}
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }


	NSDictionary*object = _objects[indexPath.row];
	cell.textLabel.text = [object objectForKey:@"name"];
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
    NSDate *object = _objects[indexPath.row];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
