//
//  ProfileViewController.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 26/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "ProfileViewController.h"
#import "SWRevealViewController.h"
#import "UserParse.h"
#import "V8HorizontalPickerView.h"

#define DEFAULT_DESCRIPTION  @"Fill with information about you"
#define MAXLENGTH 125
#define MAX_PHOTOS 10

@interface ProfileViewController () <V8HorizontalPickerViewDataSource, V8HorizontalPickerViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UILabel *charactersLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;

@property NSMutableArray *ages;
@property (weak, nonatomic) IBOutlet V8HorizontalPickerView *agePickerView;
@property (weak, nonatomic) IBOutlet UIView *genderSelect;
@property (weak, nonatomic) IBOutlet UIView *genderLikeSelect;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property int selectedPhoto;

@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIView *profileBackground;
@property (weak, nonatomic) IBOutlet UIImageView *femaleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bothImageView;
@property (weak, nonatomic) IBOutlet UIImageView *maleImageView;

@property UserParse *user;
@end

@implementation ProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self populateProfile];
    [self customize];
    [self createAgePickerView];
    self.navigationItem.title = [UserParse currentUser].username;

    UINavigationBar *navigationBar = self.navigationController.navigationBar;

    [navigationBar setBackgroundImage:[UIImage imageNamed:@"nav"]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];

    [navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = [UserParse currentUser].username;
}

- (void)createAgePickerView
{
    self.ages = [NSMutableArray new];
    for (int i = MIN_AGE; i <= MAX_AGE; i++) {
        [self.ages addObject:[NSNumber numberWithInt:i]];
    }
	self.agePickerView.backgroundColor   = [UIColor clearColor];
	self.agePickerView.selectedTextColor = BLUE_COLOR;
	self.agePickerView.textColor   = GRAY_COLOR;
	self.agePickerView.delegate    = self;
	self.agePickerView.dataSource  = self;
	self.agePickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	self.agePickerView.selectionPoint = CGPointMake(self.view.frame.size.width/3, 0);
}

- (void)customize
{
    self.profileBackground.backgroundColor = BLUE_COLOR;
    self.view.backgroundColor = WHITE_COLOR;
    self.genderSelect.backgroundColor = [UIColor clearColor];
    [self.genderSelect.layer setBorderWidth:1];
    [self.genderSelect.layer setBorderColor:BLUE_COLOR.CGColor];
    self.genderLikeSelect.layer.cornerRadius = self.genderLikeSelect.frame.size.width/2;
    self.genderLikeSelect.backgroundColor = [UIColor clearColor];
    [self.genderLikeSelect.layer setBorderWidth:1];
    [self.genderLikeSelect.layer setBorderColor:BLUE_COLOR.CGColor];
    self.charactersLabel.textColor = ORANGE_COLOR;
    self.editView.frame = CGRectMake(0, self.view.frame.size.height, self.editView.frame.size.width, self.editView.frame.size.height);
    self.descriptionTextView.textColor = BLUE_COLOR;
    self.descriptionTextView.textAlignment = NSTextAlignmentJustified;

}

-(void) populateProfile
{
    PFQuery *query = [UserParse query];
    [query getObjectInBackgroundWithId:[UserParse currentUser].objectId
                                 block:^(PFObject *object, NSError *error)
     {
         self.user = (UserParse *)object;


         self.charactersLabel.text = [NSString stringWithFormat:@"%d/%d",self.user.desc.length,MAXLENGTH];

         if (![self.user.desc isEqualToString:@""]) {
             self.descriptionLabel.text = self.user.desc;
         } else {
             self.descriptionLabel.text = DEFAULT_DESCRIPTION;
         }
         if (![self.user.desc isEqualToString:@""]) {
             self.descriptionTextView.text = self.user.desc;
         } else {
             self.descriptionTextView.text = DEFAULT_DESCRIPTION;
         }

         if (!self.user.isMale) {
             [self femaleSelect:nil];
         } else {
             [self maleSelect:nil];
         }

         if ([self.user.sexuality isEqualToNumber:[NSNumber numberWithInt:1]]) {
             [self femaleLikeSelect:nil];
         }
         if ([self.user.sexuality isEqualToNumber:[NSNumber numberWithInt:2]]) {
             [self bothLikeSelect:nil];
         }
         [self.agePickerView scrollToElement:[NSNumber numberWithInt:self.user.age.intValue-18].intValue animated:YES];

     }];
}


- (IBAction)distanceChangeEnd:(UISlider *)sender
{
    self.user.distance = [NSNumber numberWithInt:(int)sender.value];
    [self.user saveInBackground];
}
- (IBAction)distanceChangedOutside:(UISlider *)sender
{
    self.user.distance = [NSNumber numberWithInt:(int)sender.value];
    [self.user saveInBackground];
}

- (void)viewDidLayoutSubviews
{

}

