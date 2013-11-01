//
//  iPadMenuViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 16/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPadMenuViewController : UITableViewController

- (IBAction)iCloudSwitchChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *icloudSwitch;

@end
