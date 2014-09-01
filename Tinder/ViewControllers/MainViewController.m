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

@interface MainViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UIView *profileView;
@property (strong, nonatomic) UIView* backgroundView;
@property UserParse* currShowingProfile;
@property UserParse* backgroundUserProfile;
@property NSMutableArray *posibleMatchesArray;
@property NSMutableArray* willBeMatches;
@property UIImageView* profileImage;
@property UIImageView* backgroundImage;
@property BOOL firstTime;
@property BOOL isRotating;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    self.posibleMatchesArray = [NSMutableArray new];
    self.willBeMatches = [NSMutableArray new];
    self.firstTime = YES;
    self.isRotating = YES;
    [self getMatches];
    self.view.backgroundColor = BLUE_COLOR;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)BLUEDARK_COLOR.CGColor,(id)RED_COLOR.CGColor, (id)BLUEDARK_COLOR.CGColor,nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

}

- (void)getMatches
{
    NSLog(@"current showing profile %@", self.currShowingProfile);
    PFQuery *query = [PFQuery queryWithClassName:@"PossibleMatch"];
    [query whereKey:@"toUser" equalTo:[UserParse currentUser]];
    [query whereKey:@"match" equalTo:@"YES"];
    [query whereKey:@"toUserApproved" equalTo:@"notDone"];
    PFQuery* userQuery = [UserParse query];
    [userQuery whereKey:@"email" matchesKey:@"fromUserId" inQuery:query];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.posibleMatchesArray addObjectsFromArray:objects];
        [self.willBeMatches addObjectsFromArray:objects];
        NSLog(@"will be match - %@", objects);
        //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

        PFQuery *query = [PFQuery queryWithClassName:@"PossibleMatch"]; //matches
        [query whereKey:@"fromUser" equalTo:[UserParse currentUser]]; //people you've seen
        PFQuery* userQuery = [UserParse query];
        [userQuery whereKey:@"objectId" notEqualTo:[UserParse currentUser].objectId];
        [userQuery whereKey:@"email" doesNotMatchKey:@"toUserId" inQuery:query];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [self.posibleMatchesArray addObjectsFromArray:objects];
            NSLog(@"new matches - %@", objects);
            if (self.firstTime) {
                UserParse* aUser = self.posibleMatchesArray.firstObject;
                [self.posibleMatchesArray removeObject:aUser];
                self.currShowingProfile = aUser;
                self.profileView.tag = profileViewTag;
                [self placeBackgroundProfile];
                PFFile* file = aUser[@"photo"];
                NSString* username = aUser[@"username"];
                NSLog(@"top username %@", aUser.username);
                NSNumber* age = aUser[@"age"];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
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
                    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.backgroundView.frame.size.height-labelHeight, self.profileImage.frame.size.width, labelHeight)];
                    nameLabel.textAlignment = NSTextAlignmentCenter;
                    nameLabel.text = [NSString stringWithFormat:@"%@, %@", username, age];
                    nameLabel.textColor = [UIColor whiteColor];
                    nameLabel.backgroundColor = RED_COLOR;
                    nameLabel.clipsToBounds = YES;
                    nameLabel.layer.cornerRadius = cornRadius;
                    [nameLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
                    UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",nameLabel.font.fontName] size:nameLabel.font.pointSize];
                    [nameLabel setFont:newFont];
                    [self.profileView addSubview:nameLabel];
                    [self setPanGestureRecognizer];
                    self.firstTime = NO;

                }];
            }
        }];

    }];
}

-(void) placeBackgroundProfile
{
//    if (self.posibleMatchesArray.count == 1) {
//        [self getMatches];
//    }

    UserParse* aUser = self.posibleMatchesArray.firstObject;
    [self.posibleMatchesArray removeObject:aUser];
    self.backgroundUserProfile = aUser;

    PFFile* file = aUser[@"photo"];
    NSString* username = aUser[@"username"];
    NSLog(@"background user %@", aUser.username);
    NSNumber* age = aUser[@"age"];
    self.backgroundView = [[UIView alloc] initWithFrame:[self createMatchRect]];
    self.backgroundView.backgroundColor = RED_COLOR;
    self.backgroundView.clipsToBounds = YES;
    self.backgroundView.layer.cornerRadius = cornRadius;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height-labelHeight)];
        self.backgroundImage.image = [UIImage imageWithData:data];
        self.backgroundImage.clipsToBounds = YES;
        self.backgroundImage.layer.cornerRadius = cornRadius;
        [self.view addSubview:self.backgroundView];
        [self.backgroundView addSubview:self.backgroundImage];
        [self.view sendSubviewToBack:self.backgroundView];
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.backgroundView.frame.size.height-labelHeight, self.backgroundImage.frame.size.width, labelHeight)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = [NSString stringWithFormat:@"%@, %@", username, age];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.backgroundColor = RED_COLOR;
        nameLabel.clipsToBounds = YES;
        nameLabel.layer.cornerRadius = cornRadius;
        [nameLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",nameLabel.font.fontName] size:nameLabel.font.pointSize];
        [nameLabel setFont:newFont];
        [self.backgroundView addSubview:nameLabel];
    }];
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

    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self.profileImage.transform = CGAffineTransformMakeScale(-1, 1);
                     }
                     completion:^(BOOL b) {
                         self.profileView.layer.shadowColor = [UIColor clearColor].CGColor;
                         self.profileView.layer.shadowOpacity = 0.0;
                         self.profileView.layer.shadowRadius = 0.0;
                         self.profileView.layer.shadowOffset = (CGSize){0.0, 0.0};
                         [self removeOldProfileImage];
                     }];
}

