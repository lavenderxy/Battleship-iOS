//
//  PlayerOption.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "PlayerOption.h"

@implementation PlayerOption

#define keyForAnimationSpeed @"animationspeed"
#define keyForShowMyShips @"showmyships"
#define keyForGridSize @"gridsize"
#define keyForDeviceName @"devicename"
#define keyForIsHumanTeam @"isHumanTeam"

- (id)init {
    self = [super init];
    if (self) {
        self.animationSpeed = 1.0;
        self.showMyShips = YES;
        self.gridSize = 10;
        self.deviceName = [NSString stringWithFormat:@"unnamed(%d)", (int)arc4random_uniform(1000)];
        self.isHumanTeam = YES;
    }
    return self;
}

- (void)saveDefaults {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [def setDouble:self.animationSpeed forKey:keyForAnimationSpeed];
    [def setBool:self.showMyShips forKey:keyForShowMyShips];
    [def setInteger:self.gridSize forKey:keyForGridSize];
    [def setValue:self.deviceName forKey:keyForDeviceName];
    [def setBool:self.isHumanTeam forKey:keyForIsHumanTeam];
    
    [def synchronize];
}

- (void)loadDefaults {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    BOOL tempBool;
    
    double animationSpeed = [def doubleForKey:keyForAnimationSpeed];
    if ([def objectForKey:keyForAnimationSpeed] == nil) {
        animationSpeed = 1.0;
    }
    self.animationSpeed = animationSpeed;
    
    tempBool = [def boolForKey:keyForIsHumanTeam];
    if ([def objectForKey:keyForIsHumanTeam]==nil) {
        tempBool=YES;
    }
    self.isHumanTeam=tempBool;
    
    BOOL showMyShips = [def boolForKey:keyForShowMyShips];
    if ([def objectForKey:keyForShowMyShips] == nil) {
        showMyShips = YES;
    }
    self.showMyShips = showMyShips;
    
    NSInteger gridSize = [def integerForKey:keyForGridSize];
    if ([def objectForKey:keyForGridSize] == nil) {
        gridSize = 10;
    }
    self.gridSize = gridSize;
    
    NSString *deviceName = [def stringForKey:keyForDeviceName];
    if (deviceName == nil) {
        deviceName = [NSString stringWithFormat:@"unnamed(%d)", (int)arc4random_uniform(1000)];
    }
    self.deviceName = deviceName;
}




@end
