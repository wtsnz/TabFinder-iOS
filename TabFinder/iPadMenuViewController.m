//
//  iPadMenuViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 16/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "iPadMenuViewController.h"
#import "Engine.h"
#import "UpgradePromptViewController.h"
#import "InAppPurchaseManager.h"

@interface iPadMenuViewController ()

@end

@implementation iPadMenuViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setClearsSelectionOnViewWillAppear:NO];
    [_icloudSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"enable_iCloud"]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([InAppPurchaseManager sharedInstance].userHasFullApp) {
        return 8;
    } else {
        return 9;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4) {
        [Engine.instance likeOnFb];
        return;
    }
    if (indexPath.row == 5) {
        [Engine.instance sendFeedback];
        return;
    }
    if (indexPath.row == 6) {
        [Engine.instance tellFriends];
    }
    if (indexPath.row == 7) {
        return;
    }
    if (indexPath.row == 8) {
        [self presentViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"UpgradePromptViewController"] animated:YES completion:nil];
    }
}


- (IBAction)iCloudSwitchChanged:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    [Engine enableiCloud:theSwitch.isOn];
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}


@end
