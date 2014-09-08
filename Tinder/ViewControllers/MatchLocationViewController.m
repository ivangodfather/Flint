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
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property UserParse* curUser;
@property BOOL switchCurrentLocation;
@property CLLocation* currentLocation;
@property (weak, nonatomic) IBOutlet UISlider *sliderRadius;
@property CLLocationManager* locationManager;
@end

@implementation MatchLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sideBarButton.target = self.revealViewController;
    _sideBarButton.action = @selector(revealToggle:);
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.searchTextField.leftView = paddingView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.backgroundColor = GRAY_COLOR;
    self.distanceLabel.textColor = ORANGE_COLOR;
    self.sliderRadius.tintColor = ORANGE_COLOR;
    self.sliderRadius.thumbTintColor = ORANGE_COLOR;
    self.sliderRadius.minimumTrackTintColor = ORANGE_COLOR;
    self.theSwitch.onTintColor = ORANGE_COLOR;
    self.mapView.delegate = self;
    PFQuery* curQuery = [UserParse query];
    [curQuery whereKey:@"username" equalTo:[UserParse currentUser].username];
    [curQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.curUser = objects.firstObject;
        [self.sliderRadius setValue:self.curUser.distance.floatValue];
        self.distanceLabel.text = [NSString stringWithFormat:@"%dkm",(int)self.sliderRadius.value];
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
        self.searchButton.imageView.image = [UIImage imageNamed:@"magnifying-glass"];
        self.searchButton.userInteractionEnabled = YES;
        self.searchTextField.enabled = YES;
        self.searchTextField.textAlignment = NSTextAlignmentCenter;
        self.searchTextField.backgroundColor = GRAY_COLOR;
        self.searchTextField.textColor = WHITE_COLOR;
        annotation.title = @"Your Simulated Location";
        CLGeocoder* geocoder = [CLGeocoder new];
        CLLocation* location = [[CLLocation alloc]initWithLatitude:self.curUser.geoPoint.latitude longitude:self.curUser.geoPoint.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = placemarks.firstObject;
            self.searchTextField.placeholder = [NSString stringWithFormat:@"Simulated Location: %@, %@", placemark.locality, placemark.administrativeArea];
            self.centerButton.userInteractionEnabled = YES;
        }];
    } else {
        self.switchCurrentLocation = YES;
        self.theSwitch.on = YES;
        self.theSwitch.onImage = [UIImage imageNamed:@"location"];
        self.searchButton.imageView.image = [UIImage imageNamed:@"location"];
        self.searchButton.userInteractionEnabled = NO;
        self.searchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.searchTextField.enabled = NO;
        self.searchTextField.backgroundColor = BLUE_COLOR;
        self.searchTextField.textColor = ORANGE_COLOR;
        annotation.title = @"Your Real Location";
        CLGeocoder* geocoder = [CLGeocoder new];
        CLLocation* location = [[CLLocation alloc]initWithLatitude:self.curUser.geoPoint.latitude longitude:self.curUser.geoPoint.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = placemarks.firstObject;
            self.searchTextField.text = [NSString stringWithFormat:@"Current Location: %@, %@", placemark.locality, placemark.administrativeArea];
            self.searchTextField.textAlignment = NSTextAlignmentCenter;
            self.centerButton.userInteractionEnabled = YES;
        }];
    }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircle *circle = (MKCircle *)overlay;
    MKCircleRenderer* render = [[MKCircleRenderer alloc] initWithCircle:circle];
    render.fillColor = ORANGE_COLOR;
    render.alpha = 0.2;
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
        self.searchButton.imageView.image = [UIImage imageNamed:@"location"];
        self.searchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.searchTextField.enabled = NO;
        self.searchTextField.backgroundColor = BLUE_COLOR;
        self.searchTextField.textColor = ORANGE_COLOR;
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
        self.searchButton.imageView.image = [UIImage imageNamed:@"magnifying-glass"];
        self.searchTextField.enabled = YES;
        self.searchTextField.backgroundColor = GRAY_COLOR;
        self.searchTextField.textColor = WHITE_COLOR;
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

- (IBAction)distanceChangeEnd:(UISlider *)sender
{
    self.curUser.distance = [NSNumber numberWithInt:(int)sender.value];
    [self.curUser saveEventually:^(BOOL succeeded, NSError *error) {
        [self placeUserOnMap];
    }];
}

- (IBAction)distanceChangedOutside:(UISlider *)sender
{
    self.curUser.distance = [NSNumber numberWithInt:(int)sender.value];
    [self.curUser saveEventually:^(BOOL succeeded, NSError *error) {
        [self placeUserOnMap];
    }];
}

- (IBAction)sliderMoved:(UISlider *)sender
{
    self.distanceLabel.text = [NSString stringWithFormat:@"%dkm",(int)sender.value];

}

- (IBAction)editBegan:(id)sender
{
    self.searchTextField.textAlignment = NSTextAlignmentLeft;
}

- (IBAction)tapCenterButton:(id)sender
{
    self.centerButton.userInteractionEnabled = NO;
    [self placeUserOnMap];
}

@end
