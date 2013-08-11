//
//  DetailViewController.m
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import "DetailViewController.h"
#import "GCDAsyncSocket/GCDAsyncSocket.h"

#define PORT_RELAY_CONTROL 29978

#define TAG_QUERY_STATUS			(0x01 << 8)
#define TAG_RELAY_ON				(0x01 << 9)
#define TAG_RELAY_OFF				(0x01 << 10)

#define TAG_RELAY_1					1
#define TAG_RELAY_2					2
#define TAG_RELAY_3					3
#define TAG_RELAY_4					4


@interface DetailViewController ()
- (void)_configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
	{
        _detailItem = newDetailItem;
		[self _configureView];
    }
}

- (void)_configureView
{
	GCDAsyncSocket* socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	[socket setIPv6Enabled:NO];
	BOOL ret = [socket connectToHost:[_detailItem objectForKey:@"host"] onPort:PORT_RELAY_CONTROL error:nil];
	NSAssert(ret, nil);
	
	static const char Q = 'Q';
	[socket writeData:[NSData dataWithBytes:&Q length:sizeof(Q)] withTimeout:1.0 tag:TAG_QUERY_STATUS];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_imgOn = [UIImage imageNamed:@"on"];
	_imgOff = [UIImage imageNamed:@"off"];
}

- (void)viewDidUnload
{
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
	self.title = @"Network Switch";
    return self;
}
							
- (IBAction)onSwitch:(UIButton *)sender
{
	// init  status
	int tag = sender.tag;
	int relay = tag & ~(TAG_RELAY_ON | TAG_RELAY_OFF);
	
	// init cmd
	int newTag = 0;
	NSString* cmd = [[NSString alloc] init];
	if (tag & TAG_RELAY_ON)
	{
		newTag = relay | TAG_RELAY_OFF;
		cmd = [cmd stringByAppendingString:@"F"];
	}
	else if (tag & TAG_RELAY_OFF)
	{
		newTag = relay | TAG_RELAY_ON;
		cmd = [cmd stringByAppendingString:@"O"];
	}
	
	// send cmd
	cmd = [cmd stringByAppendingString:[NSString stringWithFormat:@"%d", relay]];
	
	GCDAsyncSocket* socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	[socket setIPv6Enabled:NO];
	BOOL ret = [socket connectToHost:[_detailItem objectForKey:@"host"] onPort:PORT_RELAY_CONTROL error:nil];
	NSAssert(ret, nil);
	
	[socket writeData:[NSData dataWithBytes:[cmd cStringUsingEncoding:NSUTF8StringEncoding] length:[cmd length]] withTimeout:1.0 tag:newTag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	if (tag & TAG_QUERY_STATUS)
		[sock readDataWithTimeout:1.0 tag:TAG_QUERY_STATUS];
	else if ((tag & TAG_RELAY_ON) || (tag & TAG_RELAY_OFF))
	{
		[sock disconnect];
		[self _configureButtonWithTag:tag];
	}
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSAssert(tag & TAG_QUERY_STATUS, nil);
	
	NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSAssert([result length]== 4, nil);
	
	for (int relay = 1; relay <= 4; ++relay)
	{
		char status = [result characterAtIndex:relay - 1];
		
		NSInteger tag = relay;
		if ('1' == status)
			tag |= TAG_RELAY_ON;
		else
			tag |= TAG_RELAY_OFF;
		
		[self _configureButtonWithTag:tag];
	}
	
	[sock disconnect];
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

@end
