//
//  MyAnnotation.m
//  FLAGProj
//
//  Created by Francisco Farinha on 29/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

@synthesize coordinate;

-(instancetype)initWithCoordinates:(CLLocationCoordinate2D)coords {
    self = [super init];
    if(self) {
        self.coordinate = coords;
    }
    return self;
}

-(instancetype)initWithCoordinates:(CLLocationCoordinate2D)coords andTitle:(NSString*)title andSubTitle:(NSString*)subtitle {
    self = [self initWithCoordinates:coords];
    if(self) {
        self.title = title;
        self.subtitle = subtitle;
    }
    return self;
}

@end
