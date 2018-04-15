//
//  MapViewController.m
//  FLAGProj
//
//  Created by Francisco Farinha on 29/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;



@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    

    
    
    NSNumber *lastLatitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_location_latitude"];
    NSNumber *lastLongitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_location_longitude"];
    NSString *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_location_date"];
    
    CLLocationDegrees lat = [lastLatitude doubleValue];
    CLLocationDegrees lon = [lastLongitude doubleValue];
    
    
    NSString *lastTimeYouUsedTheApp = NSLocalizedString(@"lastLocation", nil);
    
    MyAnnotation *lastAnnotation = [[MyAnnotation alloc] initWithCoordinates:CLLocationCoordinate2DMake(lat, lon) andTitle: lastDate andSubTitle:lastTimeYouUsedTheApp];
    
    NSLog(@"%f , %f , %@ , %@", lat , lon, lastLatitude, lastLongitude);
    
    [self.mapView addAnnotation:lastAnnotation];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *lastUserLocation = locations.lastObject;
    MKCoordinateRegion zoomCenter = MKCoordinateRegionMake(lastUserLocation.coordinate, MKCoordinateSpanMake(0.005, 0.005));
    

    
    NSDate *loadingDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:loadingDate];
    
    NSString *youAreHere = NSLocalizedString(@"youAreHere", nil);
  
    MyAnnotation *newAnnotation = [[MyAnnotation alloc] initWithCoordinates:locations.lastObject.coordinate andTitle: formattedDateString andSubTitle: youAreHere];
    
   
    
    NSNumber *latitude = [NSNumber numberWithDouble:locations.lastObject.coordinate.latitude];
    
    NSNumber *longitude = [NSNumber numberWithDouble:locations.lastObject.coordinate.longitude];
    
    NSLog(@"%f , %f , %@ , %@", locations.lastObject.coordinate.latitude , locations.lastObject.coordinate.longitude, latitude, longitude);
    

    
    
    [[NSUserDefaults standardUserDefaults] setObject: latitude forKey:@"last_location_latitude"];
    [[NSUserDefaults standardUserDefaults] setObject: longitude forKey:@"last_location_longitude"];
    [[NSUserDefaults standardUserDefaults] setObject: formattedDateString forKey:@"last_location_date"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

    
    [self.mapView addAnnotation: newAnnotation];
    
    

    [self.mapView setRegion:zoomCenter];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
