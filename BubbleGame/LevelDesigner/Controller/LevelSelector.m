//
//  LevelSelector.m
//  ps03
//
//  Created by Naomi Leow on 2/2/14.
//
//

#import "LevelSelector.h"
#import "Constants.h"

#define ROW_WIDTH 150
#define LEVEL_TEXT @"Level %@"
#define SELECTOR_TITLE @"Select level";

@implementation LevelSelector

@synthesize selectorDelegate;
@synthesize levelOptions;

- (id)initWithStyle:(UITableViewStyle) style andDelegate:(id<LevelSelectorDelegate> )del{
    if(self = [super initWithStyle:style]){
        selectorDelegate = del;
    }
    
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return SELECTOR_TITLE;
}

- (void)updateLevelOptions{
    [self setLevelOptions:[selectorDelegate getAvailableLevels]];
    NSIndexPath *firstIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    NSInteger rowHeight = [self.tableView.delegate tableView:self.tableView
                                           heightForRowAtIndexPath:firstIndex];
    NSInteger totalRowsHeight = ([self.levelOptions count] + 1) * rowHeight;
    [self setPreferredContentSize:CGSizeMake(ROW_WIDTH, totalRowsHeight)];
    [self.tableView reloadData];
}

- (NSInteger)getSelectedLevelForIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return [cell tag];
}

#pragma mark - datasource and delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger selectedLevel = [self getSelectedLevelForIndexPath:indexPath];
    [selectorDelegate selectedLevel:selectedLevel];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numOfLevels = [self.levelOptions count];
    return numOfLevels + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if(indexPath.row == 0){
        [cell setTag:INVALID];
        [cell.textLabel setText:@"New Level"];
    }else{
        NSNumber *level = [levelOptions objectAtIndex:(indexPath.row - 1)];
        [cell setTag:[level integerValue]];
        [cell.textLabel setText:[NSString stringWithFormat:LEVEL_TEXT, level]];
    }
    return cell;
}

@end
