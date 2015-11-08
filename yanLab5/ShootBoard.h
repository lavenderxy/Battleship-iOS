//
//  ShootBoard.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerOption.h"
#import "GameLogic.h"
#import "BattleShipGrid.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GamePlay.h"

@class GamePlay;

@interface ShootBoard : UIViewController{
    PlayerOption *_refOptions;
    GameLogic *_refGame;
    NSInteger _toggled;
    NSInteger _toggledState;
    BattleShipGrid *_gridViews[2];
    UITapGestureRecognizer *_tapRecognizers[2];
    UIPanGestureRecognizer *_panRecognizers[2];
    NSString *_statusText;
    NSInteger _whoShouldHitOrTap;
    NSTimer *_aiTimer;
    BOOL _aiHasHit;
    NSInteger _aiHittingPlayer;
    NSInteger _aiHittingX;
    NSInteger _aiHittingY;
    NSInteger _aiHittingType;
    SystemSoundID _soundHit;
    SystemSoundID _soundSunk;
    SystemSoundID _soundWin;
}
@property (assign, nonatomic) GamePlay *parent;
- (id)initWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame;

@end
