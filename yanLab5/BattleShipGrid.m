//
//  BattleShipGrid.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "BattleShipGrid.h"
#import "DrawShip.h"

@implementation BattleShipGrid

- (void)initForRefGame:(GameLogic *)refGame player:(NSInteger)player placing:(BOOL)placing showMyShips:(BOOL)showMyShips {
    _refGame = refGame;
    _player = player;
    _placing = placing;
    _showMyShips = showMyShips;
}

- (void)updateContents {
    [self setNeedsDisplay];
}

- (void)pointToGridPoint:(CGPoint)point out:(CGPoint *)gridpoint {
    CGFloat ox = self.bounds.origin.x;
    CGFloat oy = self.bounds.origin.y;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    double margin = 0.03;
    
    NSInteger n = [_refGame gridWidth];
    
    gridpoint->x = (point.x - (ox + margin * w)) / ((1 - 2 * margin) * w) * n;
    gridpoint->y = (point.y - (oy + margin * h)) / ((1 - 2 * margin) * h) * n;
}

- (void)gridPointToPoint:(CGPoint)gridpoint out:(CGPoint *)point {
    CGFloat ox = self.bounds.origin.x;
    CGFloat oy = self.bounds.origin.y;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    double margin = 0.03;
    
    NSInteger n = [_refGame gridWidth];
    
    point->x = ox + margin * w + (1 - 2 * margin) * w / n * gridpoint.x;
    point->y = oy + margin * h + (1 - 2 * margin) * h / n * gridpoint.y;
}

- (void)rectToGridRect:(CGRect)rect out:(CGRect *)gridrect {
    CGPoint p;
    CGPoint gridp;
    
    p.x = rect.origin.x + rect.size.width;
    p.y = rect.origin.y + rect.size.height;
    
    [self pointToGridPoint:rect.origin out:&gridrect->origin];
    [self pointToGridPoint:p out:&gridp];
    
    gridrect->size.width = gridp.x - gridrect->origin.x;
    gridrect->size.height = gridp.y - gridrect->origin.y;
}

- (void)gridRectToRect:(CGRect)gridrect out:(CGRect *)rect {
    CGPoint gridp;
    CGPoint p;
    
    gridp.x = gridrect.origin.x + gridrect.size.width;
    gridp.y = gridrect.origin.y + gridrect.size.height;
    
    [self gridPointToPoint:gridrect.origin out:&rect->origin];
    [self gridPointToPoint:gridp out:&p];
    
    rect->size.width = p.x - rect->origin.x;
    rect->size.height = p.y - rect->origin.y;
}

