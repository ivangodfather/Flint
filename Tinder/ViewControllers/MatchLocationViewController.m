//
//  MatchLocationViewController.m
//  Tinder
//
//  Created by John Blanchard on 9/6/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "MatchLocationViewController.h"
#import "SWRevealViewController.h"
#import "UserParse.h"
#import <MapKit/MapKit.h>

@interface MatchLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchButton;
@property (weak, nonatomic) IBOutlet UISwitch *theSwitch;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property UserParse* curUser;
@property BOOL switchCurrentLocation;
@property CLLocation* currentLocation;
@property CLLocationManager* locationManager;
@end

@implementation MatchLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sideBarButton.target = self.revealViewController;
    _sideBarButton.action = @selector(revealToggle:);
    self.searchTextField.backgroundColor = GRAY_COLOR;
    self.mapView.delegate = self;
    PFQuery* curQuery = [UserParse query];
    [curQuery whereKey:@"username" equalTo:[UserParse currentUser].username];
    [curQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.curUser = objects.firstObject;
        NSLog(@"From map %f %f", self.curUser.geoPoint.latitude , self.curUser.geoPoint.longitude);
        [self placeUserOnMap];
    }];
    // Do any additional setup after loading the view.
}

- (void) placeUserOnMap
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    MKCircle* circle = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(self.curUser.geoPoint.latitude, self.curUser.geoPoint.longitude) radius:self.curUser.distance.doubleValue*1000];
    MKPointAnnotation* annotation = [MKPointAnnotation new];
    annotation.coordinate = CLLocationCoordinate2DMake(self.curUser.geoPoint.latitude, self.curUser.geoPoint.longitude);
    [self.mapView addAnnotation:annotation];
    [self.mapView addOverlay:circle];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.curUser.geoPoint.latitude, self.curUser.geoPoint.longitude), self.curUser.distance.doubleValue*2100, self.curUser.distance.doubleValue*2100);
    [self.mapView setRegion:region];
    [self.mapView reloadInputViews];
    if ([self.curUser.useAddress isEqualToString:@"YES"]) {
        self.switchCurrentLocation = NO;
        self.theSwitch.on = NO;
        self.searchButton.hidden = NO;
        self.searchTextField.enabled = YES;
        self.searchTextField.textAlignment = NSTextAlignmentCenter;
        annotation.title = @"Your Simulated Location";
        CLGeocoder* geocoder = [CLGeocoder new];
        CLLocation* location = [[CLLocation alloc]initWithLatitude:self.curUser.geoPoint.latitude longitude:self.curUser.geoPoint.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = placemarks.firstObject;
            self.searchTextField.placeholder = [NSString stringWithFormat:@"Simulated Location: %@, %@", placemark.locality, placemark.administrativeArea];
        }];
    } else {
        self.switchCurrentLocation = YES;
        self.theSwitch.on = YES;
        self.searchButton.hidden = YES;
        self.searchTextField.enabled = NO;
        annotation.title = @"Your Real Location";
        CLGeocoder* geocoder = [CLGeocoder new];
        CLLocation* location = [[CLLocation alloc]initWithLatitude:self.curUser.geoPoint.latitude longitude:self.curUser.geoPoint.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = placemarks.firstObject;
            self.searchTextField.text = [NSString stringWithFormat:@"Current Location: %@, %@", placemark.locality, placemark.administrativeArea];
            self.searchTextField.textAlignment = NSTextAlignmentCenter;
        }];
    }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircle *circle = (MKCircle *)overlay;
    MKCircleRenderer* render = [[MKCircleRenderer alloc] initWithCircle:circle];
    render.fillColor = BLUE_COLOR;
    render.alpha = 0.6;
    return render;
}

-(void)currentLocationIdentifier
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    [self.locationManager stopUpdatingLocation];
    self.curUser.geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    [self.curUser saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self placeUserOnMap];
        }
    }];
}

- (IBAction)switchHIt:(id)sender
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    if (self.theSwitch.on) {
        self.searchButton.hidden = YES;
        self.searchTextField.enabled = NO;
        [self currentLocationIdentifier];
        CLGeocoder* geocoder = [CLGeocoder new];
        CLLocation* location = [[CLLocation alloc]initWithLatitude:self.curUser.geoPoint.latitude longitude:self.curUser.geoPoint.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = placemarks.firstObject;
            self.searchTextField.text = [NSString stringWithFormat:@"Current Location: %@, %@", placemark.locality, placemark.administrativeArea];
            self.searchTextField.textAlignment = NSTextAlignmentCenter;
        }];
        if ([self.curUser.useAddress isEqualToString:@"YES"]) {
            self.curUser.useAddress = @"NO";
            [self.curUser saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self currentLocationIdentifier];
                }
            }];
        }
    } else {
        self.searchButton.hidden = NO;
        self.searchTextField.enabled = YES;
        self.searchTextField.text = @"";
        self.searchTextField.placeholder = @"Enter a location to match from.";
    }
}

- (IBAction)searchDidEnd:(id)sender
{
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder geocodeAddressString:self.searchTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark* placemark = placemarks.firstObject;
            self.curUser.geoPoint = [PFGeoPoint geoPointWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            NSLog(@"geo point = %f", self.curUser.geoPoint.latitude);
            self.curUser.useAddress = @"YES";
            [self.curUser saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self placeUserOnMap];
                }
            }];

        }
    }];
}

- (IBAction)editBegan:(id)sender
{
    self.searchTextField.textAlignment = NSTextAlignmentLeft;
}

@end
