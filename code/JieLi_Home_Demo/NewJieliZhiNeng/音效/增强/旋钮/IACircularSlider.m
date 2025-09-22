//
//  IACircularSlider.m
//  CustomCircularSlider
//
//  Created by user on 01.01.17.
//  Copyright © 2017 I&N. All rights reserved.
//

#import "IACircularSlider.h"
#import "IACircleSliderThumbLayer.h"
#import "JL_RunSDK.h"
#import "JLUI_Cache.h"
#import "JLCacheBox.h"
#import "IACircularSliderTrackLayer.h"


NSString *kUI_JL_EFCIRCULAR_BEGIN_TOUCH = @"UI_JL_EFCIRCULAR_BEGIN_TOUCH";
NSString *kUI_JL_EFCIRCULAR_END_TOUCH   = @"UI_JL_EFCIRCULAR_END_TOUCH";
NSString *kUI_JL_REVERBERATION_END_TOUCH= @"UI_JL_REVERBERATION_END_TOUCH";

@implementation IACircularSlider
{
    IACircularSliderTrackLayer* _trackLayer;
    IACircleSliderThumbLayer* _thumbLayer;
    CGPoint _center;
    UITouch* _lastTouch;
    CGFloat _rad;
    BOOL _isInitiallySet;
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeComponents];
    }
    return self;
}

