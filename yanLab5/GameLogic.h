//
//  GameLogic.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct ship_s {
    NSInteger length;
    BOOL placed;
    BOOL vertical;
    BOOL reversed;
    NSInteger position[2];
    NSInteger hitCount;
    BOOL sunk;
}
ship_t;

@interface HitItem : NSObject
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@end


@interface GameLogic : NSObject{
    BOOL _isStarted;
    BOOL _hasComputer;
    BOOL _isConnected;
    BOOL _isPlayer2;
    BOOL _hasPlaced[2];
    NSInteger _numShips[2];
    ship_t *_ships[2];
    BOOL _isPlayer2Turn;
    BOOL _isPlayer2Winner;
    NSInteger _firstMove;
    NSInteger _gridWidth;
    NSInteger *_grid[2]; // 0 for none, 1 for miss, 2 for hit
    BOOL _shipsVisible[2];
    NSInteger _score[2];
    NSInteger _winningScore[2];
    NSMutableArray *_aiUnsunkHits;
}
- (BOOL)isStarted;
- (void)startWithHasComputer:(BOOL)hasComputer hasNetwork:(BOOL)hasNetwork gridWidth:(NSInteger)gridWidth firstMove:(NSInteger)firstMove;
- (void)stop;
- (BOOL)hasComputer;
- (BOOL)isConnected;
- (NSInteger)whoShouldPlace;
- (NSInteger)computerPlayer;
- (NSInteger)numShipsForPlayer:(NSInteger)player;
- (NSInteger)numPlacedShipsForPlayer:(NSInteger)player;
- (ship_t)shipForPlayer:(NSInteger)player atIndex:(NSInteger)index;
- (BOOL)pointInShip:(const ship_t *)s atX:(NSInteger)x atY:(NSInteger)y;
- (BOOL)canSetShip:(ship_t)ship forPlayer:(NSInteger)player atIndex:(NSInteger)index;
- (void)setShip:(ship_t)ship forPlayer:(NSInteger)player atIndex:(NSInteger)index;
- (ship_t)randomShipForPlayer:(NSInteger)player atIndex:(NSInteger)index;
- (void)finishPlacingForPlayer:(NSInteger)player;
- (void)calcBaseForShip:(const ship_t *)s outX:(NSInteger *)x outY:(NSInteger *)y;
- (void)calcHeadingForShip:(const ship_t *)s outX:(NSInteger *)x outY:(NSInteger *)y;
- (NSInteger)whoShouldHit;
- (BOOL)canHitForPlayer:(NSInteger)player atX:(NSInteger)x atY:(NSInteger)y;
- (void)hitForPlayer:(NSInteger)player atX:(NSInteger)x atY:(NSInteger)y outHit:(BOOL *)hit outSunk:(BOOL *)sunk;
- (NSInteger)scoreForPlayer:(NSInteger)player;
- (NSInteger)winner;
- (NSInteger)firstMove;
- (NSInteger)gridWidth;
- (NSInteger)gridItemForPlayer:(NSInteger)player atX:(NSInteger)x atY:(NSInteger)y;
- (BOOL)shipsVisibleForPlayer:(NSInteger)player;
- (void)calcComputerHitOutAtX:(NSInteger *)x outAtY:(NSInteger *)y outType:(NSInteger *)type;

@end
