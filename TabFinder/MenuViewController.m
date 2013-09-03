//
//  MenuViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end



@implementation MenuCell

-(void)awakeFromNib {
    self.textLabel.font = [UIFont proximaNovaSemiBoldSize:17];
    UIView *v = [[UIView alloc] initWithFrame:self.frame];
    v.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.selectedBackgroundView = v;
}

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 6) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/114543218705358"]];
        return;
    }
    [Engine.instance switchMenuToIndex:indexPath.row];
}

@end