-(void)updateLayers{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [_trackLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [_trackLayer setNeedsDisplay];
    
    CGPoint point = [self mapRadianToPoint:self.radian];
    if (!_isInitiallySet) {
        point = [self mapRadianToPoint:[self radianForValue:self.value]];
        _isInitiallySet = YES;
        self.radian = [self radianForValue:self.value];
    }
//    if(isnan(point.x)||isnan(point.y)){
////        return;
//        point.x = 46.391304;
//    }
//    if(isnan(point.y)){
//        point.y = 3.500000;
//    }
//    kJLLog(JLLOG_DEBUG,@"mapRadianToPoint:%f,%f self.radian:%f self.value:%f",point.x,point.y,self.radian,self.value);
//    kJLLog(JLLOG_DEBUG,@"setFrame:x:%f,y:%f,w:%f,h:%f",point.x-self.thumbWidth/2, point.y-self.thumbWidth/2,
//          self.thumbWidth, self.thumbWidth);
    CGFloat x = point.x - self.thumbWidth/2;
    CGFloat y = point.y - self.thumbWidth/2;
    if (!isnan(x) && !isnan(y) && !isnan(self.thumbWidth) && self.thumbWidth > 0)  {
        [_thumbLayer setFrame:CGRectMake(point.x-self.thumbWidth/2, point.y-self.thumbWidth/2,
                                         self.thumbWidth, self.thumbWidth)];
        [_thumbLayer setNeedsDisplay];
    }
    [CATransaction commit];
}

-(void)initializeComponents{
    self.minimumValue = 0.0;
    self.maximumValue = 31.0;
    self.value = 10;
    
    self.startAngle = 0;
    self.endAngle = M_PI;
    self.clockwise = YES;
    
    self.thumbTintColor = [UIColor blueColor];
    self.thumbHighlightedTintColor = [UIColor blackColor];
    self.trackTintColor = [UIColor lightGrayColor];
    self.trackHighlightedTintColor = [UIColor blueColor];
    
    self.trackWidth = 10.f;
    self.thumbWidth = 20.f;
    self.isCapRound = YES;
    
    _trackLayer = [IACircularSliderTrackLayer layer];
    _thumbLayer = [IACircleSliderThumbLayer layer];
    
    _trackLayer.contentsScale = [UIScreen mainScreen].scale;
    _thumbLayer.contentsScale = [UIScreen mainScreen].scale;
    
    _thumbLayer.slider = self;
    _trackLayer.slider = self;
    
    
    [self.layer addSublayer:_trackLayer];
    [self.layer addSublayer:_thumbLayer];
    
    _isInitiallySet = NO;
    [self updateLayers];
}

-(CGFloat)radianForValue:(CGFloat)value{
    CGFloat val = ((value-self.minimumValue)/(self.maximumValue-self.minimumValue))*[self distance];
    
    return self.clockwise? val+self.startAngle : -val+self.startAngle;
}

-(CGFloat)valueForRadian:(CGFloat)radian{
    CGFloat d = [self distance];
    return (radian-((2*M_PI-d)/2))*(self.maximumValue-self.minimumValue)/[self distance]+self.minimumValue;
}

-(CGPoint)mapRadianToPoint:(CGFloat)radian{
    return CGPointMake((_center.x-self.trackWidth/2)*cos(radian)+_center.x,
                       (( _center.y - self.trackWidth/2)*sin(radian)+_center.y));
}

-(CGFloat)distance{
    if (self.endAngle>self.startAngle) {
        if (self.clockwise) {
            return self.endAngle-self.startAngle;
        }else{
            return 2*M_PI-(self.endAngle-self.startAngle);
        }
    }else{
        if (self.clockwise) {
            return 2*M_PI-(self.startAngle-self.endAngle);
        }else{
            return self.startAngle-self.endAngle;
        }
    }
}


-(CGFloat)radianForPoint:(CGPoint)point{
    CGFloat val = 0;
    CGFloat x1 = point.x, x0 = _center.x, y1 = point.y, y0 = _center.y;
    
    if (x1>x0&&y1>y0) {
        val = atan((y1-y0)/(x1-x0));
    }else if (x1<x0&&y1>y0){
        val = atan((x0-x1)/(y1-y0))+M_PI/2;
    }else if (x1<x0&&y1<y0){
        val =  atan((y0-y1)/(x0-x1))+M_PI;
    }else if (x1>x0&&y1<y0){
        val = atan((x1-x0)/(y0-y1))+3*M_PI/2;
    }
    
    if (x1==x0) {
        if (y1>y0) {
            val = M_PI/2;
        }else{
            val = 3*M_PI/2;
        }
    }else if (y1==y0){
        if (x1<x0) {
            val = M_PI;
        }
    }
    
    return val;
}

-(CGFloat)transformRadianForCurrentOptions:(CGFloat)rad forStartAngle:(CGFloat)startAngle{
    CGFloat val = 0;
    
    if (self.clockwise) {
        if (rad>startAngle) {
            val =  rad - startAngle;
        }else if (rad<startAngle){
            val = 2*M_PI-startAngle+rad;
        }
    }else{
        if (rad>startAngle) {
            val = 2*M_PI -rad + startAngle;
        }else if (rad<startAngle){
            val = startAngle-rad;
        }
    }
    
    return val;
}

-(CGFloat)reverseTransformForModifiedStartAngleToDefault:(CGFloat)rad{
    CGFloat val = 0;
    CGFloat startAngle = [self transformedStartAngle];
    
    if (self.clockwise) {
        if (rad>startAngle) {
            val =  rad + startAngle;
        }else if (rad<=startAngle){
            val = -2*M_PI+startAngle+rad;
        }
    }else{
        if (rad>startAngle) {
            val = 2*M_PI - rad + startAngle;
        }else if (rad<startAngle){
            val = startAngle-rad;
        }
    }
    
    return val;
}

-(CGFloat)transformedStartAngle{
    CGFloat sA = self.startAngle;
    CGFloat offset = (2*M_PI - [self distance])/2;
    if (sA>self.endAngle) {
        if (self.clockwise) {
            return sA-offset;
        }else{
            CGFloat v = sA+offset;
            if (v>2*M_PI) {
                v -= 2*M_PI;
            }
            return v;
        }
    }else{
        if (self.clockwise) {
            CGFloat v = self.endAngle+offset;
            if (v>2*M_PI) {
                v -= 2*M_PI;
            }
            return v;
        }else{
            return sA+offset;
        }
    }
}

-(CGFloat)reverseTransformRadian:(CGFloat)val{
    
    CGFloat rad = 0;
    
    if (self.clockwise) {
        if (val>self.startAngle) {
            rad = val + self.startAngle;
        }else if (val<self.startAngle){
            rad = val - 2*M_PI + self.startAngle;
        }
    }else{
        if (val>self.startAngle) {
            rad = 2*M_PI - val + self.startAngle;
        }else if (val<self.startAngle){
            rad = self.startAngle-val;
        }
    }
    
    return val;
    
}

-(CGFloat)boundValueForValue:(CGFloat)value{
    return MIN(value, self.maximumValue);
}

-(CGFloat)boundRadianForRadian:(CGFloat)radian{
    CGFloat d = [self distance];
    CGFloat tSa = (2*M_PI-d)/2;
    return MAX(MIN(tSa+d, radian), tSa);
}

-(void)setGradientColorForHighlightedTrackWithFirstColor:(UIColor*)firstColor
                                             secondColor:(UIColor*)secondColor
                                         colorsLocations:(CGPoint)locations
                                              startPoint:(CGPoint)startPoint
                                             andEndPoint:(CGPoint)endPoint{
    _trackHighlightedGradientFirstColor = firstColor;
    _trackHighlightedGradientSecondColor = secondColor;
    _trackHighlightedGradientColorsLocations = locations;
    _isTrackHighlightedGradient = YES;
    _gradientEndPoint = endPoint;
    _gradientStartPoint = startPoint;
    [_trackLayer setNeedsDisplay];
}

-(void)removeGradient{
    _isTrackHighlightedGradient = NO;
    [_trackLayer setNeedsDisplay];
}

-(void)setThumbImage:(UIImage*)thumbImage{
    [_thumbLayer setImage:thumbImage];
    
}


#pragma mark - Setters

-(void)setStartAngle:(CGFloat)startAngle{
    if (startAngle>2*M_PI||startAngle<0) {
        [NSException raise:@"Invalid value of startAngle" format:@"startAngle must be more than 0 and less than 2PI"];
    }
    _startAngle = startAngle;
    [self calculateForTouch:_lastTouch];
    [self updateLayers];
}

-(void)setEndAngle:(CGFloat)endAngle{
    if (endAngle>2*M_PI||endAngle<0) {
        [NSException raise:@"Invalid value of endAngle" format:@"endAngle must be more than 0 and less than 2PI"];
    }
    _endAngle = endAngle;
    [self calculateForTouch:_lastTouch];
    [self updateLayers];
}

-(void)setValue:(CGFloat)value{
    
    if (value>self.maximumValue||value<self.minimumValue) {
        value = self.minimumValue;
    }
    _value = value;
    _isInitiallySet = NO;
    [self updateLayers];
    
}

-(void)setClockwise:(BOOL)clockwise{
    _clockwise = clockwise;
    [self updateLayers];
}

-(void)setIsCapRound:(BOOL)isCapRound{
    _isCapRound = isCapRound;
    [self updateLayers];
}

-(void)setMinimumValue:(CGFloat)minimumValue{
    _minimumValue = minimumValue;
    [self updateLayers];
}

-(void)setMaximumValue:(CGFloat)maximumValue{
    _maximumValue = maximumValue;
    [self updateLayers];
}

-(void)setThumbWidth:(CGFloat)thumbWidth{
    _thumbWidth = thumbWidth;
    [self updateLayers];
}

-(void)setTrackWidth:(CGFloat)trackWidth{
    _trackWidth = trackWidth;
    [self updateLayers];
}

-(void)setThumbTintColor:(UIColor *)thumbTintColor{
    _thumbTintColor = thumbTintColor;
    [self updateLayers];
}

-(void)setThumbHighlightedTintColor:(UIColor *)thumbHighlightedTintColor{
    _thumbHighlightedTintColor = thumbHighlightedTintColor;
    [self updateLayers];
}

-(void)setTrackTintColor:(UIColor *)trackTintColor{
    _trackTintColor = trackTintColor;
    [self updateLayers];
}

-(void)setTrackHighlightedTintColor:(UIColor *)trackHighlightedTintColor{
    _trackHighlightedTintColor = trackHighlightedTintColor;
    [self updateLayers];
}


-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
    _isInitiallySet = NO;
    [self updateLayers];
    
}



