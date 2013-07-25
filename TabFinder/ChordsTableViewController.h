//
//  ChordsTableViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 07/08/12.
//
//

#import <UIKit/UIKit.h>

@interface ChordsTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *chords;
@property (strong, nonatomic) NSMutableArray *selectedChord;

@end
