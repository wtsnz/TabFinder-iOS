//
//  ChordsPresentationViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 08/08/12.
//
//

#import "ChordsPresentationViewController.h"

@interface ChordsPresentationViewController ()

@end

@implementation ChordsPresentationViewController

@synthesize chordWebView;
@synthesize chords;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(320, 480);
    [chordWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"chord" ofType:@"html"]isDirectory:NO]]];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    for (NSString *chord in chords) {
        [chordWebView stringByEvaluatingJavaScriptFromString:chord];
    }
}

- (void)viewDidUnload
{
    [self setChordWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
