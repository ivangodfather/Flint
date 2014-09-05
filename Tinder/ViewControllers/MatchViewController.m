//
//  MatchViewController.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 04/09/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "MatchViewController.h"
#define MARGIN 50

@interface MatchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *matchingButton;
@property (weak, nonatomic) IBOutlet UIImageView *matchImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchingLabel;

@end

@implementation MatchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messageButton.layer.cornerRadius = 3;
    self.matchingButton.layer.cornerRadius = 3;
    self.messageButton.layer.borderWidth = 1.0;
    self.matchingButton.layer.borderWidth = 1.0;
    self.messageButton.layer.borderColor = WHITE_COLOR.CGColor;
    self.matchingButton.layer.borderColor = WHITE_COLOR.CGColor;

}

- (IBAction)messageButton:(id)sender
{

}

- (IBAction)keepMatching:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.view.frame];
    iv.image = [UIImage imageNamed:@"match"];
    [self.view addSubview:iv];
    UIImageView *leftIV = [[UIImageView alloc] initWithImage:self.userImage];
    leftIV.frame = CGRectMake(-100, self.view.frame.size.height/3, 100, 100);
    leftIV.contentMode = UIViewContentModeScaleAspectFill;
    leftIV.layer.borderColor = WHITE_COLOR.CGColor;
    leftIV.layer.borderWidth = 1.0;
    leftIV.layer.cornerRadius = leftIV.frame.size.width/2;
    leftIV.clipsToBounds = YES;
    [self.view addSubview:leftIV];
    [self.view sendSubviewToBack:iv];
    [self.view bringSubviewToFront:self.matchingButton];
    [self.view bringSubviewToFront:self.messageButton];

    UIImageView *rightIV = [[UIImageView alloc] initWithImage:self.matchImage];
    rightIV.frame = CGRectMake(self.view.frame.size.width+100, self.view.frame.size.height/3, 100, 100);
    rightIV.contentMode = UIViewContentModeScaleAspectFill;
    rightIV.layer.cornerRadius = leftIV.frame.size.width/2;
    rightIV.layer.borderColor = WHITE_COLOR.CGColor;
    rightIV.layer.borderWidth = 1.0;
    rightIV.clipsToBounds = YES;
    [self.view addSubview:rightIV];


    [UIView animateWithDuration:4 delay:0.2 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        leftIV.frame = CGRectMake(MARGIN/1.5, self.view.frame.size.height/3, leftIV.frame.size.width, leftIV.frame.size.height);
        rightIV.frame = CGRectMake(self.view.frame.size.width-MARGIN/1.5-100, self.view.frame.size.height/3, leftIV.frame.size.width, leftIV.frame.size.height);
    } completion:^(BOOL finished) {

    }];

    [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.messageButton.frame = CGRectMake(self.messageButton.frame.origin.x, 330, self.messageButton.frame.size.width, self.messageButton.frame.size.height);
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, 345, self.messageLabel.frame.size.width, self.messageLabel.frame.size.height);
    } completion:^(BOOL finished) {

    }];
    [UIView animateWithDuration:1.5 delay:0.7 usingSpringWithDamping:0.6 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.matchingButton.frame = CGRectMake(self.messageButton.frame.origin.x, 400, self.messageButton.frame.size.width, self.messageButton.frame.size.height);
        self.matchingLabel.frame = CGRectMake(self.matchingLabel.frame.origin.x, 415, self.matchingLabel.frame.size.width, self.matchingLabel.frame.size.height);
    } completion:^(BOOL finished) {

    }];
    [UIView animateWithDuration:7 animations:^{
        self.matchImageView.alpha = 1.0;
    } completion:^(BOOL finished) {

    }];
}


@end
