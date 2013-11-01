//
//  Engine.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IIViewDeckController.h"
#import "SearchViewController.h"
#import "ChordsTableViewController.h"
#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "IIWrapController.h"
#import "IISideController.h"
#import "RESideMenu.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "CoreDataHelper.h"

@class MenuViewController;

@interface Engine : NSObject

@property IIViewDeckController *viewDeckController;
@property UINavigationController *navigationController;
@property SearchViewController *searchViewController;
@property MenuViewController *menuViewController;

-(void)attachToWindow:(UIWindow *)window;

-(void)switchMenuToIndex:(NSInteger)index;
-(void)disableLeftMenu;
-(void)enableLeftMenu;

-(void)tellFriends;
-(void)likeOnFb;
-(void)sendFeedback;

+(Engine *)instance;

+(void)enableiCloud:(BOOL)enable;

@end
