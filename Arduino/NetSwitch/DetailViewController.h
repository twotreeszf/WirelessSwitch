//
//  DetailViewController.h
//  NetSwitch
//
//  Created by zhang fan on 12-12-17.
//  Copyright (c) 2012年 twotrees. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
{
	UIImage* _imgOn;
	UIImage* _imgOff;
}

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIButton *relay1;
@property (weak, nonatomic) IBOutlet UIButton *relay2;
@property (weak, nonatomic) IBOutlet UIButton *relay3;
@property (weak, nonatomic) IBOutlet UIButton *relay4;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (IBAction)onSwitch:(UIButton *)sender;


@end
