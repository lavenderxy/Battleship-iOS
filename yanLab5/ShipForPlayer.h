//
//  ShipForPlayer.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawShip.h"

@interface ShipForPlayer : UIView
@property (nonatomic) BOOL vertical;
@property (nonatomic) BOOL reversed;
@property (nonatomic) BOOL hasGridCellSize;
@property (nonatomic) double gridCellSize;
@property (nonatomic) double transparency;
- (void)updateContents;

@end
