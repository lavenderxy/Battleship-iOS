//
//  BattleShipGrid.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameLogic.h"

@interface BattleShipGrid : UIView {
    GameLogic *_refGame;
    NSInteger _player;
    BOOL _placing;
    BOOL _showMyShips;
}
- (void)initForRefGame:(GameLogic *)refGame player:(NSInteger)player placing:(BOOL)placing showMyShips:(BOOL)showMyShips;
- (void)updateContents;
- (void)rectToGridRect:(CGRect)rect out:(CGRect *)gridrect;
- (void)gridRectToRect:(CGRect)gridrect out:(CGRect *)rect;
- (void)pointToGridPoint:(CGPoint)point out:(CGPoint *)gridpoint;
- (void)gridPointToPoint:(CGPoint)gridpoint out:(CGPoint *)point;
- (double)gridCellSize;


@end
