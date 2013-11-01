//
//  TabHeaderView.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 4/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "UIImageView+Blurry.h"

@interface TabHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *artistName;
@property (weak, nonatomic) IBOutlet UIImageView *smallPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *blurredPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *originalPhoto;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
-(id)initWithSong:(Song *)song;
-(void)configureForSong:(Song *)song;
@end
