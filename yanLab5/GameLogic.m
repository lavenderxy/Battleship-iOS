//
//  GameLogic.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "GameLogic.h"

@implementation HitItem

@end

@implementation GameLogic

- (void)dealloc {
    for (NSInteger x = 0; x < 2; ++x) {
        if (_ships[x] != nil) {
            free(_ships[x]);
        }
        if (_grid[x] != nil) {
            free(_grid[x]);
        }
    }
}

- (void)doInit {
    _isStarted = NO;
    _ships[0] = nil;
    _ships[1] = nil;
    _grid[0] = nil;
    _grid[1] = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self doInit];
    }
    return self;
}

- (BOOL)isStarted {
    return _isStarted;
}

- (void)startWithHasComputer:(BOOL)hasComputer hasNetwork:(BOOL)hasNetwork gridWidth:(NSInteger)gridWidth firstMove:(NSInteger)firstMove {
    _isStarted = YES;
    _hasComputer = hasComputer;
    _isConnected = NO;
    _isPlayer2 = NO;
    for (NSInteger x = 0; x < 2; ++x) {
        _hasPlaced[x] = NO;
        _numShips[x] = 5;
        if (_ships[x] != nil) {
            free(_ships[x]);
        }
        _ships[x] = (ship_t *)malloc(_numShips[x] * sizeof(ship_t));
        for (NSInteger i = 0; i < _numShips[x]; ++i) {
            ship_t *s = &_ships[x][i];
            switch (i) {
                case 0:
                    s->length = 5;
                    break;
                case 1:
                    s->length = 4;
                    break;
                case 2:
                    s->length = 3;
                    break;
                case 3:
                    s->length = 3;
                    break;
                case 4:
                    s->length = 2;
                    break;
            }
            s->placed = NO;
            s->vertical = NO;
            s->reversed = NO;
            s->position[0] = 0;
            s->position[1] = 0;
            s->hitCount = 0;
            s->sunk = NO;
        }
    }
    _isPlayer2Turn = NO;
    _isPlayer2Winner = NO;
    _firstMove = firstMove;
    _gridWidth = gridWidth;
    for (NSInteger x = 0; x < 2; ++x) {
        if (_grid[x] != nil) {
            free(_grid[x]);
        }
        _grid[x] = (NSInteger *)malloc(_gridWidth * _gridWidth * sizeof(NSInteger));
        for (NSInteger i = 0; i < _gridWidth * _gridWidth; ++i) {
            _grid[x][i] = 0;
        }
        _shipsVisible[x] = NO;
        _score[x] = 0;
        _winningScore[x] = 0;
    }
    _aiUnsunkHits = [[NSMutableArray alloc] init];
}

- (void)stop {
    _isStarted = NO;
}

- (BOOL)hasComputer {
    return _hasComputer;
}


- (BOOL)isConnected {
    return _isConnected;
}



- (NSInteger)whoShouldPlace {
    if (!_hasPlaced[0]) {
        if (_isPlayer2 && !_hasPlaced[1]) {
            return 2;
        }
        else {
            return 1;
        }
    }
    else if (!_hasPlaced[1]) {
        return 2;
    }
    else {
        return 0;
    }
}


- (NSInteger)computerPlayer {
    if (!_hasComputer) {
        return 0;
    }
    return 2;
}

- (NSInteger)numShipsForPlayer:(NSInteger)player {
    return _numShips[player - 1];
}

- (NSInteger)numPlacedShipsForPlayer:(NSInteger)player {
    NSInteger count = 0;
    for (NSInteger i = 0; i < _numShips[player - 1]; ++i) {
        ship_t *s = &_ships[player - 1][i];
        if (s->placed) {
            ++count;
        }
    }
    return count;
}

- (ship_t)shipForPlayer:(NSInteger)player atIndex:(NSInteger)index {
    return _ships[player - 1][index];
}

