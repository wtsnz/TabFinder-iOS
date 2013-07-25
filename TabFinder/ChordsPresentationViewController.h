//
//  ChordsPresentationViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 08/08/12.
//
//

#import <UIKit/UIKit.h>

@interface ChordsPresentationViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *chordWebView;
@property (strong, nonatomic) NSArray *chords;

@end
