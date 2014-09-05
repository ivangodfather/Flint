//
//  MainViewController.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 25/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "MainViewController.h"
#import "SWRevealViewController.h"
#import "UserParse.h"
#import "PossibleMatch.h"
#import "MessageParse.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MatchViewController.h"

#define labelHeight 20
#define labelCushion 20
#define MARGIN 50
#define imageMargin 10

#define buttonWidth 40
#define buttonHeight 50

#define currentProfileView 5
#define currentProfileImage 4
#define profileViewTag 3
#define likeViewTag 2
#define dislikeViewTag 1

#define cornRadius 10

@interface MainViewController () <UIGestureRecognizerDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UIView *profileView;
@property (strong, nonatomic) UIView* backgroundView;
@property UserParse* currShowingProfile;
@property UserParse* backgroundUserProfile;
@property NSMutableArray *posibleMatchesArray;
@property NSMutableArray* willBeMatches;
@property (strong, nonatomic) UIImageView* profileImage;
@property (strong, nonatomic) UIImageView* profileImageAge;
@property (strong, nonatomic) UIImageView* profileImageLocation;
@property (strong, nonatomic) UIImageView* backgroundImage;
@property (strong, nonatomic) UIImageView* backgroundImageAge;
@property (strong, nonatomic) UIImageView* backgroundImageLocation;
@property NSMutableArray* arrayOfPhotoDataForeground;
@property NSMutableArray* arrayOfPhotoDataBackground;
@property (strong, nonatomic) UILabel* foregroundLabel;
@property (strong, nonatomic) UILabel* backgroundLabel;
@property (strong, nonatomic) UILabel* foregroundLabelAge;
@property (strong, nonatomic) UILabel* backgroundLabelAge;
@property (strong, nonatomic) UILabel* foregroundLabelLocation;
@property (strong, nonatomic) UILabel* backgroundLabelLocation;
@property (strong, nonatomic) UILabel* foregroundDescriptionLabel;
@property (strong, nonatomic) UILabel* backgroundDescriptionLabel;
@property BOOL firstTime;
@property BOOL isRotating;
@property int photoArrayIndex;
@property CLLocationManager* locationManager;
@property CLLocation* currentLocation;
@property NSNumber* milesAway;
@property UIImageView* background;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIButton *cyclePhotosButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property UserParse* curUser;
@property UIImage *userPhoto;
@property UIImage *matchPhoto;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property UserParse *otherUser;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    PFQuery* curQuery = [UserParse query];
    [curQuery whereKey:@"username" equalTo:[UserParse currentUser].username];
    [curQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.curUser = objects.firstObject;
        [self.curUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.userPhoto = [UIImage imageWithData:data];
        }];
        [self currentLocationIdentifier];
    }];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    self.posibleMatchesArray = [NSMutableArray new];
    self.willBeMatches = [NSMutableArray new];
    self.photoArrayIndex = 1;
    self.firstTime = YES;
    self.isRotating = YES;
    self.view.backgroundColor = BLUE_COLOR;
    self.navigationController.navigationBar.barTintColor = BLUE_COLOR;
    self.navigationItem.title = @"Flint";
    //    self.background = [[UIImageView alloc] initWithFrame:self.view.frame];
    //    self.background.image = [UIImage imageNamed:@"background"];
    //    [self.view addSubview:self.background];
    //    [self.view sendSubviewToBack:self.background];
    //    self.gradiantView = [[UIView alloc] initWithFrame:self.view.frame];
    //    CAGradientLayer *gradient = [CAGradientLayer layer];
    //    gradient.frame = self.view.bounds;
    //    gradient.colors = [NSArray arrayWithObjects:(id)BLUEDARK_COLOR.CGColor,(id)RED_COLOR.CGColor,nil];
    //    [self.gradiantView.layer insertSublayer:gradient atIndex:0];
    //    [self.view addSubview:self.gradiantView];
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
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:locations.firstObject completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark* placemark = placemarks.firstObject;
        self.activityLabel.text = [NSString stringWithFormat:@"Locating matches near %@, %@", placemark.locality, placemark.administrativeArea];
        self.activityLabel.textColor = [UIColor whiteColor];
    }];
    [UserParse currentUser].geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    [[UserParse currentUser] saveEventually];
    [self.locationManager stopUpdatingLocation];
    [self getMatches];
}