#pragma mark - Tracking

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if(_type == 0){
        [JL_Tools post:kUI_JL_EFCIRCULAR_BEGIN_TOUCH Object:nil];
    }
    if (CGRectContainsPoint(_thumbLayer.frame, [touch locationInView:self])) {
        _thumbLayer.isHighlighted = YES;
        return YES;
        
    }
    
    return NO;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self calculateForTouch:touch];
    _lastTouch = touch;
    [self updateLayers];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

-(void)calculateForTouch:(UITouch*)touch{
    UIWindow *win = [DFUITools getWindow];
    
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    
    if(bleSDK.mBleMultiple.bleManagerState == CBManagerStatePoweredOn &&
       [[JLCacheBox cacheUuid:bleSDK.mBleUUID] callPhoneFlag]){ //通话中，禁止调节主音量\高低音
        [DFUITools showText:kJL_TXT("msg_call_tip") onView:win delay:1.0];
        return;
    }
    CGFloat preRad = [self radianForPoint:[touch locationInView:self]]; //radian from east
    
    CGFloat transN = [self transformRadianForCurrentOptions:preRad forStartAngle:[self transformedStartAngle]];
    
    CGFloat boundRadianTN = [self boundRadianForRadian:transN];
    
    CGFloat reversedBoundValue = [self reverseTransformForModifiedStartAngleToDefault:boundRadianTN];
    
    self.radian = reversedBoundValue;
    
    self.value = [self boundValueForValue:[self valueForRadian:transN]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(_type == 0){
        [JL_Tools post:kUI_JL_EFCIRCULAR_END_TOUCH Object:nil];
    }
    if(_type == 1){
        [JL_Tools post:kUI_JL_REVERBERATION_END_TOUCH Object:nil];
    }
    _thumbLayer.isHighlighted = NO;
    [_thumbLayer setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_type == 0){
        [JL_Tools post:kUI_JL_EFCIRCULAR_END_TOUCH Object:nil];
    }
    if(_type == 1){
        [JL_Tools post:kUI_JL_REVERBERATION_END_TOUCH Object:nil];
    }
    _thumbLayer.isHighlighted = NO;
    [_thumbLayer setNeedsDisplay];
}

@end
