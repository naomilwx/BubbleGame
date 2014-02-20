//
//  LevelSelector.h
//  ps03
//
//  Created by Naomi Leow on 2/2/14.
//
//

#import <UIKit/UIKit.h>
#import "LevelSelectorDelegate.h"

@interface LevelSelector : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *levelOptions;
@property (nonatomic, weak) id<LevelSelectorDelegate> selectorDelegate;

- (id)initWithStyle:(UITableViewStyle)style andDelegate:(id<LevelSelectorDelegate> )del;

- (void)updateLevelOptions;
//Update level selection list

@end
