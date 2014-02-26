//
//  ViewController.h
//  GameEngine
//
//  Created by Naomi Leow on 11/2/14.
//
//

#import <UIKit/UIKit.h>
#import "MainEngineSpecialised.h"
#import "GridTemplateDelegate.h"
#import "BubbleLoader.h"
#import "GameEngineInitDelegate.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, GridTemplateDelegate, GameEngineInitDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *bubbleGridTemplate;
@property (strong, nonatomic) IBOutlet UIImageView *gameBackground;
@property (strong) UIButton *backButton;
@property (strong) NSDictionary *allBubbleMappings;
@property (strong) NSDictionary *launchableBubbleMappings;
@property CGFloat defaultBubbleRadius;
@property (strong) MainEngineSpecialised *engine;
@property (strong) BubbleLoader *bubbleLoader;

- (void)panHandler:(UIGestureRecognizer *)recogniser;
//Tracks the gesture and changes the bubble's fire angle

- (void)tapHandler:(UIGestureRecognizer *)recogniser;
//Fire bubble with angle from tap point

- (void)longPressHandler:(UIGestureRecognizer *)recogniser;
//Note: longpressrecogniser is able to track the gesture till finger is lifted

- (void)loadNextBubble;

@end
