//
//  ShipForPlayer.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "ShipForPlayer.h"
#import "DrawShip.h"

@implementation ShipForPlayer

- (void)updateContents {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    DrawShip *painter = [[DrawShip alloc] init];
    
    double gridsize = self.gridCellSize;
    if (!self.hasGridCellSize) {
        gridsize = self.vertical? self.bounds.size.width: self.bounds.size.height;
    }
    double linewidth = gridsize * 0.08;
    double shipsize = gridsize * 0.9;
    double shipmargin = gridsize * 0.15;
    
    painter.shipMargin = shipmargin;
    painter.shipWidth = shipsize;
    painter.shipEdgeWidth = linewidth;
    painter.vertical = self.vertical;
    painter.reversed = self.reversed;
    painter.colorFill = [[ShipColor alloc] initWithR:0.47 g:0.4 b:0.91 a:1 - self.transparency];
    painter.colorEdge = [[ShipColor alloc] initWithR:0.47 g:0.4 b:0.91 a:1 - self.transparency];
    
    [painter paintShipInRect:self.bounds forContext:context];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