- (void)getMatches
{
    NSLog(@"current user here %@", self.curUser);
    PFQuery *query = [PossibleMatch query];
    [query whereKey:@"toUser" equalTo:self.curUser];
    [query whereKey:@"match" equalTo:@"YES"];
    [query whereKey:@"toUserApproved" equalTo:@"notDone"];
    PFQuery* userQuery = [UserParse query];
    if (self.curUser.distance.doubleValue == 0.0) {
        self.curUser.distance = [NSNumber numberWithInt:100];
    }
    [userQuery whereKey:@"geoPoint" nearGeoPoint:self.curUser.geoPoint withinKilometers:self.curUser.distance.doubleValue];
    [userQuery whereKey:@"email" matchesKey:@"fromUserEmail" inQuery:query];
    if (self.curUser.sexuality.integerValue == 0) {
        [userQuery whereKey:@"isMale" equalTo:@"true"];
    }
    if (self.curUser.sexuality.integerValue == 1) {
        [userQuery whereKey:@"isMale" equalTo:@"false"];
    }
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        [self.posibleMatchesArray addObjectsFromArray:objects];
        [self.willBeMatches addObjectsFromArray:objects];
        NSLog(@"will be match - %@", objects);
        PFQuery *query = [PossibleMatch query];
        [query whereKey:@"fromUser" equalTo:[UserParse currentUser]];
        PFQuery* userQuery = [UserParse query];
        [userQuery whereKey:@"objectId" notEqualTo:[UserParse currentUser].objectId];
        [userQuery whereKey:@"email" doesNotMatchKey:@"toUserEmail" inQuery:query];
        if (self.curUser.sexuality.integerValue == 0) {
            [userQuery whereKey:@"isMale" equalTo:@"true"];
        }
        NSLog(@"sexuality - %@", self.curUser.sexuality);
        if (self.curUser.sexuality.integerValue == 1) {
            [userQuery whereKey:@"isMale" equalTo:@"false"];
        }
        NSLog(@"distance - %@", self.curUser.distance);
        if (self.curUser.distance.doubleValue == 0.0) {
            self.curUser.distance = [NSNumber numberWithInt:1000];
        }
        [userQuery whereKey:@"geoPoint" nearGeoPoint:self.curUser.geoPoint withinKilometers:self.curUser.distance.doubleValue];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [self.posibleMatchesArray addObjectsFromArray:objects];
            NSLog(@"new matches - %@", objects);
            NSLog(@"new matches - %lu", (unsigned long)objects.count);
            if (self.firstTime) {
                [self firstPlacement];
            }

        }];
    }];
}

