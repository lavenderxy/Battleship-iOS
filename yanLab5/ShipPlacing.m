//
//  ShipPlacing.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "ShipPlacing.h"

@interface ShipPlacing ()
@property (strong, nonatomic) IBOutlet ShipForPlayer *ship1;
@property (strong, nonatomic) IBOutlet ShipForPlayer *ship2;
@property (strong, nonatomic) IBOutlet ShipForPlayer *ship3;
@property (strong, nonatomic) IBOutlet ShipForPlayer *ship4;
@property (strong, nonatomic) IBOutlet ShipForPlayer *ship5;
@property (strong, nonatomic) IBOutlet BattleShipGrid *gridView;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation ShipPlacing

- (IBAction)clickedNext:(UIButton *)sender {
    if (_isNetworkPlayer) {
        return;
    }
    NSInteger numplaced = [_refGame numPlacedShipsForPlayer:_player];
    if (numplaced == 0) {
        for (NSInteger i = 0; i < _numShips; ++i) {
            ship_t ship = [_refGame randomShipForPlayer:_player atIndex:i];
            [_refGame setShip:ship forPlayer:_player atIndex:i];
        }
        [self updateGrid];
    }
    else if (numplaced == _numShips) {
        [_refGame finishPlacingForPlayer:_player];
        UIViewController *next = [self.parent createNextViewController];
        if (next) {
            UINavigationController *nav = self.navigationController;
            [self.navigationController popViewControllerAnimated:NO];
            [nav pushViewController:next animated:NO];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else {
        return;
    }

}

- (void)updateGrid {
    if (![self isViewLoaded]) {
        return;
    }
    [self.gridView updateContents];
    
    NSInteger numplaced = [_refGame numPlacedShipsForPlayer:_player];
    if (numplaced == 0) {
        self.nextButton.hidden = NO;
        [self.nextButton setTitle:@" Random " forState:UIControlStateNormal];
    }
    else if (numplaced == _numShips) {
        self.nextButton.hidden = NO;
        [self.nextButton setTitle:@" Next " forState:UIControlStateNormal];
    }
    else {
        self.nextButton.hidden = YES;
        [self.nextButton setTitle:@" " forState:UIControlStateNormal];
    }
}

- (void)updateTopLabel {
    if (![self isViewLoaded]) {
        return;
    }
    NSString *text = [NSString stringWithFormat:@"Place"];
    self.textLabel.text = text;
}


- (void)doInitWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame {
    self.title = @"BATTLESHIP";
    _refOptions = refOptions;
    _refGame = refGame;
    _player = [_refGame whoShouldPlace];
    _numShips = [_refGame numShipsForPlayer:_player];
}

- (id)initWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame {
        if (self) {
        [self doInitWithRefOptions:refOptions refGame:refGame];
    }
    return self;
}

- (void)updateDraggingShipPositionOnlyAtIndex:(NSInteger)i {
    if (![self isViewLoaded]) {
        return;
    }
    ShipForPlayer *v = _draggingShipViews[i];
    if (_dragging[i]) {
        v.frame = _draggingRects[i];
    }
}

- (void)updateTopShipShapes {
    for (NSInteger i = 0; i < _numShips; ++i) {
        [_topShipViews[i] updateContents];
    }
}

- (void)updateDraggingShipAtIndex:(NSInteger)i animated:(BOOL)animated {
    if (![self isViewLoaded]) {
        return;
    }
    ShipForPlayer *v = _draggingShipViews[i];
    if (_dragging[i]) {
        ship_t ship = [_refGame shipForPlayer:_player atIndex:i];
        v.vertical = ship.vertical;
        v.reversed = ship.reversed;
        v.hasGridCellSize = YES;
        v.gridCellSize = [self.gridView gridCellSize];
        v.transparency = 0.2;
        v.hidden = NO;
        v.opaque = NO;
        _topShipViews[i].hidden = YES;
        if (animated) {
            [UIView animateWithDuration:0.1 / _refOptions.animationSpeed animations:^(){
                v.frame = _draggingRects[i];
            }];
        }
        else {
            v.frame = _draggingRects[i];
        }
        [v updateContents];
    }
    else {
        if ([_refGame shipForPlayer:_player atIndex:i].placed) {
            v.hidden = YES;
            _topShipViews[i].hidden = YES;
        }
        else {
            if (animated) {
                [UIView animateWithDuration:0.1 / _refOptions.animationSpeed animations:^(){
                    v.frame = _topShipViews[i].frame;
                } completion:^(BOOL finished) {
                    [self updateDraggingShipAtIndex:i animated:NO];
                }];
            }
            else {
                v.hidden = YES;
                _topShipViews[i].hidden = NO;
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self updateGrid];
    [self updateTopShipShapes];
    
    [self.gridView initForRefGame:_refGame player:[_refGame whoShouldPlace] placing:YES showMyShips:_refOptions.showMyShips];
    
    _gridTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedGridView:)];
    [self.gridView addGestureRecognizer:_gridTapRecognizer];
    
    _gridPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedGridView:)];
    _gridPanRecognizer.maximumNumberOfTouches = 1;
    _gridPanRecognizer.delegate = self;
    [self.gridView addGestureRecognizer:_gridPanRecognizer];
    
    [self updateTopLabel];
    
    _topShipViews[0] = self.ship1;
    _topShipViews[1] = self.ship2;
    _topShipViews[2] = self.ship3;
    _topShipViews[3] = self.ship4;
    _topShipViews[4] = self.ship5;
    for (NSInteger i = 0; i < _numShips; ++i) {
        _topPanRecognizers[i] = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedTopShip:)];
        _topPanRecognizers[i].maximumNumberOfTouches = 1;
        _topPanRecognizers[i].delegate = self;
        [_topShipViews[i] addGestureRecognizer:_topPanRecognizers[i]];
        _dragging[i] = NO;
        _draggingShipViews[i] = [[ShipForPlayer alloc] initWithFrame:CGRectMake(0,0,100,100)];
        [self updateDraggingShipAtIndex:i animated:NO];
        [self.view addSubview:_draggingShipViews[i]];
    }
    
    _gridDragging = NO;
    
    self.gridView.backgroundColor = [UIColor whiteColor];
    self.gridView.alpha = 0.7;
    self.nextButton.backgroundColor = [UIColor darkGrayColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tappedGridView:(UIGestureRecognizer *)sender {
    if (_isNetworkPlayer) {
        return;
    }
    if (![self isViewLoaded]) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint startgridpoint;
        [self.gridView pointToGridPoint:[sender locationInView:self.gridView] out:&startgridpoint];
        NSInteger gridx = (NSInteger)floor(startgridpoint.x);
        NSInteger gridy = (NSInteger)floor(startgridpoint.y);
        
        NSInteger index;
        ship_t ship;
        for (index = 0; index < _numShips; ++index) {
            ship = [_refGame shipForPlayer:_player atIndex:index];
            if (!ship.placed) {
                continue;
            }
            if ([_refGame pointInShip:&ship atX:gridx atY:gridy]) {
                break;
            }
        }
        if (index == _numShips) {
            return;
        }
        
        NSInteger shipbase[2];
        NSInteger shipheading[2];
        NSInteger shipclickedpos;
        [_refGame calcBaseForShip:&ship outX:&shipbase[0] outY:&shipbase[1]];
        [_refGame calcHeadingForShip:&ship outX:&shipheading[0] outY:&shipheading[1]];
        shipclickedpos = (gridx - shipbase[0]) * shipheading[0] + (gridy - shipbase[1]) * shipheading[1];
        
        ship.vertical = !ship.vertical;
        ship.reversed = ship.vertical? !ship.reversed: ship.reversed;
        
        [_refGame calcBaseForShip:&ship outX:&shipbase[0] outY:&shipbase[1]];
        [_refGame calcHeadingForShip:&ship outX:&shipheading[0] outY:&shipheading[1]];
        NSInteger idealpos[2];
        idealpos[0] = ship.position[0] + (gridx - shipclickedpos * shipheading[0] - shipbase[0]);
        idealpos[1] = ship.position[1] + (gridy - shipclickedpos * shipheading[1] - shipbase[1]);
        
        NSInteger probedist;
        NSInteger maxprobedist = [_refGame gridWidth] * 2 - 2;
        NSInteger bestpos[2];
        NSInteger bestdist = maxprobedist + 1;
        for (probedist = 0; probedist < bestdist; ++probedist) {
            NSInteger nudge1, nudge2, dist;
            for (nudge1 = probedist; nudge1 > -probedist - 1; --nudge1) {
                for (nudge2 = probedist; nudge2 > -probedist - 1; --nudge2) {
                    dist = labs(nudge1) + labs(nudge2);
                    if (dist > probedist || dist >= bestdist) {
                        continue;
                    }
                    ship.position[0] = idealpos[0] + nudge1 * shipheading[0] + nudge2 * shipheading[1];
                    ship.position[1] = idealpos[1] + nudge1 * shipheading[1] + nudge2 * (-shipheading[0]);
                    if (![_refGame canSetShip:ship forPlayer:_player atIndex:index]) {
                        continue;
                    }
                    bestdist = dist;
                    bestpos[0] = ship.position[0];
                    bestpos[1] = ship.position[1];
                }
            }
        }
        if (bestdist < maxprobedist + 1) {
            ship.position[0] = bestpos[0];
            ship.position[1] = bestpos[1];
            [_refGame setShip:ship forPlayer:_player atIndex:index];
            [self updateGrid];
        }
    }
}

