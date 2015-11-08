//
//  ShootBoard.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "ShootBoard.h"

@interface ShootBoard ()
@property (strong, nonatomic) IBOutlet UILabel *text1Label;
@property (strong, nonatomic) IBOutlet UILabel *text2Label;
@property (strong, nonatomic) IBOutlet UILabel *Score1;
@property (strong, nonatomic) IBOutlet UILabel *Score2;
@property (strong, nonatomic) IBOutlet BattleShipGrid *playGrid1;
@property (strong, nonatomic) IBOutlet BattleShipGrid *playGrid2;
@property (strong, nonatomic) IBOutlet UIView *viewForGrid;
@property (strong, nonatomic) IBOutlet UILabel *labelState;

@end

@implementation ShootBoard

- (NSString *)nameForPlayer:(NSInteger)player {
    if (player == 0) {
        return @"Internal error";
    }
    if (player == [_refGame computerPlayer]) {
        return @"Computer";
    }
    return [NSString stringWithFormat:@"Player %d", (int)player];
}

- (void)updatePlayerLabels {
    if (![self isViewLoaded]) {
        return;
    }
    self.text1Label.text = [NSString stringWithFormat:@" %@ ", [self nameForPlayer:1]];
    self.text2Label.text = [NSString stringWithFormat:@" %@ ", [self nameForPlayer:2]];
    self.text1Label.backgroundColor = _whoShouldHitOrTap == 1? [UIColor darkGrayColor]: [UIColor clearColor];
    self.text2Label.backgroundColor = _whoShouldHitOrTap == 2? [UIColor darkGrayColor]: [UIColor clearColor];
}

- (void)updateGridAndScores {
    if (![self isViewLoaded]) {
        return;
    }
    [_gridViews[0] updateContents];
    [_gridViews[1] updateContents];
    self.Score1.text = [NSString stringWithFormat:@" Score: %d ", (int)[_refGame scoreForPlayer:1]];
    self.Score2.text = [NSString stringWithFormat:@" Score: %d ", (int)[_refGame scoreForPlayer:2]];
}

- (void)updateStatusLabelAnimated:(BOOL)animated {
    if (![self isViewLoaded]) {
        return;
    }
    if (animated && self.labelState.text != _statusText) {
        self.labelState.transform = CGAffineTransformMakeTranslation(0, 5 * self.labelState.frame.size.height);
        [UIView animateWithDuration:0.2 / _refOptions.animationSpeed animations:^{
            self.labelState.transform = CGAffineTransformIdentity;
        }];
    }
    self.labelState.text = _statusText;
}

- (void)replaceConstraintsOfPriority:(UILayoutPriority)oldPriority withPriority:(UILayoutPriority)newPriority forViews:(NSArray *)views {
    if (![self isViewLoaded]) {
        return;
    }
    for (UIView *view in views) {
        [view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
         {
             if (fabs(constraint.priority - oldPriority) < 0.05) {
                 constraint.priority = newPriority;
             }
         }];
    }
}

- (void)updateToggledGridAnimated:(BOOL)animated {
    if (![self isViewLoaded]) {
        return;
    }
    NSArray *views = [NSArray arrayWithObjects:self.viewForGrid,self.playGrid1,self.playGrid2,nil];
    if (_toggledState != _toggled) {
        if (_toggled == 2) {
            [self replaceConstraintsOfPriority:921 withPriority:121 forViews:views];
            [self replaceConstraintsOfPriority:120 withPriority:920 forViews:views];
        }
        else {
            [self replaceConstraintsOfPriority:920 withPriority:120 forViews:views];
            [self replaceConstraintsOfPriority:121 withPriority:921 forViews:views];
        }
        if (animated) {
            [UIView animateWithDuration:0.2 / _refOptions.animationSpeed animations:^{
                [self.view layoutIfNeeded];
            }];
        }
        else {
            [self.view layoutIfNeeded];
        }
        _toggledState = _toggled;
    }
}

- (void)doInitWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame {
    self.title = @"BATTLESHIP";
    _refOptions = refOptions;
    _refGame = refGame;
    NSInteger whoshouldhit = [_refGame whoShouldHit];
    NSInteger winner = [_refGame winner];
    _toggled = (whoshouldhit != 0? whoshouldhit: winner != 0? winner: 1);
    _whoShouldHitOrTap = whoshouldhit;
    _statusText = @" ";
    
    NSURL *soundHitUrl = [[NSBundle mainBundle] URLForResource:@"hitShips" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundHitUrl, &_soundHit);
    NSURL *soundSunkUrl = [[NSBundle mainBundle] URLForResource:@"sunkSounds" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundSunkUrl, &_soundSunk);
    NSURL *soundWinUrl = [[NSBundle mainBundle] URLForResource:@"winSound" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundWinUrl, &_soundWin);
    
}

- (id)initWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame {
    if (self) {
        [self doInitWithRefOptions:refOptions refGame:refGame];
    }
    return self;
}

- (void)dealloc {
    if (_aiTimer != nil) {
        [_aiTimer invalidate];
        _aiTimer = nil;
    }
    AudioServicesDisposeSystemSoundID(_soundHit);
    AudioServicesDisposeSystemSoundID(_soundSunk);
    AudioServicesDisposeSystemSoundID(_soundWin);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _gridViews[0] = self.playGrid1;
    _gridViews[1] = self.playGrid2;
    
    for (NSInteger i = 0; i < 2; ++i) {
        [_gridViews[i] initForRefGame:_refGame player:i + 1 placing:NO showMyShips:_refOptions.showMyShips];
        _tapRecognizers[i] = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [_gridViews[i] addGestureRecognizer:_tapRecognizers[i]];
        _panRecognizers[i] = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        [_gridViews[i] addGestureRecognizer:_panRecognizers[i]];
    }
    
    [self updatePlayerLabels];
    [self updateGridAndScores];
    [self updateStatusLabelAnimated:NO];
    
    _toggledState = 0;
    [self updateToggledGridAnimated:NO];
    
    self.playGrid1.backgroundColor = [UIColor clearColor];
    self.playGrid2.backgroundColor = [UIColor clearColor];
    
    [self next];
}