- (void) firstPlacement
{
    UserParse* aUser = self.posibleMatchesArray.firstObject;
    NSLog(@"first user %@", aUser);
    self.arrayOfPhotoDataForeground = [NSMutableArray new];
    [self.posibleMatchesArray removeObject:aUser];
    self.currShowingProfile = aUser;
    self.profileView.tag = profileViewTag;
    if (self.posibleMatchesArray.firstObject != nil) {
        [self placeBackgroundProfile];
    }
    PFFile* file = aUser.photo;
    NSString* username = aUser.username;
    NSLog(@"top username %@", aUser.username);
    NSNumber* age = aUser.age;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [self.arrayOfPhotoDataForeground addObject:data];
        self.profileView = [[UIView alloc] initWithFrame:[self createMatchRect]];
        self.profileView.clipsToBounds = YES;
        self.profileView.backgroundColor = WHITE_COLOR;
        //        self.profileView.layer.cornerRadius = cornRadius;
        self.profileImage.tag = currentProfileView;
        [self.view addSubview:self.profileView];
        self.profileImage = [[UIImageView alloc] initWithFrame:[self createPhotoRect]];
        self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImage.tag = currentProfileImage;
        self.profileImage.image = [UIImage imageWithData:data];
        self.profileImage.clipsToBounds = YES;
        //        self.profileImage.layer.cornerRadius = cornRadius;
        [self.profileView addSubview:self.profileImage];
        self.foregroundLabel = [[UILabel alloc] initWithFrame:[self createLabelRect]];
        self.matchPhoto = self.profileImage.image;
        double distance = [aUser.geoPoint distanceInKilometersTo:self.curUser.geoPoint];
        if ([aUser.geoPoint distanceInKilometersTo:self.curUser.geoPoint] < 1) {
            distance = 1;
        }
        self.foregroundLabel.text = [NSString stringWithFormat:@"%@", username];
        self.foregroundLabel.textColor = BLUE_COLOR;
        self.foregroundLabel.clipsToBounds = YES;
        //        self.foregroundLabel.layer.cornerRadius = cornRadius;
        [self.foregroundLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",self.foregroundLabel.font.fontName] size:self.foregroundLabel.font.pointSize];
        UIFont *descFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",self.foregroundLabel.font.fontName] size: 12];
        [self.foregroundLabel setFont:newFont];
        [self.profileView addSubview:self.foregroundLabel];
        [self.profileView bringSubviewToFront:self.foregroundLabel];
        self.profileImageAge = [[UIImageView alloc] initWithFrame:[self createImageViewAge]];
        self.profileImageAge.image = [UIImage imageNamed:@"birthday"];
        [self.profileView addSubview:self.profileImageAge];
        [self.profileView bringSubviewToFront:self.profileImageAge];
        self.foregroundLabelAge = [[UILabel alloc] initWithFrame:[self createLabelAge]];
        self.foregroundLabelAge.text = [NSString stringWithFormat:@"%@", age];
        self.foregroundLabelAge.textColor = BLUE_COLOR;
        [self.foregroundLabelAge setFont:newFont];
        [self.profileView addSubview:self.foregroundLabelAge];
        [self.profileView bringSubviewToFront:self.foregroundLabelAge];
        self.profileImageLocation = [[UIImageView alloc] initWithFrame:[self createImageLocation]];
        self.profileImageLocation.image = [UIImage imageNamed:@"location"];
        self.profileImageLocation.contentMode = UIViewContentModeScaleAspectFit;
        [self.profileView addSubview:self.profileImageLocation];
        self.foregroundLabelLocation = [[UILabel alloc] initWithFrame:[self createLabelLocation]];
        self.foregroundLabelLocation.text = [NSString stringWithFormat:@"%.0fkm", distance];
        self.foregroundLabelLocation.textColor = BLUE_COLOR;
        [self.foregroundLabelLocation setFont:newFont];
        [self.profileView addSubview:self.foregroundLabelLocation];
        [self.profileView bringSubviewToFront:self.foregroundLabelLocation];
        [self.profileView bringSubviewToFront:self.profileImageLocation];
        UILabel* boundaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.profileImage.frame.size.height+self.foregroundLabel.frame.size.height+23, self.profileView.frame.size.width, 1)];
        boundaryLabel.backgroundColor = [UIColor grayColor];
        boundaryLabel.alpha = 0.6;
        [self.profileView addSubview:boundaryLabel];
        [self.profileView bringSubviewToFront:boundaryLabel];
        self.foregroundDescriptionLabel = [[UILabel alloc] initWithFrame:[self createLabelDescription]];
        self.foregroundDescriptionLabel.numberOfLines = 0;
        //self.foregroundDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.foregroundDescriptionLabel.textAlignment = NSTextAlignmentJustified;
        self.foregroundDescriptionLabel.text = aUser.desc;
        self.foregroundDescriptionLabel.textColor = BLUE_COLOR;
        [self.foregroundDescriptionLabel setFont:descFont];
        [self.profileView addSubview:self.foregroundDescriptionLabel];
        [self setPanGestureRecognizer];
        self.firstTime = NO;

        if ([aUser.photo1 isKindOfClass:[PFFile class]]) {
            PFFile* photo1 = aUser.photo1;
            [photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
                self.matchPhoto = [UIImage imageWithData:data];
        }];
        }
        if ([aUser.photo2 isKindOfClass:[PFFile class]]) {
            PFFile* photo2 = aUser.photo2;
            [photo2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
            }];
        }
        if ([aUser.photo3 isKindOfClass:[PFFile class]]) {
            PFFile* photo3 = aUser.photo3;
            [photo3 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
            }];
        }
        if ([aUser.photo4 isKindOfClass:[PFFile class]]) {
            PFFile* photo4 = aUser.photo4;
            [photo4 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
            }];
        }
        [self.activityIndicator stopAnimating];
    }];
}

