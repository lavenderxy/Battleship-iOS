//
//  DrawShip.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShipColor : NSObject<NSCopying> {
    double _rgba[4];
}
@property (nonatomic) double r;
@property (nonatomic) double g;
@property (nonatomic) double b;
@property (nonatomic) double a;
- (id)initWithR:(double)r g:(double)g b:(double)b a:(double)a;
- (double *)data;
- (UIColor *)toUiColor;

@end

@interface DrawShip : NSObject
@property (nonatomic) double shipMargin;
@property (nonatomic) double shipWidth;
@property (nonatomic) double shipEdgeWidth;
@property (nonatomic) BOOL vertical;
@property (nonatomic) BOOL reversed;
@property (copy, nonatomic) ShipColor *colorFill;
@property (copy, nonatomic) ShipColor *colorEdge;
- (void)paintShipInRect:(CGRect)rect forContext:(CGContextRef)context;

@end

@interface CirclePainter : NSObject
@property (nonatomic) double circleWidth;
@property (nonatomic) double circleEdgeWidth;
@property (copy, nonatomic) ShipColor *colorFill;
@property (copy, nonatomic) ShipColor *colorEdge;
- (void)paintCircleInRect:(CGRect)rect forContext:(CGContextRef)context;

@end

@interface CrossPainter : NSObject
@property (nonatomic) double crossWidth;
@property (nonatomic) double crossEdgeWidth;
@property (copy, nonatomic) ShipColor *colorFill;
@property (copy, nonatomic) ShipColor *colorEdge;
- (void)paintCrossInRect:(CGRect)rect forContext:(CGContextRef)context;


@end
