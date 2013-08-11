//
//  MasterViewController.h
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket/GCDAsyncUdpSocket.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UINavigationControllerDelegate>
{
	NSMutableArray*			_objects;
	GCDAsyncUdpSocket*		_UdpFindArduinos;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