-(void) placeBackgroundProfile
{
    UserParse* aUser = self.posibleMatchesArray.firstObject;
    [self.posibleMatchesArray removeObject:aUser];
    self.backgroundUserProfile = aUser;
    self.arrayOfPhotoDataBackground = [NSMutableArray new];
    PFFile* file = aUser[@"photo"];
    NSString* username = aUser[@"username"];
    NSLog(@"background user %@", aUser.username);
    NSNumber* age = aUser[@"age"];
    self.backgroundView = [[UIView alloc] initWithFrame:[self createBackgroundMatchRect]];
    self.backgroundView.clipsToBounds = YES;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    //    self.backgroundView.layer.cornerRadius = cornRadius;
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    [self.view sendSubviewToBack:self.background];
    NSLog(@"%@", self.backgroundView);
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [self.arrayOfPhotoDataBackground addObject:data];
        self.backgroundImage = [[UIImageView alloc] initWithFrame:[self createBackgroundPhotoRect]];
        self.backgroundImage.image = [UIImage imageWithData:data];
        self.backgroundImage.clipsToBounds = YES;
        self.backgroundImage.layer.cornerRadius = cornRadius;
        [self.backgroundView addSubview:self.backgroundImage];
        self.backgroundLabel = [[UILabel alloc] initWithFrame:[self createBackgroundLabelRect]];
        double distance = [aUser.geoPoint distanceInKilometersTo:self.curUser.geoPoint];
        if ([aUser.geoPoint distanceInKilometersTo:self.curUser.geoPoint] < 1) {
            distance = 1;
        }
        self.backgroundLabel.text = [NSString stringWithFormat:@"%@", username];
        self.backgroundLabel.textColor = BLUE_COLOR;
        self.backgroundLabel.clipsToBounds = YES;
        //        self.backgroundLabel.layer.cornerRadius = cornRadius;
        [self.backgroundLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",self.backgroundLabel.font.fontName] size:self.backgroundLabel.font.pointSize];
        UIFont *descFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",self.backgroundLabel.font.fontName] size: 12];
        [self.backgroundLabel setFont:newFont];
        [self.backgroundView addSubview:self.backgroundLabel];
        self.backgroundDescriptionLabel = [[UILabel alloc] initWithFrame:[self createBackgroundLabelDescription]];
        [self.profileView bringSubviewToFront:self.foregroundLabel];
        self.backgroundImageAge = [[UIImageView alloc] initWithFrame:[self createBackgroundImageViewAge]];
        self.backgroundImageAge.image = [UIImage imageNamed:@"birthday"];
        [self.backgroundView addSubview:self.backgroundImageAge];
        [self.backgroundView bringSubviewToFront:self.backgroundImageAge];
        self.backgroundLabelAge = [[UILabel alloc] initWithFrame:[self createBackgroundLabelAge]];
        self.backgroundLabelAge.text = [NSString stringWithFormat:@"%@", age];
        self.backgroundLabelAge.textColor = BLUE_COLOR;
        [self.backgroundLabelAge setFont:newFont];
        [self.backgroundView addSubview:self.backgroundLabelAge];
        [self.backgroundView bringSubviewToFront:self.backgroundLabelAge];
        self.backgroundImageLocation = [[UIImageView alloc] initWithFrame:[self createBackgroundImageLocation]];
        self.backgroundImageLocation.image = [UIImage imageNamed:@"location"];
        self.backgroundImageLocation.contentMode = UIViewContentModeScaleAspectFit;
        [self.backgroundView addSubview:self.backgroundImageLocation];
        self.backgroundLabelLocation = [[UILabel alloc] initWithFrame:[self createBackgroundLabelLocation]];
        self.backgroundLabelLocation.text = [NSString stringWithFormat:@"%.0fkm", distance];
        self.backgroundLabelLocation.textColor = BLUE_COLOR;
        [self.backgroundLabelLocation setFont:newFont];
        [self.backgroundView addSubview:self.backgroundLabelLocation];
        [self.backgroundView bringSubviewToFront:self.backgroundLabelLocation];
        [self.backgroundView bringSubviewToFront:self.backgroundLabelLocation];
        UILabel* boundaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.backgroundImage.frame.size.height+self.backgroundLabel.frame.size.height+23, self.backgroundView.frame.size.width, 1)];
        boundaryLabel.backgroundColor = [UIColor grayColor];
        boundaryLabel.alpha = 0.6;
        [self.backgroundView addSubview:boundaryLabel];
        [self.backgroundView bringSubviewToFront:boundaryLabel];
        self.backgroundDescriptionLabel = [[UILabel alloc] initWithFrame:[self createBackgroundLabelDescription]];
        self.backgroundDescriptionLabel.numberOfLines = 0;
        self.backgroundDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.backgroundDescriptionLabel.text = aUser.desc;
        self.backgroundDescriptionLabel.textColor = BLUE_COLOR;
        [self.backgroundDescriptionLabel setFont:descFont];
        [self.backgroundView addSubview:self.backgroundDescriptionLabel];
    }];
    if ([aUser[@"photo1"] isKindOfClass:[PFFile class]]) {
        PFFile* photo1 = aUser[@"photo1"];
        [photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.arrayOfPhotoDataBackground addObject:data];
        }];
    }
    if ([aUser[@"photo2"] isKindOfClass:[PFFile class]]) {
        PFFile* photo2 = aUser[@"photo2"];
        [photo2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.arrayOfPhotoDataBackground addObject:data];
        }];
    }
    if ([aUser[@"photo3"] isKindOfClass:[PFFile class]]) {
        PFFile* photo3 = aUser[@"photo3"];
        [photo3 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.arrayOfPhotoDataBackground addObject:data];
        }];
    }
    if ([aUser[@"photo4"] isKindOfClass:[PFFile class]]) {
        PFFile* photo4 = aUser[@"photo4"];
        [photo4 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.arrayOfPhotoDataBackground addObject:data];
        }];
    }
}