- (void)tapped:(UITapGestureRecognizer *)sender {
    if (![self isViewLoaded]) {
        return;
    }
    
    NSInteger index;
    for (index = 0; index < 2; ++index) {
        if (_tapRecognizers[index] == sender) {
            break;
        }
    }
    if (index == 2) {
        return;
    }
    
    NSInteger whoshouldhit = [_refGame whoShouldHit];
    if (whoshouldhit == 0) {
        _toggled = 3 - _toggled;
        [self updateToggledGridAnimated:YES];
        [self next];
        return;
    }
    if (index + 1 != whoshouldhit) {
        _toggled = whoshouldhit;
        [self updateToggledGridAnimated:YES];
        [self next];
        return;
    }
    
    CGPoint gridp;
    [_gridViews[index] pointToGridPoint:[sender locationInView:_gridViews[index]] out:&gridp];
    NSInteger gridx = (NSInteger)floor(gridp.x);
    NSInteger gridy = (NSInteger)floor(gridp.y);
    if (![_refGame canHitForPlayer:whoshouldhit atX:gridx atY:gridy]) {
        [self updateStatusLabelAnimated:NO];
    }
    else {
        BOOL hit, sunk;
        [_refGame hitForPlayer:whoshouldhit atX:gridx atY:gridy outHit:&hit outSunk:&sunk];
        [self updateGridAndScores];
        _statusText = sunk? [NSString stringWithFormat:@"%@ scored", [self nameForPlayer:whoshouldhit]] : @" ";
        [self updateStatusLabelAnimated:YES];
        if ([_refGame winner] != 0) {
            [self next];
        }
        else {
            if (sunk) {
                AudioServicesPlaySystemSound(_soundSunk);
            }
            else if (hit) {
                AudioServicesPlaySystemSound(_soundHit);
            }
        }
    }
}

- (void)next {
    NSInteger whoshouldhit = [_refGame whoShouldHit];
    if (whoshouldhit == 0) {
        AudioServicesPlaySystemSound(_soundWin);
        
        _whoShouldHitOrTap = 0;
        [self updatePlayerLabels];
        NSInteger winner = [_refGame winner];
        _statusText = [NSString stringWithFormat:@"%@ wins",[self nameForPlayer:winner]];
        [self updateStatusLabelAnimated:YES];
        return;
    }
    
    _whoShouldHitOrTap = whoshouldhit;
    [self updatePlayerLabels];
    
    
    if (whoshouldhit == [_refGame computerPlayer] && !_aiTimer) {
        _aiHasHit = NO;
        _aiHittingPlayer = whoshouldhit;
        [_refGame calcComputerHitOutAtX:&_aiHittingX outAtY:&_aiHittingY outType:&_aiHittingType];
        
        double thinktime = _aiHittingType == 1? 0.4: _aiHittingType == 2? 0.4: 0.4;
        thinktime = (thinktime + 0.01 * arc4random_uniform(10)) / _refOptions.animationSpeed;
        
        _aiTimer = [NSTimer scheduledTimerWithTimeInterval:thinktime target:self selector:@selector(firedAiTimer:) userInfo:nil repeats:NO];
        [self updateStatusLabelAnimated:NO];
    }
}

- (void)firedAiTimer:(NSTimer *)timer {
    _aiTimer = nil;
    if (!_aiHasHit) {
        if (![_refGame canHitForPlayer:_aiHittingPlayer atX:_aiHittingX atY:_aiHittingY]) {
            [self updateStatusLabelAnimated:NO];
            return;
        }
        BOOL hit, sunk;
        [_refGame hitForPlayer:_aiHittingPlayer atX:_aiHittingX atY:_aiHittingY outHit:&hit outSunk:&sunk];
        [self updateGridAndScores];
        _statusText = sunk? [NSString stringWithFormat:@"%@ scored", [self nameForPlayer:_aiHittingPlayer]] : @" ";
        [self updateStatusLabelAnimated:YES];
        if ([_refGame winner] != 0) {
            [self next];
        }
        else {
            if (sunk) {
                AudioServicesPlaySystemSound(_soundSunk);
            }
            else if (hit) {
                AudioServicesPlaySystemSound(_soundHit);
            }
            
            _aiHasHit = YES;
            double thinktime = sunk? 0.4: hit? 0.4: 0.4;
            thinktime = (thinktime + 0.01 * arc4random_uniform(10)) / _refOptions.animationSpeed;
            _aiTimer = [NSTimer scheduledTimerWithTimeInterval:thinktime target:self selector:@selector(firedAiTimer:) userInfo:nil repeats:NO];
        }
    }
    else {
        NSInteger whoshouldhit = [_refGame whoShouldHit];
        if (whoshouldhit != 0) {
            _toggled = whoshouldhit;
            [self updateToggledGridAnimated:YES];
        }
        [self next];
    }
}

- (void)panned:(UIPanGestureRecognizer *)sender {
    if (![self isViewLoaded]) {
        return;
    }
    
    if ([sender translationInView:self.view].x > 10) {
        _toggled = 1;
        [self updateToggledGridAnimated:YES];
        [sender setTranslation:CGPointZero inView:self.view];
    }
    if ([sender translationInView:self.view].x < -10) {
        _toggled = 2;
        [self updateToggledGridAnimated:YES];
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self updateGridAndScores];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