- (void)startGridDraggingShipFromLocation:(CGPoint)location {
    if (_isNetworkPlayer) {
        return;
    }
    if (![self isViewLoaded]) {
        return;
    }
    
    NSInteger index;
    CGPoint startgridpoint;
    [self.gridView pointToGridPoint:[self.view convertPoint:_gridDraggingStart toView:self.gridView] out:&startgridpoint];
    NSInteger gridx = (NSInteger)floor(startgridpoint.x);
    NSInteger gridy = (NSInteger)floor(startgridpoint.y);
    
    ship_t ship;
    for (index = 0; index < _numShips; ++index) {
        ship = [_refGame shipForPlayer:_player atIndex:index];
        if (!ship.placed) {
            continue;
        }
        if ([_refGame pointInShip:&ship atX:gridx atY:gridy]) {
            break;
        }
    }
    if (index == _numShips) {
        return;
    }
    
    _gridDragging = YES;
    _gridDraggingIndex = index;
    
    _dragging[index] = YES;
    ship.placed = NO;
    [_refGame setShip:ship forPlayer:_player atIndex:index];
    [self updateGrid];
    
    CGRect gridrect;
    CGRect rect;
    gridrect.origin.x = ship.position[0];
    gridrect.origin.y = ship.position[1];
    gridrect.size.width = ship.vertical? 1: ship.length;
    gridrect.size.height = ship.vertical? ship.length: 1;
    [self.gridView gridRectToRect:gridrect out:&rect];
    
    rect = [self.view convertRect:rect fromView:self.gridView];
    
    _draggingRects[index] = rect;
    [self updateDraggingShipAtIndex:index animated:NO];
    
    rect.origin.x += location.x - _gridDraggingStart.x;
    rect.origin.y += location.y - _gridDraggingStart.y;
    _draggingRects[index] = rect;
    [self updateDraggingShipAtIndex:index animated:YES];
}