- (CGRect)createLabelDescription
{
    int x = imageMargin;
    int y = self.profileImage.frame.size.height+self.foregroundLabel.frame.size.height+25;
    int width = self.profileView.frame.size.width-imageMargin-imageMargin;
    int height = 50;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createLabelLocation
{
    int x = self.foregroundLabel.frame.size.width+77;
    int y = self.profileImage.frame.size.height+15;
    int width = 59-imageMargin;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createImageLocation
{
    int x = self.foregroundLabel.frame.size.width+55;
    int y = self.profileImage.frame.size.height+15;
    int width = 16;
    int height = 16;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createLabelAge
{
    int x = self.foregroundLabel.frame.size.width+24;
    int y = self.profileImage.frame.size.height+15;
    int width = 30;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}
- (CGRect)createImageViewAge
{
    int x = self.foregroundLabel.frame.size.width;
    int y = self.profileImage.frame.size.height+15;
    int width = 16;
    int height = 16;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createLabelRect
{
    int x = imageMargin;
    int y = self.profileImage.frame.size.height+15;
    int width = (self.profileImage.frame.size.width/2)+30;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createPhotoRect
{
    int x = imageMargin;
    int width = self.profileView.frame.size.width - (x*2);
    int y = imageMargin;
    int height = 280;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createMatchRect
{
    int x = imageMargin;
    int width = 320 - (x*2);
    int y = imageMargin;
    int height = 380;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundLabelDescription
{
    int x = imageMargin;
    int y = self.backgroundImage.frame.size.height+self.backgroundLabel.frame.size.height+25;
    int width = self.backgroundView.frame.size.width-imageMargin-imageMargin;
    int height = 50;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundLabelLocation
{
    int x = self.backgroundLabel.frame.size.width+77;
    int y = self.backgroundImage.frame.size.height+15;
    int width = 59-imageMargin;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundImageLocation
{
    int x = self.backgroundLabel.frame.size.width+55;
    int y = self.backgroundImage.frame.size.height+15;
    int width = 20;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundLabelAge
{
    int x = self.backgroundLabel.frame.size.width+24;
    int y = self.backgroundImage.frame.size.height+15;
    int width = 30;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}
- (CGRect)createBackgroundImageViewAge
{
    int x = self.backgroundLabel.frame.size.width;
    int y = self.backgroundImage.frame.size.height+15;
    int width = 20;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundLabelRect
{
    int x = imageMargin;
    int y = self.backgroundImage.frame.size.height+15;
    int width = (self.backgroundImage.frame.size.width/2)+30;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundPhotoRect
{
    int x = imageMargin;
    int width = self.backgroundView.frame.size.width - (x*2);
    int y = imageMargin;
    int height = 280;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundMatchRect
{
    int x = imageMargin;
    int width = 320 - (x*2);
    int y = imageMargin;
    int height = 380;
    return CGRectMake(x, y, width, height);
}

- (void)rotateImageView:(UIView*) view withDouble:(double) dub
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [view setTransform:CGAffineTransformRotate(view.transform, dub)];
    }completion:^(BOOL finished){
        if (finished) {
            self.isRotating = NO;
        }
    }];
}

#pragma mark - set up and handle pan gesture
- (void) setPanGestureRecognizer
{
    [self.profileView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.profileView addGestureRecognizer:pan];
    [self.profileView addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    self.profileView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self.profileImage.alpha = 0;
                     }
                     completion:^(BOOL b) {
                         [self removeOldProfileImage];
                         [self addNewProfileImage];
                         self.profileView.userInteractionEnabled = YES;
                     }];
}

- (void)addNewProfileImage
{
    NSData* data;
    if (self.photoArrayIndex >= self.arrayOfPhotoDataForeground.count) {
        data = [self.arrayOfPhotoDataForeground objectAtIndex:self.photoArrayIndex-1];
        self.photoArrayIndex = 0;
    }
    if (self.photoArrayIndex < self.arrayOfPhotoDataForeground.count) {
        data = [self.arrayOfPhotoDataForeground objectAtIndex:self.photoArrayIndex];
        self.photoArrayIndex++;
    }
    self.profileImage = [[UIImageView alloc] initWithFrame:[self createPhotoRect]];
    self.profileImage.tag = currentProfileImage;
    self.profileImage.image = [UIImage imageWithData:data];
    self.profileImage.clipsToBounds = YES;
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    //    self.profileImage.layer.cornerRadius = cornRadius;
    [self.profileView addSubview:self.profileImage];
}

- (void)removeOldProfileImage
{
    for (UIView* view in self.profileView.subviews) {
        if (view.tag == currentProfileImage) {
            [view removeFromSuperview];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint vel = [pan velocityInView:self.view];
    CGPoint point = [pan translationInView:self.view];
    BOOL allowRotation = YES;
    if (vel.x > 0)
    {
        //        self.profileView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(point.x, point.y), CGAffineTransformMakeRotation((-M_PI_2)+1.45));
        if (allowRotation) {
            allowRotation = NO;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [self.profileView setTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(point.x, point.y), CGAffineTransformMakeRotation(-0.15))];
            }completion:^(BOOL finished){
                if (finished) {
                }
            }];
            [self removeDislikeView];
            [self addLikeView];
        }
    }
    else
    {
        //        self.profileView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(point.x, point.y), CGAffineTransformMakeRotation((M_PI_2)-1.45));
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.profileView setTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(point.x, point.y), CGAffineTransformMakeRotation(0.15))];
        }completion:^(BOOL finished){
            if (finished) {
            }
        }];
        [self removeLikeView];
        [self addDislikeView];
    }

    point.x += self.profileView.center.x;
    point.y += self.profileView.center.y;

    //    [self placeBackgroundProfile];
    [self checkPointsForLike:point];
    if (pan.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.4 animations:^{
            self.profileView.transform = CGAffineTransformMakeTranslation(0, -5);
        } completion:^(BOOL finished) {
            self.profileView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.profileView.alpha = 1;
        }];
        [self removeLikeAndDislikeView];
    }
}

#pragma mark - pan gesture helper methods
- (void) checkPointsForLike:(CGPoint)point
{
    if (point.x > self.view.frame.size.width - MARGIN) {
        [self likeAProfile];
    }
    if (point.x < MARGIN) {
        [self dislikeAProfile];
    }
}

- (void)dislikeAProfile
{
    NSLog(@"doesn't like");
    self.profileView.gestureRecognizers = [NSArray new];
    [self.profileView removeFromSuperview];
    self.profileView = self.backgroundView;
    self.profileImage = self.backgroundImage;
    self.foregroundLabel = self.backgroundLabel;
    self.foregroundDescriptionLabel = self.backgroundDescriptionLabel;
    self.profileImage.tag = currentProfileImage;
    self.photoArrayIndex = 1;
    self.arrayOfPhotoDataForeground = self.arrayOfPhotoDataBackground;
    if ([self.willBeMatches containsObject:self.currShowingProfile]) {
        PFQuery* query = [PossibleMatch query];
        [query whereKey:@"fromUser" equalTo:self.currShowingProfile];
        [query whereKey:@"toUser" equalTo:[UserParse currentUser]];
        PossibleMatch* posMatch = [query findObjects].firstObject;
        posMatch.toUserApproved = @"NO";
        [posMatch saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                }
            }
        }];
    } else {
        PossibleMatch* possibleMatch = [PossibleMatch object];
        possibleMatch.fromUser = [UserParse currentUser];
        possibleMatch.fromUserEmail = [UserParse currentUser].email;
        possibleMatch.toUserEmail = self.currShowingProfile.email;
        NSLog(@"%@", self.currShowingProfile.email);
        possibleMatch.toUser = self.currShowingProfile;
        possibleMatch.match = @"NO";
        [possibleMatch saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                }
            }
        }];
    }
}

