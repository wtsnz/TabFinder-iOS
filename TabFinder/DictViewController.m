//
//  DictViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 25/11/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "DictViewController.h"
#import "ChordsContainerView.h"

@implementation ChordCell

-(void)setSelected:(BOOL)selected {
    if (selected) {
        self.layer.cornerRadius = 4;
        self.backgroundColor = [UIColor defaultColor];
        _label.textColor = [UIColor colorWithWhite:0.15 alpha:1];
    } else {
        self.layer.cornerRadius = 0;
        self.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

@end

@interface DictViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *baseChordSC;
@property (weak, nonatomic) IBOutlet UICollectionView *baseChordCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *detailCollectionView;
@property (weak, nonatomic) IBOutlet ChordsContainerView *chordContainerView;
@property (strong, nonatomic) NSDictionary *chords;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation DictViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _closeButton.hidden = YES;
    }
    NSError *error;
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = nil;
    filePath = [thisBundle pathForResource:@"chords" ofType:@"txt" inDirectory:@""];
    NSString *string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    _chords = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    [_baseChordSC setSelectedSegmentIndex:0];
    [self selectFirstBaseChord];
    [self selectFirstDetailChord];
    _baseChordSC.tintColor = [UIColor defaultColor];
    _baseChordCollectionView.allowsMultipleSelection = NO;
    _detailCollectionView.allowsMultipleSelection = NO;
    _detailCollectionView.backgroundColor = [UIColor colorWithWhite:0.16 alpha:1];
    [self updateChord];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _baseChordCollectionView) {
        return [self chordNamesForSegmentedIndex:_baseChordSC.selectedSegmentIndex].count;
    }
    else {
        return [self currentSubChords].allKeys.count;
    }
}

-(NSString *)currentBaseChord {
    NSIndexPath *selectedItemIndexPath = [_baseChordCollectionView indexPathsForSelectedItems][0];
    return [[self chordNamesForSegmentedIndex:_baseChordSC.selectedSegmentIndex] objectAtIndex:selectedItemIndexPath.row];
}

-(NSDictionary *)currentSubChords {
    return _chords[[self currentBaseChord]];
}

-(NSArray *)sortedSubChordsNamesArray {
    return [[self currentSubChords].allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSArray *chords = @[@"m",@"7",@"m7",@"5",@"6",@"9",@"m6",@"m9",@"7M",@"7M(9)",@"11",@"13",@"sus2",@"sus4",@"5-",@"dim",@"5+",@"7(5-)",@"m7(5-)",@"7(5+)"];
        if ([(NSString *)obj1 isEqualToString:[self currentBaseChord]]) {
            return NSOrderedAscending;
        }
        if ([(NSString *)obj2 isEqualToString:[self currentBaseChord]]) {
            return NSOrderedDescending;
        }
        NSString *c1 = [((NSString *)obj1) substringFromIndex:[self currentBaseChord].length];
        NSString *c2 = [((NSString *)obj2) substringFromIndex:[self currentBaseChord].length];
        if ([chords indexOfObject:c1] < [chords indexOfObject:c2]) { return NSOrderedAscending; }
        return NSOrderedDescending;
    }];
}

-(NSArray *)selectedSubChordsVariations {
    return [self currentSubChords][[self selectedSubChordsName]];
}

-(NSString *)selectedSubChordsName {
    return [self sortedSubChordsNamesArray][[_detailCollectionView.indexPathsForSelectedItems[0] row]];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _baseChordCollectionView) {
        ChordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BaseCell" forIndexPath:indexPath];
        cell.label.text = [[self chordNamesForSegmentedIndex:_baseChordSC.selectedSegmentIndex] objectAtIndex:indexPath.row];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_menu"]];
        return cell;
    } else {
        NSArray *namesArray = [self sortedSubChordsNamesArray];
        ChordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DetailCell" forIndexPath:indexPath];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_menu"]];
        cell.label.text = [namesArray objectAtIndex:indexPath.row];
        return cell;
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[InAppPurchaseManager sharedInstance] fullAppCheck:@""];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _baseChordCollectionView) {
        [self reloadDetail];
    } else {
        [self updateChord];
    }
}

-(void)updateChord {
    [_chordContainerView configureForChord:[self selectedSubChordsName] variations:[self selectedSubChordsVariations]];
}

-(NSArray *)chordNamesForSegmentedIndex:(NSInteger)index {
    if (index == 0) {
        return @[@"C",@"D",@"E",@"F",@"G",@"A",@"B"];
    }
    if (index == 1) {
        return @[@"C#",@"D#",@"F#",@"G#",@"A#"];
    }
    if (index == 2) {
        return @[@"Db",@"Eb",@"Gb",@"Ab",@"Bb"];
    }
    return nil;
}

- (IBAction)didChangeBaseChordSegment:(id)sender {
    [self reloadBase];
}

-(void)reloadBase {
    NSIndexPath *selected = _baseChordCollectionView.indexPathsForSelectedItems.firstObject;
    [_baseChordCollectionView reloadData];
    NSIndexPath *adjusted = [NSIndexPath indexPathForRow:MIN(selected.row, [self collectionView:_baseChordCollectionView numberOfItemsInSection:0] - 1) inSection:0];
    [_baseChordCollectionView selectItemAtIndexPath:adjusted animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self reloadDetail];
}

-(void)reloadDetail {
    NSIndexPath *selected = _detailCollectionView.indexPathsForSelectedItems.firstObject;
    [_detailCollectionView reloadData];
    [_detailCollectionView selectItemAtIndexPath:selected animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self updateChord];
}

- (IBAction)didPressDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)selectFirstBaseChord {
    [_baseChordCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}
-(void)selectFirstDetailChord {
    [_detailCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}



@end