- (BOOL)pointInShip:(const ship_t *)s atX:(NSInteger)x atY:(NSInteger)y {
    if (s->vertical) {
        if (x == s->position[0] && s->position[1] <= y && y < s->position[1] + s->length) {
            return YES;
        }
    }
    else {
        if (y == s->position[1] && s->position[0] <= x && x < s->position[0] + s->length) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canSetShip:(ship_t)ship forPlayer:(NSInteger)player atIndex:(NSInteger)index {
    if (!ship.placed) {
        return YES;
    }
    if (ship.position[0] < 0 ||
        ship.position[1] < 0 ||
        ship.position[0] + (ship.vertical? 0: ship.length - 1) >= _gridWidth ||
        ship.position[1] + (ship.vertical? ship.length - 1: 0) >= _gridWidth) {
        return NO;
    }
    for (NSInteger i = 0; i < ship.length; ++i) {
        NSInteger x = ship.position[0] + (ship.vertical? 0: i);
        NSInteger y = ship.position[1] + (ship.vertical? i: 0);
        for (NSInteger j = 0; j < _numShips[player - 1]; ++j) {
            ship_t *s = &_ships[player - 1][j];
            if (!s->placed) {
                continue;
            }
            if (j == index) {
                continue;
            }
            if ([self pointInShip:s atX:x atY:y]) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)setShip:(ship_t)ship forPlayer:(NSInteger)player atIndex:(NSInteger)index {
    _ships[player - 1][index] = ship;
}

- (ship_t)randomShipForPlayer:(NSInteger)player atIndex:(NSInteger)index {
    ship_t ship = [self shipForPlayer:player atIndex:index];
    while (YES) {
        ship.reversed = (arc4random_uniform(2) == 1);
        ship.vertical = (arc4random_uniform(2) == 1);
        ship.placed = YES;
        ship.position[0] = arc4random_uniform((int)_gridWidth);
        ship.position[1] = arc4random_uniform((int)_gridWidth);
        if ([self canSetShip:ship forPlayer:player atIndex:index]) {
            break;
        }
    }
    return ship;
}

- (void)finishPlacingForPlayer:(NSInteger)player {
    _hasPlaced[player - 1] = YES;
    if (_hasPlaced[0] && _hasPlaced[1]) {
        _isPlayer2Turn = (_firstMove == 2? YES: NO);
        for (NSInteger x = 0; x < 2; ++x) {
            _winningScore[x] = [self numPlacedShipsForPlayer:2 - x];
        }
        if (_hasComputer) {
            _shipsVisible[0] = YES;
        }
    }
}

- (void)calcBaseForShip:(const ship_t *)s outX:(NSInteger *)x outY:(NSInteger *)y {
    *x = (!s->vertical && s->reversed? s->position[0] + (s->length - 1): s->position[0]);
    *y = (s->vertical && s->reversed? s->position[1] + (s->length - 1): s->position[1]);
}

- (void)calcHeadingForShip:(const ship_t *)s outX:(NSInteger *)x outY:(NSInteger *)y {
    *x = (s->vertical? 0: (s->reversed? -1: 1));
    *y = (!s->vertical? 0: (s->reversed? -1: 1));
}

- (NSInteger)whoShouldHit {
    if ([self winner] != 0) {
        return 0;
    }
    return _isPlayer2Turn? 2: 1;
}

- (BOOL)canHitForPlayer:(NSInteger)player atX:(NSInteger)x atY:(NSInteger)y {
    if (x < 0 || x >= _gridWidth || y < 0 || y >= _gridWidth) {
        return NO;
    }
    return _grid[player - 1][x + _gridWidth * y] == 0;
}

- (void)hitForPlayer:(NSInteger)player atX:(NSInteger)x atY:(NSInteger)y outHit:(BOOL *)hit outSunk:(BOOL *)sunk {
    ship_t *shit = nil;
    for (NSInteger i = 0; i < _numShips[2 - player]; ++i) {
        ship_t *s = &_ships[2 - player][i];
        if (!s->placed) {
            continue;
        }
        if ([self pointInShip:s atX:x atY:y]) {
            shit = s;
            break;
        }
    }
    if (!shit) {
        _grid[player - 1][x + _gridWidth * y] = 1;
        *hit = NO;
        *sunk = NO;
    }
    else {
        _grid[player - 1][x + _gridWidth * y] = 2;
        *hit = YES;
        shit->hitCount += 1;
        if (shit->hitCount >= shit->length) {
            shit->sunk = YES;
            *sunk = YES;
            _score[player - 1] += 1;
        }
        else {
            *sunk = NO;
        }
    }
    if (_hasComputer && player == 2) {
        if (*sunk) {
            [_aiUnsunkHits removeAllObjects];
        }
        if (*hit && !*sunk) {
            HitItem *h = [[HitItem alloc] init];
            h.x = x;
            h.y = y;
            [_aiUnsunkHits addObject:h];
        }
    }
    _isPlayer2Turn = !_isPlayer2Turn;
}

- (NSInteger)scoreForPlayer:(NSInteger)player {
    return _score[player - 1];
}

- (NSInteger)winner {
    if ([self whoShouldPlace] != 0) {
        return 0;
    }
    if (_score[0] == _winningScore[0]) {
        return 1;
    }
    else if (_score[1] == _winningScore[1]) {
        return 2;
    }
    else {
        return 0;
    }
}

- (NSInteger)firstMove {
    return _firstMove;
}

- (NSInteger)gridWidth {
    return _gridWidth;
}

- (NSInteger)gridItemForPlayer:(NSInteger)player atX:(NSInteger)x atY:(NSInteger)y {
    return _grid[player - 1][x + _gridWidth * y];
}

- (BOOL)shipsVisibleForPlayer:(NSInteger)player {
    return _shipsVisible[player - 1];
}

- (void)calcComputerHitOutAtX:(NSInteger *)x outAtY:(NSInteger *)y outType:(NSInteger *)type {
    
    BOOL found = NO;
    
    if ([_aiUnsunkHits count] > 0) {
        HitItem *h1 = [_aiUnsunkHits objectAtIndex:0];
        NSInteger xy[2] = {h1.x, h1.y};
        NSInteger mins[2] = {h1.x, h1.y};
        NSInteger maxs[2] = {h1.x, h1.y};
        for (HitItem *h in _aiUnsunkHits) {
            mins[0] = MIN(mins[0], h.x);
            maxs[0] = MAX(maxs[0], h.x);
            mins[1] = MIN(mins[1], h.y);
            maxs[1] = MAX(maxs[1], h.y);
        }
        
        NSInteger xynear[4][2];
        NSInteger xyfar[4][2];
        for (NSInteger d = 0; d < 4; ++d) {
            switch (d) {
                case 0:
                    xynear[d][0] = maxs[0];
                    xynear[d][1] = xy[1];
                    xyfar[d][0] = maxs[0] + 1;
                    xyfar[d][1] = xy[1];
                    break;
                case 1:
                    xynear[d][0] = mins[0];
                    xynear[d][1] = xy[1];
                    xyfar[d][0] = mins[0] - 1;
                    xyfar[d][1] = xy[1];
                    break;
                case 2:
                    xynear[d][1] = maxs[1];
                    xynear[d][0] = xy[0];
                    xyfar[d][1] = maxs[1] + 1;
                    xyfar[d][0] = xy[0];
                    break;
                case 3:
                    xynear[d][1] = mins[1];
                    xynear[d][0] = xy[0];
                    xyfar[d][1] = mins[1] - 1;
                    xyfar[d][0] = xy[0];
                    break;
            }
        }
        
        // find a direction that we haven't finished probing
        for (NSInteger d = 0; d < 4; ++d) {
            if (xynear[d][0] == xy[0] && xynear[d][1] == xy[1]) {
                continue;
            }
            if ([self gridItemForPlayer:2 atX:xynear[d][0] atY:xynear[d][1]] != 2) {
                continue;
            }
            if ([self canHitForPlayer:2 atX:xyfar[d][0] atY:xyfar[d][1]]) {
                *x = xyfar[d][0];
                *y = xyfar[d][1];
                *type = 1;
                found = YES;
            }
        }
        
        // or find a new direction
        if (!found) {
            NSInteger numfeasibles = 0;
            NSInteger feasibles[4];
            for (NSInteger d = 0; d < 4; ++d) {
                if (xynear[d][0] != xy[0] || xynear[d][1] != xy[1]) {
                    continue;
                }
                if ([self canHitForPlayer:2 atX:xyfar[d][0] atY:xyfar[d][1]]) {
                    feasibles[numfeasibles] = d;
                    ++numfeasibles;
                }
            }
            if (numfeasibles > 0)
            {
                NSInteger d = feasibles[arc4random_uniform((u_int32_t)numfeasibles)];
                *x = xyfar[d][0];
                *y = xyfar[d][1];
                *type = 2;
                found = YES;
            }
        }
    }
    
    // if we still cannot decide, just pick a random spot
    while (!found) {
        *x = arc4random_uniform((u_int32_t)_gridWidth);
        *y = arc4random_uniform((u_int32_t)_gridWidth);
        *type = 3;
        if (![self canHitForPlayer:2 atX:*x atY:*y]) {
            continue;
        }
        found = YES;
    }
}


@end
