//
//  MenuLevelSelector.m
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "MenuLevelSelector.h"
#import "GameCommon.h"

#define FIRST_SECTION_TITLE @"Default Levels"
#define SECOND_SECTION_TITLE @"Designed Levels"

@implementation MenuLevelSelector

@synthesize selectorDelegate;
@synthesize levelOptions;
@synthesize preloadedMappings;

- (id)initWithStyle:(UITableViewStyle) style andDelegate:(id<LevelSelectorDelegate> )del{
    if(self = [super initWithStyle:style]){
        selectorDelegate = del;
        levelOptions = [self.selectorDelegate getAvailableLevels];
        preloadedMappings = [GameCommon preloadedLevelMappings];
    }
    
    return self;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return FIRST_SECTION_TITLE;
    }else{
        return SECOND_SECTION_TITLE;
    }
}

#pragma mark - datasource and delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger selectedLevel = [self getSelectedLevelForIndexPath:indexPath];
    if(indexPath.section == 0){
        [selectorDelegate selectedPreloadedLevel:selectedLevel];
    }else{
        [selectorDelegate selectedLevel:selectedLevel];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return [self.preloadedMappings count];
    }else{
        NSInteger numOfLevels = [self.levelOptions count];
        return numOfLevels;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if(indexPath.section == 0){
        [cell setTag:indexPath.row];
        [cell.textLabel setText:[preloadedMappings objectForKey:[NSNumber numberWithInteger:indexPath.row]]];
        
    }else{
        NSNumber *level = [levelOptions objectAtIndex:(indexPath.row)];
        [cell setTag:[level integerValue]];
        [self setLevelText:level forCell:cell];
    }
    return cell;
}
@end
