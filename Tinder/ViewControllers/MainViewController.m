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

#define profileViewTag 3
#define likeViewTag 2
#define dislikeViewTag 1

@interface MainViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UIView *profileView;
@property (strong, nonatomic) UIView* backgroundView;
@property UserParse* currShowingProfile;
@property UserParse* backgroundUserProfile;
@property NSMutableArray *posibleMatchesArray;
@property NSMutableArray* willBeMatches;
@property BOOL firstTime;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    self.posibleMatchesArray = [NSMutableArray new];
    self.firstTime = YES;
    [self getMatches];
    self.view.backgroundColor = BLACK_COLOR;

}


- (void)getMatches
{
    PFQuery *query = [PFQuery queryWithClassName:@"PossibleMatch"];
    [query whereKey:@"toUser" equalTo:[UserParse currentUser]];
    [query whereKey:@"match" equalTo:@"YES"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.posibleMatchesArray addObjectsFromArray:objects];
        [self.willBeMatches addObjectsFromArray:objects];
        NSLog(@"will be match - %@", objects);
        //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        if (objects.count == 0) {
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
                    int nameCushion = (int)[username length];
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        self.profileView = [[UIView alloc] initWithFrame:[self createMatchRect]];
                        self.profileView.backgroundColor = [UIColor grayColor];
                        [self.view addSubview:self.profileView];
                        UIImageView* profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileView.frame.size.width, self.profileView.frame.size.height-labelHeight)];
                        profileImage.image = [UIImage imageWithData:data];
                        [self.profileView addSubview:profileImage];
                        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.profileView.frame.size.width/2)-labelCushion-nameCushion, self.profileView.frame.size.height-labelHeight, profileImage.frame.size.width, labelHeight)];
                        nameLabel.text = [NSString stringWithFormat:@"%@, %@", username, age];
                        [nameLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
                        [self.profileView addSubview:nameLabel];
                        [self setPanGestureRecognizer];
                        self.firstTime = NO;

                    }];
                }
            }];
        }
    }];
}

-(void) placeBackgroundProfile
{
    if (self.posibleMatchesArray.count == 1) {
        [self getMatches];
    }

    UserParse* aUser = self.posibleMatchesArray.firstObject;
    [self.posibleMatchesArray removeObject:aUser];
    self.backgroundUserProfile = aUser;

    PFFile* file = aUser[@"photo"];
    NSString* username = aUser[@"username"];
    NSLog(@"background user %@", aUser.username);
    NSNumber* age = aUser[@"age"];
    self.backgroundView = [[UIView alloc] initWithFrame:[self createMatchRect]];
    self.backgroundView.backgroundColor = [UIColor grayColor];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImageView* profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height-labelHeight)];
        profileImage.image = [UIImage imageWithData:data];
        [self.view addSubview:self.backgroundView];
        [self.backgroundView addSubview:profileImage];
        [self.view sendSubviewToBack:self.backgroundView];
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.backgroundView.frame.size.height-labelHeight, profileImage.frame.size.width, labelHeight)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.backgroundColor = [UIColor grayColor];
        nameLabel.text = [NSString stringWithFormat:@"Hey %@, %@", username, age];
        [nameLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
        [self.backgroundView addSubview:nameLabel];
    }];
}

- (CGRect)createMatchRect
{
    return CGRectMake(50, 150, 220, 220);
}

#pragma mark - set up and handle pan gesture
- (void) setPanGestureRecognizer
{
    [self.profileView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.profileView addGestureRecognizer:pan];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint vel = [pan velocityInView:self.view];
    CGPoint point = [pan translationInView:self.view];
    if (vel.x > 0)
    {
        self.profileView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(point.x, point.y), CGAffineTransformMakeRotation((-M_PI_2)+1.45));
        [self removeDislikeView];
        [self addLikeView];
    }
    else
    {
        self.profileView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(point.x, point.y), CGAffineTransformMakeRotation((M_PI_2)-1.45));
        [self removeLikeView];
        [self addDislikeView];
    }
    self.profileView.alpha = 0.7;
    point.x += self.profileView.center.x;
    point.y += self.profileView.center.y;
    //    [self placeBackgroundProfile];
    [self checkPointsForLike:point];
    if (pan.state == UIGestureRecognizerStateEnded) {
        self.profileView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.profileView.alpha = 1;
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
        if ([self.willBeMatches containsObject:self.currShowingProfile]) {
            PFObject* match = [PFObject objectWithClassName:@"Match"];
            match[@"fromUser"] = self.currShowingProfile;
            match[@"toUser"] = [UserParse currentUser];
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
            possibleMatch[@"match"] = @"YES";
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