- (void)likeAProfile
{
    NSLog(@"like");
    self.profileView.gestureRecognizers = [NSArray new];
    [self.profileView removeFromSuperview];
    self.profileView = self.backgroundView;
    self.matchPhoto = self.profileImage.image;
    self.profileImage = self.backgroundImage;
    self.foregroundLabel = self.backgroundLabel;
    self.foregroundDescriptionLabel = self.backgroundDescriptionLabel;
    self.arrayOfPhotoDataForeground = self.arrayOfPhotoDataBackground;
    self.profileImage.tag = currentProfileImage;
    self.photoArrayIndex = 1;
    if ([self.willBeMatches containsObject:self.currShowingProfile]) {
        [self performSegueWithIdentifier:@"match" sender:nil];
        MessageParse* message = [MessageParse object];
        message.fromUserParse = self.currShowingProfile;
        message.fromUserParseEmail = self.currShowingProfile.email;
        message.toUserParse = [UserParse currentUser];
        message.toUserParseEmail = [UserParse currentUser].email;
        message.text = @"";
        PFQuery* query = [PossibleMatch query];
        [query whereKey:@"fromUser" equalTo:self.currShowingProfile];
        [query whereKey:@"toUser" equalTo:[UserParse currentUser]];
        PossibleMatch* posMatch = [query findObjects].firstObject;
        posMatch.toUserApproved = @"YES";
        [posMatch saveEventually];
        NSLog(@"match made in heaven");
        NSLog(@"pos match %@", posMatch);
        [message saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                }
            }
        }];
    } else {
        PossibleMatch* possibleMatch = [PossibleMatch object];
        possibleMatch.fromUser = [UserParse currentUser];
        possibleMatch.toUser = self.currShowingProfile;
        possibleMatch.toUserEmail = self.currShowingProfile.email;
        possibleMatch.fromUserEmail = [UserParse currentUser].email;
        possibleMatch.match = @"YES";
        possibleMatch.toUserApproved = @"notDone";
        [possibleMatch saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                NSLog(@"here");
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                }
            }
        }];
    }
}

