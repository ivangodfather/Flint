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

#define labelHeight 30
#define labelCushion 20
#define MARGIN 50

#define buttonWidth 40
#define buttonHeight 50

#define currentProfileImage 4
#define profileViewTag 3
#define likeViewTag 2
#define dislikeViewTag 1

#define cornRadius 3

@interface MainViewController () <UIGestureRecognizerDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UIView *profileView;
@property (strong, nonatomic) UIView* backgroundView;
@property UserParse* currShowingProfile;
@property UserParse* backgroundUserProfile;
@property NSMutableArray *posibleMatchesArray;
@property NSMutableArray* willBeMatches;
@property (strong, nonatomic) UIImageView* profileImage;
@property (strong, nonatomic) UIImageView* backgroundImage;
@property NSMutableArray* arrayOfPhotoDataForeground;
@property NSMutableArray* arrayOfPhotoDataBackground;
@property (strong, nonatomic) UILabel* foregroundLabel;
@property (strong, nonatomic) UILabel* backgroundLabel;
@property BOOL firstTime;
@property BOOL isRotating;
@property int photoArrayIndex;
@property CLLocationManager* locationManager;
@property CLLocation* currentLocation;
@property NSNumber* milesAway;
@property UIView* gradiantView;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    self.posibleMatchesArray = [NSMutableArray new];
    self.willBeMatches = [NSMutableArray new];
    [self currentLocationIdentifier];
    self.photoArrayIndex = 1;
    self.firstTime = YES;
    self.isRotating = YES;
    NSLog(@"current user %@", [UserParse currentUser]);
    self.view.backgroundColor = BLUE_COLOR;
    self.gradiantView = [[UIView alloc] initWithFrame:self.view.frame];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)BLUEDARK_COLOR.CGColor,(id)RED_COLOR.CGColor,nil];
    [self.gradiantView.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:self.gradiantView];
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
    [UserParse currentUser].geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    [[UserParse currentUser] saveEventually];
    [self.locationManager stopUpdatingLocation];
    [self getMatches];

}

//-(void) getDistanceFrom:(PFGeoPoint*)userLocation withString:(PFGeoPoint*)toUserGeopoint
//{
//    NSLog(@"to user geopoint - %@", toUserGeopoint);
//    CLLocation* toUserLocation = [[CLLocation alloc] initWithLatitude:toUserGeopoint.latitude longitude:toUserGeopoint.longitude];
//    int meters = (int)[userLocation distanceFromLocation:toUserLocation];
//    int miles = meters * 0.000621371;
//    self.milesAway = [NSNumber numberWithInt:miles];
//    if (self.milesAway.intValue < 10000) {
//        [self.posibleMatchesArray removeObject:self.posibleMatchesArray.firstObject];
//        UserParse* aUser = self.posibleMatchesArray.firstObject;
//        [self getDistanceFrom:userLocation withString:aUser.geoPoint];
//    } else {
//        [self firstPlacement];
//        NSLog(@"miles - %d", miles);
//    }
//}

//-(void) getDistanceFromSecondTime:(CLLocation*)userLocation withString:(PFGeoPoint*)toUserGeopoint
//{
//
//    CLLocation* toUserLocation = [[CLLocation alloc] initWithLatitude:toUserGeopoint.latitude longitude:toUserGeopoint.longitude];
//    int meters = (int)[userLocation distanceFromLocation:toUserLocation];
//    int miles = meters * 0.000621371;
//    self.milesAway = [NSNumber numberWithInt:miles];
//    if (self.milesAway.intValue < 10000) {
//        [self.posibleMatchesArray removeObject:self.posibleMatchesArray.firstObject];
//        UserParse* aUser = self.posibleMatchesArray.firstObject;
//        [self getDistanceFromSecondTime:userLocation withString:aUser.geoPoint];
//    } else {
//        [self placeBackgroundProfile];
//        NSLog(@"miles - %d", miles);
//    }
//}

