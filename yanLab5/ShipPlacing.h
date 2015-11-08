//
//  ShipPlacing.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerOption.h"
#import "GameLogic.h"
#import "ShipForPlayer.h"
#import "BattleShipGrid.h"
#import "GamePlay.h"

@class GamePlay;

@interface ShipPlacing : UIViewController<UIGestureRecognizerDelegate> {
    PlayerOption *_refOptions;
    GameLogic *_refGame;
    NSInteger _networkState;
    NSInteger _player;
    BOOL _isNetworkPlayer;
    NSInteger _numShips;
    ShipForPlayer *_topShipViews[5];
    UITapGestureRecognizer *_gridTapRecognizer;
    UIPanGestureRecognizer *_gridPanRecognizer;
    CGPoint _gridDraggingStart;
    BOOL _gridDragging;
    NSInteger _gridDraggingIndex;
    UIPanGestureRecognizer *_topPanRecognizers[5];
    BOOL _dragging[5];
    CGRect _draggingRects[5];
    CGPoint _draggingStarts[5];
    ShipForPlayer *_draggingShipViews[5];
}
@property (assign, nonatomic) GamePlay *parent;
- (id)initWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame;

@end