- (void) addLikeView
{
    UIImageView* likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    likeImageView.tag = likeViewTag;
    likeImageView.image = [UIImage imageNamed:@"like.png"];
    likeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.profileView addSubview:likeImageView];
}

- (void) addDislikeView
{
    UIImageView* dislikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.profileImage.frame.size.width - buttonWidth + (imageMargin*2), 0, buttonWidth, buttonHeight)];
    dislikeImageView.tag = dislikeViewTag;
    dislikeImageView.image = [UIImage imageNamed:@"dislike.png"];
    dislikeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.profileView addSubview:dislikeImageView];
    [self.profileView bringSubviewToFront:dislikeImageView];
}

- (void) removeLikeAndDislikeView
{
    for (UIView* view in self.profileView.subviews) {
        if (view.tag == dislikeViewTag || view.tag == likeViewTag) {
            [view removeFromSuperview];
        }
    }
}

- (void) removeLikeView
{
    for (UIView* view in self.profileView.subviews) {
        if (view.tag == likeViewTag) {
            [view removeFromSuperview];
        }
    }
}

- (void) removeDislikeView
{
    for (UIView* view in self.profileView.subviews) {
        if (view.tag == dislikeViewTag) {
            [view removeFromSuperview];
        }
    }
}

-(void) removeProfileViewForGood
{
    for (UIView* view in self.view.subviews) {
        if (view.tag == currentProfileView) {
            [view removeFromSuperview];
        }
    }
}