- (IBAction)maleSelect:(id)sender
{
    self.user.isMale = @"true";
    [UIView animateWithDuration:1.5 animations:^{
        self.genderSelect.frame = CGRectMake(109, self.genderSelect.frame.origin.y, self.genderSelect.frame.size.width, self.genderSelect.frame.size.height);
        [self.maleButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        [self.femaleButton setTitleColor:GRAY_COLOR forState:UIControlStateNormal];
        self.genderLabel.text = @"Gender: Male";
    } completion:^(BOOL finished) {

    }];
    [self.user saveInBackground];
}

- (IBAction)femaleSelect:(id)sender
{
    self.user.isMale = @"false";
    [UIView animateWithDuration:1.5 animations:^{
        self.genderSelect.frame = CGRectMake(202, self.genderSelect.frame.origin.y, self.genderSelect.frame.size.width, self.genderSelect.frame.size.height);
        [self.maleButton setTitleColor:GRAY_COLOR forState:UIControlStateNormal];
        [self.femaleButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        self.genderLabel.text = @"Gender: Female";

    } completion:^(BOOL finished) {


    }];
    [self.user saveInBackground];
}

- (IBAction)maleLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:0];
    [UIView animateWithDuration:0.7 animations:^{
        self.genderLikeSelect.frame = CGRectMake(40, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);
    } completion:^(BOOL finished) {
        self.maleImageView.image = [UIImage imageNamed:@"maleBlue"];
        self.femaleImageView.image = [UIImage imageNamed:@"female"];
        self.bothImageView.image = [UIImage imageNamed:@"both"];
    }];
    [self.user saveInBackground];
}

- (IBAction)femaleLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:1];
    [UIView animateWithDuration:0.7 animations:^{
        self.genderLikeSelect.frame = CGRectMake(127, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);

    } completion:^(BOOL finished) {
        self.maleImageView.image = [UIImage imageNamed:@"male"];
        self.femaleImageView.image = [UIImage imageNamed:@"femaleBlue"];
        self.bothImageView.image = [UIImage imageNamed:@"both"];
    }];
    [self.user saveInBackground];
}

- (IBAction)bothLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:2];
    [UIView animateWithDuration:0.7 animations:^{
        self.genderLikeSelect.frame = CGRectMake(219, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);

    } completion:^(BOOL finished) {
        self.maleImageView.image = [UIImage imageNamed:@"male"];
        self.femaleImageView.image = [UIImage imageNamed:@"female"];
        self.bothImageView.image = [UIImage imageNamed:@"bothBlue"];
    }];
    [self.user saveInBackground];
}

#pragma mark - V8 picker

#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker
{
	return [self.ages count];
}


#pragma mark - HorizontalPickerView Delegate Methods

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index
{
    NSNumber *num = [self.ages objectAtIndex:index];
	return num.description;
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index
{
    return 42;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    self.user.age = [NSNumber numberWithInt:index+MIN_AGE];
    [self.user saveInBackground];
    self.ageLabel.text = [NSString stringWithFormat:@"Age: %@",[NSNumber numberWithInt:index+MIN_AGE]];
}

- (IBAction)logOut:(id)sender {
    [UserParse logOut];
    [self performSegueWithIdentifier:@"logOut" sender:nil];
}

#pragma mark UItextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.descriptionTextView.text isEqualToString:DEFAULT_DESCRIPTION]) {
        self.descriptionTextView.text = @"";
    }
    [UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.editView.frame = CGRectMake(0, self.editView.frame.origin.y-80, self.editView.frame.size.width, self.editView.frame.size.height);
    } completion:^(BOOL finished) {

    }];

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.descriptionLabel.text = self.descriptionTextView.text;
    self.user.desc =self.descriptionTextView.text;
    [self.user saveInBackground];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.editView.frame = CGRectMake(0, self.editView.frame.origin.y+80, self.editView.frame.size.width, self.editView.frame.size.height);
    } completion:^(BOOL finished) {

    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.user saveInBackground];
        return NO;
    }
    self.descriptionLabel.text = textView.text;
    self.charactersLabel.text = [NSString stringWithFormat:@"%d/%d",textView.text.length,MAXLENGTH];
    return self.descriptionTextView.text.length + (text.length - range.length) <= MAXLENGTH;
}

- (IBAction)changePicture:(UIButton *)button
{
    self.selectedPhoto = button.tag;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


- (IBAction)editProfile:(id)sender
{
    if (!self.editing) {
        [self.editButton setTitle:@"Done"];
    } else {
        [self.editButton setTitle:@"Edit"];
    }
    self.editing = !self.editing;
    if (self.editing) {
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.editView.frame = CGRectMake(0, self.view.frame.size.height-self.editView.frame.size.height, self.editView.frame.size.width, self.editView.frame.size.height);
        } completion:^(BOOL finished) {

        }];
    } else {
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.editView.frame = CGRectMake(0, self.view.frame.size.height, self.editView.frame.size.width, self.editView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.title = @"Profile";
}

@end
