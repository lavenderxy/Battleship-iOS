//
//  DrawShip.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "DrawShip.h"

@implementation ShipColor

- (void)setR:(double)r {
    _rgba[0] = r;
}

- (double)r {
    return _rgba[0];
}

- (void)setG:(double)g {
    _rgba[1] = g;
}

- (double)g {
    return _rgba[1];
}

- (void)setB:(double)b {
    _rgba[2] = b;
}

- (double)b {
    return _rgba[2];
}

- (void)setA:(double)a {
    _rgba[3] = a;
}

- (double)a {
    return _rgba[3];
}

- (id)initWithR:(double)r g:(double)g b:(double)b a:(double)a {
    self = [super init];
    if (self) {
        self.r = r;
        self.g = g;
        self.b = b;
        self.a = a;
    }
    return self;
}

- (double *)data {
    return _rgba;
}

- (UIColor *)toUiColor {
    return [[UIColor alloc] initWithRed:self.r green:self.g blue:self.b alpha:self.a];
}

- (id)copyWithZone:(NSZone *)zone {
    ShipColor *copy = [[ShipColor allocWithZone:zone] init];
    for (NSInteger i = 0; i < 4; ++i) {
        copy->_rgba[i] = _rgba[i];
    }
    return copy;
}

@end

@implementation DrawShip

void setPoint(double point[2], double x, double y) {
    point[0] = x;
    point[1] = y;
}

void rotatePoints180(double (*points)[2], NSInteger numpoints, const double center[2]) {
    for (NSInteger i = 0; i < numpoints; ++i) {
        double *point = &points[i][0];
        point[0] = 2 * center[0] - point[0];
        point[1] = 2 * center[1] - point[1];
    }
}

void rotatePoints90(double (*points)[2], NSInteger numpoints, double center[2], const double changecenter[2]) {
    for (NSInteger i = 0; i < numpoints; ++i) {
        double *point = &points[i][0];
        double tmp = point[0];
        point[0] = changecenter[0] - (point[1] - center[1]);
        point[1] = changecenter[1] + (tmp - center[0]);
    }
    center[0] = changecenter[0];
    center[1] = changecenter[1];
}

void movePointsIntoRect(double (*points)[2], NSInteger numpoints, double center[2], CGRect rect) {
    double move[2];
    setPoint(move, rect.origin.x + rect.size.width / 2 - center[0], rect.origin.y + rect.size.height / 2 - center[1]);
    for (NSInteger i = 0; i < numpoints; ++i) {
        double *point = &points[i][0];
        point[0] += move[0];
        point[1] += move[1];
    }
    center[0] += move[0];
    center[1] += move[1];
}

- (void)paintShipInRect:(CGRect)rect forContext:(CGContextRef)context {
    NSInteger numpoints = 5;
    double points[5][2];
    double canvash = self.shipWidth;
    double canvasw = (self.vertical? rect.size.height: rect.size.width) - 2 * self.shipMargin;
    double center[2];
    setPoint(center, canvasw / 2, canvash / 2);
    
    setPoint(points[0], 0, canvash);
    setPoint(points[1], 0, 0);
    setPoint(points[2], canvasw - 0.7 * canvash, 0);
    setPoint(points[3], canvasw, 0.5 * canvash);
    setPoint(points[4], canvasw - 0.7 * canvash, canvash);
    
    if (self.reversed) {
        rotatePoints180(points, numpoints, center);
    }
    if (self.vertical) {
        double changecenter[2];
        setPoint(changecenter, center[1], center[0]);
        rotatePoints90(points, numpoints, center, changecenter);
    }
    movePointsIntoRect(points, numpoints, center, rect);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, points[0][0], points[0][1]);
    for (NSInteger j = 1; j < numpoints; ++j) {
        CGContextAddLineToPoint(context, points[j][0], points[j][1]);
    }
    CGContextClosePath(context);
    CGContextSetLineWidth(context, self.shipEdgeWidth);
    [[self.colorFill toUiColor] setFill];
    [[self.colorEdge toUiColor] setStroke];
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

@implementation CirclePainter

- (void)paintCircleInRect:(CGRect)rect forContext:(CGContextRef)context {
    NSInteger numpoints = 2;
    double points[2][2];
    double canvash = self.circleWidth;
    double canvasw = self.circleWidth;
    double center[2];
    setPoint(center, canvasw / 2, canvash / 2);
    
    setPoint(points[0], canvasw, canvash / 2);
    setPoint(points[1], 0, canvash / 2);
    
    movePointsIntoRect(points, numpoints, center, rect);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, points[0][0], points[0][1]);
    double r = fabs(points[0][0] - center[0]);
    CGContextAddArc(context, center[0], center[1], r, 0.0, M_PI, NO);
    CGContextAddArc(context, center[0], center[1], r, M_PI, 0, NO);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, self.circleEdgeWidth);
    [[self.colorEdge toUiColor] setStroke];
    [[self.colorFill toUiColor] setFill];
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

@implementation CrossPainter

- (void)paintCrossInRect:(CGRect)rect forContext:(CGContextRef)context {
    NSInteger numpoints = 12;
    double points[12][2];
    double canvash = self.crossWidth;
    double canvasw = self.crossWidth;
    double center[2];
    setPoint(center, 0, 0);
    
    setPoint(points[0], canvasw * 0.2, canvash * 0.0);
    setPoint(points[1], canvasw * 0.5, canvash * 0.3);
    setPoint(points[2], canvasw * 0.3, canvash * 0.5);
    setPoint(points[3], canvasw * 0.0, canvash * 0.2);
    setPoint(points[4], canvasw * -.3, canvash * 0.5);
    setPoint(points[5], canvasw * -.5, canvash * 0.3);
    setPoint(points[6], canvasw * -.2, canvash * -.0);
    setPoint(points[7], canvasw * -.5, canvash * -.3);
    setPoint(points[8], canvasw * -.3, canvash * -.5);
    setPoint(points[9], canvasw * -.0, canvash * -.2);
    setPoint(points[10], canvasw * 0.3, canvash * -.5);
    setPoint(points[11], canvasw * 0.5, canvash * -.3);
    
    movePointsIntoRect(points, numpoints, center, rect);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, points[0][0], points[0][1]);
    for (NSInteger j = 1; j < numpoints; ++j) {
        CGContextAddLineToPoint(context, points[j][0], points[j][1]);
    }
    CGContextClosePath(context);
    CGContextSetLineWidth(context, self.crossEdgeWidth);
    [[self.colorEdge toUiColor] setStroke];
    [[self.colorFill toUiColor] setFill];
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