- (IBAction)cycleImagesButtonHit:(UIButton *)sender
{
    self.profileView.userInteractionEnabled = NO;
    sender.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self.profileImage.alpha = 0;
                     }
                     completion:^(BOOL b) {
                         [self removeOldProfileImage];
                         [self addNewProfileImage];
                         self.profileView.userInteractionEnabled = YES;
                         sender.userInteractionEnabled = YES;
                     }];
}

- (IBAction)dislikeButtonHit:(UIButton *)sender
{
    if(self.profileView != nil) {
        sender.enabled = NO;
        self.likeButton.enabled = NO;
        self.cyclePhotosButton.enabled = NO;
        [UIView animateWithDuration:0.4 animations:^{
            self.profileView.transform = CGAffineTransformMakeTranslation(-300, 40);
            [self addDislikeView];
        } completion:^(BOOL finished) {
            [self dislikeAProfile];
            sender.enabled = YES;
            self.likeButton.enabled = YES;
            self.cyclePhotosButton.enabled = YES;
        }];
    }
}

- (IBAction)likeButtonHit:(UIButton *)sender
{
    if(self.profileView != nil) {
        sender.enabled = NO;
        self.dislikeButton.enabled = NO;
        self.cyclePhotosButton.enabled = NO;
        [UIView animateWithDuration:0.4 animations:^{
            self.profileView.transform = CGAffineTransformMakeTranslation(300, 40);
            [self addLikeView];
        } completion:^(BOOL finished) {
            [self likeAProfile];
            sender.enabled = YES;
            self.dislikeButton.enabled = YES;
            self.cyclePhotosButton.enabled = YES;
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"match"]) {


        MatchViewController *vc = segue.destinationViewController;
        vc.modalTransitionStyle = UIModalTransitionStylePartialCurl;

        vc.userImage = self.userPhoto;
        vc.matchImage = self.matchPhoto;
        vc.matchUser = self.otherUser;
        vc.user = self.curUser;
    }
}


@end