- (void)addNewProfileImage
{
    PFFile* file = self.currShowingProfile[@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [self.view addSubview:self.profileView];
        self.profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileView.frame.size.width, self.profileView.frame.size.height-labelHeight)];
        self.profileImage.tag = currentProfileImage;
        self.profileImage.image = [UIImage imageWithData:data];
        self.profileImage.clipsToBounds = YES;
        self.profileImage.layer.cornerRadius = cornRadius;
        [self.profileView addSubview:self.profileImage];
    }];

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
        [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
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
        [UIView animateWithDuration:0.3 animations:^{
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
        self.profileImage.tag = currentProfileImage;
        if ([self.willBeMatches containsObject:self.currShowingProfile]) {
            PFObject* match = [PFObject objectWithClassName:@"MessageParse"];
            match[@"fromUserParse"] = self.currShowingProfile;
            match[@"fromUserId"] = self.currShowingProfile.email;
            match[@"toUserParse"] = [UserParse currentUser];
            match[@"toUserId"] = [UserParse currentUser].email;
            match[@"text"] = @"";
            PFQuery* query = [PFQuery queryWithClassName:@"PossibleMatch"];
            [query whereKey:@"fromUser" equalTo:self.currShowingProfile];
            [query whereKey:@"toUser" equalTo:[UserParse currentUser]];
            PFObject* posMatch = [query findObjects].firstObject;
            posMatch[@"toUserApproved"] = @"YES";
            [posMatch saveEventually];
            NSLog(@"pos match %@", posMatch);
            [match saveEventually:^(BOOL succeeded, NSError *error) {
                NSLog(@"match made in heaven");
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                [self placeBackgroundProfile];
            }];
        } else {
            PFObject* possibleMatch = [PFObject objectWithClassName:@"PossibleMatch"];
            possibleMatch[@"fromUser"] = [UserParse currentUser];
            possibleMatch[@"toUser"] = self.currShowingProfile;
            possibleMatch[@"toUserId"] = self.currShowingProfile.email;
            possibleMatch[@"fromUserId"] = [UserParse currentUser].email;
            possibleMatch[@"match"] = @"YES";
            possibleMatch[@"toUserApproved"] = @"notDone";
            [possibleMatch saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"here");
                    self.currShowingProfile = self.backgroundUserProfile;
                    [self setPanGestureRecognizer];
                    [self placeBackgroundProfile];
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
        self.profileImage.tag = currentProfileImage;
        if ([self.willBeMatches containsObject:self.currShowingProfile]) {
            PFQuery* query = [PFQuery queryWithClassName:@"PossibleMatch"];
            [query whereKey:@"fromUser" equalTo:self.currShowingProfile];
            [query whereKey:@"toUser" equalTo:[UserParse currentUser]];
            PFObject* posMatch = [query findObjects].firstObject;
            posMatch[@"toUserApproved"] = @"NO";
            [posMatch saveEventually];
        } else {
            PFObject* possibleMatch = [PFObject objectWithClassName:@"PossibleMatch"];
            possibleMatch[@"fromUser"] = [UserParse currentUser];
            possibleMatch[@"fromUserId"] = [UserParse currentUser].email;
            possibleMatch[@"toUserId"] = self.currShowingProfile.email;
            NSLog(@"%@", self.currShowingProfile.email);
            possibleMatch[@"toUser"] = self.currShowingProfile;
            possibleMatch[@"match"] = @"NO";
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
    UIImageView* dislikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.profileView.frame.size.width - (buttonWidth*2)+18, 0, buttonWidth, buttonHeight)];
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
