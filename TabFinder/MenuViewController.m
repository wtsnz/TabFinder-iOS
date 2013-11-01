//
//  MenuViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "MenuViewController.h"
#import "InAppPurchaseManager.h"
#import "UpgradePromptViewController.h"

@interface MenuViewController ()

@end

@implementation MenuCell

-(void)awakeFromNib {
    self.textLabel.font = [UIFont proximaNovaSize:17];
    self.textLabel.highlightedTextColor = [UIColor defaultColor];
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.tintColor = [UIColor defaultColor];
    UIView *v = [[UIView alloc] initWithFrame:self.frame];
    v.backgroundColor = [UIColor colorWithWhite:0.14 alpha:1];
    self.selectedBackgroundView = v;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.imageView.tintColor = highlighted ? [UIColor defaultColor] : [UIColor whiteColor];
    self.textLabel.textColor = highlighted ? [UIColor defaultColor] : [UIColor whiteColor];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.imageView.tintColor = selected ? [UIColor defaultColor] : [UIColor whiteColor];
    self.textLabel.textColor = selected ? [UIColor defaultColor] : [UIColor whiteColor];
}

@end

@implementation MenuViewController

static MenuViewController *_instance;

+(MenuViewController *)instance {
    return _instance;
}

- (IBAction)iCloudSwitchChanged:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    [Engine enableiCloud:theSwitch.isOn];
}

- (void)viewDidLoad
{
    _instance = self;
    [super viewDidLoad];
    BOOL iCloudIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_iCloud"];
    [_icloudSwitch setOn:iCloudIsOn];
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self setClearsSelectionOnViewWillAppear:NO];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
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
        return;
    }
    if (indexPath.row == 7) {
        return;
    }
    if (indexPath.row == 8) {
        [self presentViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"UpgradePromptViewController"] animated:YES completion:nil];
        return;
    }
    [Engine.instance switchMenuToIndex:indexPath.row];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 7) return NO;
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