- (void)getMatches
{
    NSLog(@"current showing profile %@", self.currShowingProfile);
    PFQuery *query = [PossibleMatch query];
    [query whereKey:@"toUser" equalTo:[UserParse currentUser]];
    [query whereKey:@"match" equalTo:@"YES"];
    [query whereKey:@"toUserApproved" equalTo:@"notDone"];
    PFQuery* userQuery = [UserParse query];
    if ([UserParse currentUser].distance.doubleValue == 0.0) {
        [UserParse currentUser].distance = [NSNumber numberWithInt:100];
    }
    [userQuery whereKey:@"geoPoint" nearGeoPoint:[UserParse currentUser].geoPoint withinKilometers:[UserParse currentUser].distance.doubleValue];
    [userQuery whereKey:@"email" matchesKey:@"fromUserId" inQuery:query];
    if ([UserParse currentUser].sexuality.integerValue == 0) {
        NSLog(@"Im here 0 ");
        [userQuery whereKey:@"isMale" equalTo:@"true"];
    }
    if ([UserParse currentUser].sexuality.integerValue == 1) {
        NSLog(@"Im here 1");
        [userQuery whereKey:@"isMale" equalTo:@"false"];
    }
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.posibleMatchesArray addObjectsFromArray:objects];
        [self.willBeMatches addObjectsFromArray:objects];
        NSLog(@"will be match - %@", objects);
        //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        PFQuery *query = [PossibleMatch query]; //matches
        [query whereKey:@"fromUser" equalTo:[UserParse currentUser]]; //people you've seen
        PFQuery* userQuery = [UserParse query];
        [userQuery whereKey:@"objectId" notEqualTo:[UserParse currentUser].objectId];
        [userQuery whereKey:@"email" doesNotMatchKey:@"toUserEmail" inQuery:query];
        if ([UserParse currentUser].sexuality.integerValue == 0) {
            [userQuery whereKey:@"isMale" equalTo:@"true"];
        }
        if ([UserParse currentUser].sexuality.integerValue == 1) {
            [userQuery whereKey:@"isMale" equalTo:@"false"];
        }
        if ([UserParse currentUser].distance.doubleValue == 0.0) {
            [UserParse currentUser].distance = [NSNumber numberWithInt:1000];
        }
        [userQuery whereKey:@"geoPoint" nearGeoPoint:[UserParse currentUser].geoPoint withinKilometers:[UserParse currentUser].distance.doubleValue];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [self.posibleMatchesArray addObjectsFromArray:objects];
            NSLog(@"new matches - %@", objects);
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
    [self placeBackgroundProfile];
    PFFile* file = aUser.photo;
    NSString* username = aUser.username;
    NSLog(@"top username %@", aUser.username);
    NSNumber* age = aUser.age;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [self.arrayOfPhotoDataForeground addObject:data];
        self.profileView = [[UIView alloc] initWithFrame:[self createMatchRect]];
        self.profileView.backgroundColor = RED_COLOR;
        self.profileView.clipsToBounds = YES;
        self.profileView.layer.cornerRadius = cornRadius;
        [self.view addSubview:self.profileView];
        self.profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileView.frame.size.width, self.profileView.frame.size.height-labelHeight)];
        self.profileImage.tag = currentProfileImage;
        self.profileImage.image = [UIImage imageWithData:data];
        self.profileImage.clipsToBounds = YES;
        self.profileImage.layer.cornerRadius = cornRadius;
        [self.profileView addSubview:self.profileImage];
        self.foregroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.profileView.frame.size.height-labelHeight, self.profileImage.frame.size.width, labelHeight)];
        self.foregroundLabel.textAlignment = NSTextAlignmentCenter;
        self.foregroundLabel.text = [NSString stringWithFormat:@"%@, %@", username, age];
        self.foregroundLabel.textColor = [UIColor whiteColor];
        self.foregroundLabel.backgroundColor = RED_COLOR;
        self.foregroundLabel.clipsToBounds = YES;
        self.foregroundLabel.layer.cornerRadius = cornRadius;
        [self.foregroundLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",self.foregroundLabel.font.fontName] size:self.foregroundLabel.font.pointSize];
        [self.foregroundLabel setFont:newFont];
        [self.profileView addSubview:self.foregroundLabel];
        [self.profileView bringSubviewToFront:self.foregroundLabel];
        NSLog(@"%@", self.foregroundLabel);
        [self setPanGestureRecognizer];
        self.firstTime = NO;
        if ([aUser.photo1 isKindOfClass:[PFFile class]]) {
            PFFile* photo1 = aUser.photo1;
            [photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
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
    self.backgroundView = [[UIView alloc] initWithFrame:[self createMatchRect]];
    self.backgroundView.backgroundColor = RED_COLOR;
    self.backgroundView.clipsToBounds = YES;
    self.backgroundView.layer.cornerRadius = cornRadius;
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    [self.view sendSubviewToBack:self.gradiantView];
    NSLog(@"%@", self.backgroundView);
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [self.arrayOfPhotoDataBackground addObject:data];
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height-labelHeight)];
        self.backgroundImage.image = [UIImage imageWithData:data];
        self.backgroundImage.clipsToBounds = YES;
        self.backgroundImage.layer.cornerRadius = cornRadius;
        [self.backgroundView addSubview:self.backgroundImage];
        self.backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.backgroundView.frame.size.height-labelHeight, self.backgroundImage.frame.size.width, labelHeight)];
        self.backgroundLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundLabel.text = [NSString stringWithFormat:@"%@, %@", username, age];
        self.backgroundLabel.textColor = [UIColor whiteColor];
        self.backgroundLabel.backgroundColor = RED_COLOR;
        self.backgroundLabel.clipsToBounds = YES;
        self.backgroundLabel.layer.cornerRadius = cornRadius;
        [self.backgroundLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",self.backgroundLabel.font.fontName] size:self.backgroundLabel.font.pointSize];
        [self.backgroundLabel setFont:newFont];
        [self.backgroundView addSubview:self.backgroundLabel];
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

- (CGRect)createMatchRect
{
    int x = 10;
    int width = 320 - (x*2);
    int y = 10;
    int height = 480;
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
    self.profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.profileImage.layer.shadowOpacity = 0.75;
    self.profileImage.layer.shadowRadius = 15.0;
    self.profileImage.layer.shadowOffset = (CGSize){0.0,20.0};


    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self.profileImage.transform = CGAffineTransformMakeScale(-1, 1);
                         self.foregroundLabel.transform = CGAffineTransformMakeScale(-1, -1);
                     }
                     completion:^(BOOL b) {
                         self.foregroundLabel.transform = CGAffineTransformMakeScale(1, 1);
                         self.profileView.layer.shadowColor = [UIColor clearColor].CGColor;
                         self.profileView.layer.shadowOpacity = 0.0;
                         self.profileView.layer.shadowRadius = 0.0;
                         self.profileView.layer.shadowOffset = (CGSize){0.0, 0.0};
                         [self removeOldProfileImage];
                         [self addNewProfileImage];
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
    self.profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileView.frame.size.width, self.profileView.frame.size.height-labelHeight)];
    self.profileImage.tag = currentProfileImage;
    self.profileImage.image = [UIImage imageWithData:data];
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.cornerRadius = cornRadius;
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

        NSLog(@"like");
        self.profileView.gestureRecognizers = [NSArray new];
        [self.profileView removeFromSuperview];
        self.profileView = self.backgroundView;
        self.profileImage = self.backgroundImage;
        self.foregroundLabel = self.backgroundLabel;
        self.arrayOfPhotoDataForeground = self.arrayOfPhotoDataBackground;
        self.profileImage.tag = currentProfileImage;
        self.photoArrayIndex = 1;
        if ([self.willBeMatches containsObject:self.currShowingProfile]) {
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
                    [self placeBackgroundProfile];
                    [self setPanGestureRecognizer];
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
                    [self placeBackgroundProfile];
                    [self setPanGestureRecognizer];
                    NSLog(@"here");
                }
            }];
        }
    }
    if (point.x < MARGIN) {
        NSLog(@"doesn't like");
        self.profileView.gestureRecognizers = [NSArray new];
        [self.profileView removeFromSuperview];
        self.profileView = self.backgroundView;
        self.profileImage = self.backgroundImage;
        self.foregroundLabel = self.backgroundLabel;
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
                    [self placeBackgroundProfile];
                    [self setPanGestureRecognizer];
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
                    [self placeBackgroundProfile];
                    NSLog(@"save this no match");
                }
            }];
        }
    }
}

- (void) addLikeView
{
    UIImageView* likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    likeImageView.tag = likeViewTag;
    likeImageView.image = [UIImage imageNamed:@"like.png"];
    likeImageView.alpha = 0.01;
    [self.profileView addSubview:likeImageView];
}

- (void) addDislikeView
{
    UIImageView* dislikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.profileImage.frame.size.width - buttonWidth, 0, buttonWidth, buttonHeight)];
    dislikeImageView.tag = dislikeViewTag;
    dislikeImageView.image = [UIImage imageNamed:@"dislike.png"];
    dislikeImageView.alpha = 0.01;
    [self.profileView addSubview:dislikeImageView];
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

@end