- (void)pannedGridView:(UIPanGestureRecognizer *)sender {
    if (_isNetworkPlayer) {
        return;
    }
    if (![self isViewLoaded]) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (!_gridDragging) {
            CGPoint location = [sender locationInView:self.view];
            [self startGridDraggingShipFromLocation:location];
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled) {
        if (_gridDragging) {
            _gridDragging = NO;
            if (_dragging[_gridDraggingIndex]) {
                [self cancelDraggingShipAtIndex:_gridDraggingIndex];
            }
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        if (_gridDragging) {
            _gridDragging = NO;
            if (_dragging[_gridDraggingIndex]) {
                [self dropDraggingShipAtIndex:_gridDraggingIndex];
            }
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        if (_gridDragging) {
            if (_dragging[_gridDraggingIndex]) {
                CGPoint trans = [sender translationInView:self.view];
                [self moveDraggingShipAtIndex:_gridDraggingIndex withTranslation:trans];
                [sender setTranslation:CGPointZero inView:self.view];
            }
        }
    }
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_isNetworkPlayer) {
        return YES;
    }
    if (![self isViewLoaded]) {
        return YES;
    }
    
    if (gestureRecognizer == _gridPanRecognizer) {
        CGPoint location = [touch locationInView:self.view];
        _gridDraggingStart = location;
        return YES;
    }
    
    NSInteger index;
    for (index = 0; index < _numShips; ++index) {
        if (_topPanRecognizers[index] == gestureRecognizer) {
            break;
        }
    }
    if (index == _numShips) {
        return YES;
    }
    
    if (!_dragging[index]) {
        CGPoint location = [touch locationInView:self.view];
        _draggingStarts[index] = location;
    }
    return YES;
}

- (void)pannedTopShip:(UIPanGestureRecognizer *)sender {
    if (_isNetworkPlayer) {
        return;
    }
    if (![self isViewLoaded]) {
        return;
    }
    
    NSInteger index;
    for (index = 0; index < _numShips; ++index) {
        if (_topPanRecognizers[index] == sender) {
            break;
        }
    }
    if (index == _numShips) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (!_dragging[index]) {
            CGPoint location = [sender locationInView:self.view];
            [self startDraggingShipAtIndex:index fromLocation:location];
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled) {
        if (_dragging[index]) {
            [self cancelDraggingShipAtIndex:index];
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        if (_dragging[index]) {
            [self dropDraggingShipAtIndex:index];
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        if (_dragging[index]) {
            CGPoint trans = [sender translationInView:self.view];
            [self moveDraggingShipAtIndex:index withTranslation:trans];
            [sender setTranslation:CGPointZero inView:self.view];
        }
    }
}

- (void)startDraggingShipAtIndex:(NSInteger)i fromLocation:(CGPoint)location {
    if (_isNetworkPlayer) {
        return;
    }
    if (![self isViewLoaded]) {
        return;
    }
    
    _dragging[i] = YES;
    ship_t ship = [_refGame shipForPlayer:_player atIndex:i];
    ship.placed = NO;
    ship.vertical = NO;
    ship.reversed = NO;
    [_refGame setShip:ship forPlayer:_player atIndex:i];
    [self updateGrid];
    
    CGRect gridrect;
    CGRect rect;
    gridrect.origin.x = ship.position[0];
    gridrect.origin.y = ship.position[1];
    gridrect.size.width = ship.vertical? 1: ship.length;
    gridrect.size.height = ship.vertical? ship.length: 1;
    [self.gridView gridRectToRect:gridrect out:&rect];
    
    double xfrac, yfrac;
    CGRect startrect = _topShipViews[i].frame;
    xfrac = (_draggingStarts[i].x - startrect.origin.x) / startrect.size.width;
    yfrac = (_draggingStarts[i].y - startrect.origin.y) / startrect.size.height;
    rect.origin.x = location.x - xfrac * rect.size.width;
    rect.origin.y = location.y - yfrac * rect.size.height;
    
    _draggingRects[i] = _topShipViews[i].frame;
    [self updateDraggingShipAtIndex:i animated:NO];
    _draggingRects[i] = rect;
    [self updateDraggingShipAtIndex:i animated:YES];
}

- (void)moveDraggingShipAtIndex:(NSInteger)i withTranslation:(CGPoint)trans {
    _draggingRects[i].origin.x += trans.x;
    _draggingRects[i].origin.y += trans.y;
    [self updateDraggingShipPositionOnlyAtIndex:i];
}

- (void)cancelDraggingShipAtIndex:(NSInteger)i {
    _dragging[i] = NO;
    [self updateDraggingShipAtIndex:i animated:YES];
}

- (void)dropDraggingShipAtIndex:(NSInteger)i {
    if (_isNetworkPlayer) {
        return;
    }
    if (![self isViewLoaded]) {
        _dragging[i] = NO;
        return;
    }
    _dragging[i] = NO;
    CGRect rect;
    CGRect gridrect;
    rect = [self.view convertRect:_draggingRects[i] toView:self.gridView];
    [self.gridView rectToGridRect:rect out:&gridrect];
    
    ship_t ship = [_refGame shipForPlayer:_player atIndex:i];
    ship.placed = YES;
    ship.position[0] = (NSInteger)floor(gridrect.origin.x + 0.5);
    ship.position[1] = (NSInteger)floor(gridrect.origin.y + 0.5);
    if ([_refGame canSetShip:ship forPlayer:_player atIndex:i]) {
        [_refGame setShip:ship forPlayer:_player atIndex:i];
        [self updateGrid];
    }
    [self updateDraggingShipAtIndex:i animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
