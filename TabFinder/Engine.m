//
//  Engine.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "Engine.h"

@interface Engine () <UIGestureRecognizerDelegate, IIViewDeckControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, UIActionSheetDelegate>

@property RESideMenu *sideMenu;
@property UIPanGestureRecognizer *panGesture;
@property UIView *blackStatusBarBackground;

@end

@implementation Engine

static Engine *_instance;

+(Engine *)instance {
    if (!_instance) {
        _instance = [[Engine alloc] init];
    }
    return _instance;
}

-(id)init {
    self = [super init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    if ([defaults objectForKey:@"enable_iCloud"] == nil) {
        [self.class enableiCloud:NO];
    }
//    [[CoreDataHelper get] managedObjectContext]; //connects to database upon launch!
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        _navigationController = [sb instantiateViewControllerWithIdentifier:@"NavigationController"];
        _menuViewController = [sb instantiateViewControllerWithIdentifier:@"MenuViewController"];
        _searchViewController = [sb instantiateViewControllerWithIdentifier:@"SearchViewController"];
        _viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:_navigationController leftViewController:[[IISideController alloc] initWithViewController:_menuViewController]];
        _viewDeckController.panningMode = IIViewDeckFullViewPanning;
        _viewDeckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
        _viewDeckController.parallaxAmount = 0.2;
        _viewDeckController.panningGestureDelegate = self;
        _viewDeckController.delegate = self;
        _blackStatusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1136, 20)];
        _blackStatusBarBackground.backgroundColor = [UIColor blackColor];
        [_viewDeckController.view addSubview:_blackStatusBarBackground];
        [_viewDeckController.view bringSubviewToFront:_blackStatusBarBackground];
        _blackStatusBarBackground.alpha = 0;
        [_navigationController.navigationBar setBarTintColor:[UIColor defaultColor]];
        [self switchMenuToIndex:0];
    }
    return self;
}

-(void)viewDeckController:(IIViewDeckController *)viewDeckController didChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning {
    _blackStatusBarBackground.alpha = offset/276;
}

-(void)swipeHandler:(id)sender {
    [_sideMenu showFromPanGesture:sender];
}

-(void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckLeftSide)
        [_navigationController.visibleViewController.view endEditing:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch locationInView:_navigationController.view].x > 180) return NO;
    return YES;
}

-(void)attachToWindow:(UIWindow *)window {
    window.rootViewController = _viewDeckController;
}

-(UIViewController *)viewControllerForMenuItem:(NSInteger)menuItemIndex {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    switch (menuItemIndex) {
        case 0:
            return _searchViewController;
        case 1:
            return [sb instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
        case 2:
            return [sb instantiateViewControllerWithIdentifier:@"HistoryViewController"];
        case 3:
            return [sb instantiateViewControllerWithIdentifier:@"ChordsViewController"];
        default:
            return nil;
    }
}

-(void)switchMenuToIndex:(NSInteger)index {
    UIViewController *vc = [self viewControllerForMenuItem:index];
    [_navigationController setViewControllers:@[vc] animated:NO];
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] landscapeImagePhone:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [_viewDeckController toggleLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
        if (index == 0) {
            [_searchViewController.searchBar becomeFirstResponder];
        }
    }];
}

-(void)showMenu {
    [_viewDeckController toggleLeftViewAnimated:YES];
}

-(void)disableLeftMenu {
    _viewDeckController.panningMode = IIViewDeckNoPanning;
}

-(void)enableLeftMenu {
    _viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

-(void)likeOnFb {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/114543218705358"]];
}

-(void)sendFeedback {
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    vc.toRecipients = @[@"tabfinderapp@gmail.com"];
    vc.subject = @"Feedback";
    vc.navigationBar.translucent = NO;
    [self presentVC:vc];
}

-(void)presentVC:(UIViewController *)vc {
    if (_viewDeckController)
        [_viewDeckController presentViewController:vc animated:YES completion:nil];
    else [((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewControllerIpad presentViewController:vc animated:YES completion:nil];
}

-(void)tellFriends {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Tell friends about TabFinder" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose from my contacts", @"Facebook", @"Twitter", nil];
    if (_viewDeckController)
        [sheet showInView:_viewDeckController.view];
    else [sheet showInView:((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewControllerIpad.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex) return;
    if (buttonIndex == 0) { // choose from contacts
        BOOL canSendEmail = [MFMailComposeViewController canSendMail];
#if TARGET_IPHONE_SIMULATOR
        BOOL canSendText = NO; // simulator doesn't support texting
#else
        BOOL canSendText = [MFMessageComposeViewController canSendText];
#endif
        if (! canSendEmail && ! canSendText) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Your email doesn't seem to be active for this device. Please check your settings." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            
            return;
        }
        ABPeoplePickerNavigationController *vc = [[ABPeoplePickerNavigationController alloc] init];
        vc.peoplePickerDelegate = self;
        
        // only display the supported sending options
        
        NSMutableArray *array = [NSMutableArray array];
        
        if (canSendEmail) {
            [array addObject:@(kABPersonEmailProperty)];
        }
        
        if (canSendText) {
            [array addObject:@(kABPersonPhoneProperty)];
        }
        
        vc.displayedProperties = [array mutableCopy];
        vc.navigationBar.translucent = NO;
        [self presentVC:vc];
        return;
    }
    
    NSString *serviceType = buttonIndex == 1 ? SLServiceTypeFacebook : SLServiceTypeTwitter;
    if([SLComposeViewController isAvailableForServiceType:serviceType]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [controller setInitialText:[self punchLine]];
        [self presentVC:controller];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler = myBlock;
    } else {
        NSString *message = [[actionSheet buttonTitleAtIndex:buttonIndex] stringByAppendingString:@" is not available! You can enable it on from your device settings."];
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(NSString *)punchLine {
    return @"Check out TabFinder, it shows you how to play any song on the guitar! http://appstore.com/tabfinder";
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	return YES;
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    // get the selected email or phone number
    CFTypeRef typeRef = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(typeRef, identifier);
    NSString *value = (__bridge NSString *)ABMultiValueCopyValueAtIndex(typeRef, index);
    CFRelease(typeRef);
    [peoplePicker dismissViewControllerAnimated:NO completion:^{
        if (property == kABPersonPhoneProperty) {
            MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
            vc.messageComposeDelegate = self;
            vc.recipients = @[value];
            vc.body = [self punchLine];
            [self presentVC:vc];
        } else if (property == kABPersonEmailProperty) {
            NSString *message = [self punchLine];
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            vc.mailComposeDelegate = self;
            vc.toRecipients = @[value];
            vc.subject = @"Guitar tabs app";
            [vc setMessageBody:message isHTML:NO];
            [self presentVC:vc];
        }
    }];
    return NO;
}

+(void)enableiCloud:(BOOL)enable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    [defaults setBool:enable forKey:@"enable_iCloud"];
    [CoreDataHelper reset];
}


@end
