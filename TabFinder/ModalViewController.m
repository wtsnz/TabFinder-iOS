//
//  ModalViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/11/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "ModalViewController.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return self;
}


-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate {
    return UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone;
}



@end
