//
//  TabHeaderView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 4/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "TabHeaderView.h"
#import "Song.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Blur.h"

@implementation TabHeaderView


static const CGFloat kDRNRealTimeBlurViewScreenshotCompression = 0.01;

//the blur radius
static const CGFloat kDRNRealTimeBlurViewBlurRadius = 1.f;

//the default corner radius for all the DRNRealTimeBlurViews
static const CGFloat kDRNRealTimeBlurViewDefaultCornerRadius = 20.f;

//the view is rendered every kDRNRealTimeBlurViewRenderPeriod seconds
//tweak this value to have a smoother or a more perfomant rendering
static const CGFloat kDRNRealTimeBlurViewRenderFps = 30.f;

//the alpha component of the tint color
static const CGFloat kDNRRealTimeBlurTintColorAlpha = 0.1f;

-(id)initWithSong:(Song *)song {
    self = [[NSBundle mainBundle] loadNibNamed:@"TabHeaderView" owner:self options:nil].lastObject;
    self.clipsToBounds = YES;
    UIImage *originalImage = [UIImage imageWithData:song.artistImage];
    //_originalPhoto.image = originalImage;
    _smallPhoto.layer.cornerRadius = _smallPhoto.frame.size.height/2;
    _smallPhoto.layer.masksToBounds = YES;
    _smallPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    _smallPhoto.layer.borderWidth = 4;
    _smallPhoto.image = originalImage;
    NSData *imageData = UIImageJPEGRepresentation(originalImage, kDRNRealTimeBlurViewScreenshotCompression);
    _blurredPhoto.image = [[UIImage imageWithData:imageData] drn_boxblurImageWithBlur:2];
    _blurredPhoto.alpha = 0.95;
    _blurredPhoto.layer.masksToBounds = YES;
    _artistName.text = song.artist;
    _songName.text = song.name;
    _versionLabel.text = song.shortVersionTitle;
    _artistName.font = [UIFont proximaNovaSemiBoldSize:14];
    _songName.font = [UIFont proximaNovaSemiBoldSize:18];
    _versionLabel.font = [UIFont proximaNovaSemiBoldSize:12];
    return self;
}

-(void)configureForSong:(Song *)song {
    self.frame = CGRectMake(0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 44 : 0, self.frame.size.width, self.frame.size.height);
    self.clipsToBounds = YES;
    UIImage *originalImage = [UIImage imageWithData:song.artistImage];
    originalImage = originalImage ? originalImage : [UIImage imageNamed:@"unknown_artist"];
    _smallPhoto.layer.cornerRadius = _smallPhoto.frame.size.height/2;
    _smallPhoto.layer.masksToBounds = YES;
    _smallPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    _smallPhoto.layer.borderWidth = 4;
    _smallPhoto.image = originalImage;
    //NSData *imageData = UIImageJPEGRepresentation(originalImage, kDRNRealTimeBlurViewScreenshotCompression);
    //_blurredPhoto.image = [[UIImage imageWithData:imageData] drn_boxblurImageWithBlur:2];
    _blurredPhoto.image = originalImage;
    [_blurredPhoto applyBlur];
    //_blurredPhoto.alpha = 0.95;
    _blurredPhoto.layer.masksToBounds = YES;
    _artistName.text = song.artist;
    _songName.text = song.name;
    _versionLabel.text = song.shortVersionTitle;
    _artistName.font = [UIFont proximaNovaSemiBoldSize:14];
    _songName.font = [UIFont proximaNovaSemiBoldSize:18];
    _versionLabel.font = [UIFont proximaNovaSemiBoldSize:12];
}


@end