- (double)gridCellSize {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    NSInteger n = [_refGame gridWidth];
    
    double margin = 0.03;
    double gridsize = (1 - 2 * margin) * MIN(w, h) / n;
    
    return gridsize;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat ox = self.bounds.origin.x;
    CGFloat oy = self.bounds.origin.y;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSInteger n = [_refGame gridWidth];
    
    double margin = 0.03;
    double gridsize = (1 - 2 * margin) * MIN(w, h) / n;
    double gridwsize = (1 - 2 * margin) * w / n;
    double gridhsize = (1 - 2 * margin) * h / n;
    double linewidth = gridsize * 0.08;
    double circlesize = gridsize * 0.8;
    double crosssize = gridsize * 0.8;
    double shipsize = gridsize * 0.9;
    double shipmargin = gridsize * 0.15;
    
    // draw grids
    for (NSInteger i = 0; i < n + 1; ++i)
    {
        double x = ox + margin * w + i * gridwsize;
        double y1 = oy + margin * h;
        double y2 = oy + (1 - margin) * h;
        CGContextMoveToPoint(context, x, y1);
        CGContextAddLineToPoint(context, x, y2);
    }
    CGContextSetLineWidth(context, gridwsize * 0.05);
    [[UIColor blackColor] setStroke];
    CGContextDrawPath(context, kCGPathStroke);
    for (NSInteger i = 0; i < n + 1; ++i)
    {
        double x1 = ox + margin * w;
        double x2 = ox + (1 - margin) * w;
        double y = oy + margin * h + i * gridhsize;
        CGContextMoveToPoint(context, x1, y);
        CGContextAddLineToPoint(context, x2, y);
    }
    CGContextSetLineWidth(context, gridhsize * 0.05);
    [[UIColor blackColor] setStroke];
    CGContextDrawPath(context, kCGPathStroke);
    
    // draw ships
    CGContextBeginPath(context);
    NSInteger numships = 0;
    ship_t ships[20];
    if (_placing) {
        for (NSInteger i = 0; i < [_refGame numShipsForPlayer:_player]; ++i) {
            ship_t ship = [_refGame shipForPlayer:_player atIndex:i];
            if (ship.placed) {
                ships[numships] = ship;
                ++numships;
            }
        }
    }
    if ([_refGame winner] != 0 ||
        (_showMyShips && [_refGame shipsVisibleForPlayer:3 - _player])) {
        for (NSInteger i = 0; i < [_refGame numShipsForPlayer:3 - _player]; ++i) {
            ship_t ship = [_refGame shipForPlayer:3 - _player atIndex:i];
            if (ship.placed) {
                ships[numships] = ship;
                ++numships;
            }
        }
    }
    DrawShip *painter = [[DrawShip alloc] init];
    for (NSInteger i = 0; i < numships; ++i) {
        ship_t *s = &ships[i];
        
        painter.shipMargin = shipmargin;
        painter.shipWidth = shipsize;
        painter.shipEdgeWidth = linewidth;
        painter.vertical = s->vertical;
        painter.reversed = s->reversed;
        if (s->hitCount >= s->length) {
            painter.colorFill = [[ShipColor alloc] initWithR:0.47 g:0.4 b:0.91 a:0.0];
            painter.colorEdge = [[ShipColor alloc] initWithR:0.47 g:0.4 b:0.91 a:1.0];
        }
        else if (s->hitCount > 0) {
            painter.colorFill = [[ShipColor alloc] initWithR:1.0 g:0.38 b:0.0 a:1.0];
            painter.colorEdge = [[ShipColor alloc] initWithR:1.0 g:0.38 b:0.0 a:1.0];
        }
        else {
            painter.colorFill = [[ShipColor alloc] initWithR:0.47 g:0.4 b:0.91 a:1.0];
            painter.colorEdge = [[ShipColor alloc] initWithR:0.47 g:0.4 b:0.91 a:1.0];
        }
        double x1 = ox + margin * w + s->position[0] * gridwsize;
        double y1 = oy + margin * h + s->position[1] * gridhsize;
        double x2 = x1 + (s->vertical? 1: s->length) * gridwsize;
        double y2 = y1 + (s->vertical? s->length: 1) * gridhsize;
        [painter paintShipInRect:CGRectMake(x1, y1, x2 - x1, y2 - y1) forContext:context];
    }
    
    // draw crosses
    CrossPainter *crosspainter = [[CrossPainter alloc] init];
    crosspainter.crossWidth = crosssize;
    crosspainter.crossEdgeWidth = linewidth;
    crosspainter.colorFill = [[ShipColor alloc] initWithR:1.0 g:0.0 b:0.0 a:1.0];
    crosspainter.colorEdge = [[ShipColor alloc] initWithR:1.0 g:0.0 b:0.0 a:1.0];
    for (NSInteger i = 0; i < n; ++i) {
        for (NSInteger j = 0; j < n; ++j) {
            if ([_refGame gridItemForPlayer:_player atX:i atY:j] == 2) {
                double x1 = ox + margin * w + i * gridwsize;
                double y1 = oy + margin * h + j * gridhsize;
                double x2 = x1 + gridwsize;
                double y2 = y1 + gridhsize;
                [crosspainter paintCrossInRect:CGRectMake(x1, y1, x2 - x1, y2 - y1) forContext:context];
            }
        }
    }
    
    // draw circles
    CirclePainter *circlepainter = [[CirclePainter alloc] init];
    circlepainter.circleWidth = circlesize;
    circlepainter.circleEdgeWidth = linewidth;
    circlepainter.colorFill = [[ShipColor alloc] initWithR:0.53 g:0.8 b:0.92 a:1.0];
    circlepainter.colorEdge = [[ShipColor alloc] initWithR:0.53 g:0.8 b:0.92 a:1.0];
    for (NSInteger i = 0; i < n; ++i) {
        for (NSInteger j = 0; j < n; ++j) {
            if ([_refGame gridItemForPlayer:_player atX:i atY:j] == 1) {
                double x1 = ox + margin * w + i * gridwsize;
                double y1 = oy + margin * h + j * gridhsize;
                double x2 = x1 + gridwsize;
                double y2 = y1 + gridhsize;
                [circlepainter paintCircleInRect:CGRectMake(x1, y1, x2 - x1, y2 - y1) forContext:context];
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
