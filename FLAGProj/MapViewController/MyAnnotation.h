//
//  MyAnnotation.h
//  FLAGProj
//
//  Created by Francisco Farinha on 29/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@interface MyAnnotation: NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) NSString *subtitle;

-(instancetype _Nullable )initWithCoordinates:(CLLocationCoordinate2D)coords;

-(instancetype _Nullable )initWithCoordinates:(CLLocationCoordinate2D)coords andTitle:(NSString*_Nullable)title andSubTitle:(NSString*_Nullable)subtitle;

@end
