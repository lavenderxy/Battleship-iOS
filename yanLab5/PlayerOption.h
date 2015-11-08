//
//  PlayerOption.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerOption : NSObject
@property (nonatomic) double animationSpeed;
@property (nonatomic) BOOL showMyShips;
@property (nonatomic) NSInteger gridSize;
@property (copy, nonatomic) NSString *deviceName;
@property (nonatomic) BOOL isHumanTeam;
- (id)init;
- (void)saveDefaults;
- (void)loadDefaults;

@end
