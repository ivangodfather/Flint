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
#define MAXLENGTH 120
#define MAX_PHOTOS 10

@interface ProfileViewController () <V8HorizontalPickerViewDataSource, V8HorizontalPickerViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property NSMutableArray *ages;
@property (weak, nonatomic) IBOutlet V8HorizontalPickerView *agePickerView;
@property (weak, nonatomic) IBOutlet UIView *genderSelect;
@property (weak, nonatomic) IBOutlet UIView *genderLikeSelect;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto1;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto2;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto3;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto4;

@property int selectedPhoto;


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
    self.navigationItem.title = [PFUser currentUser].username;
//    if ([self.descriptionTextView.text isEqualToString:@""]) {
//        self.descriptionTextView.text = DEFAULT_DESCRIPTION;
//    }
    self.descriptionTextView.textContainer.maximumNumberOfLines = 4;


}

- (void)createAgePickerView
{
    self.ages = [NSMutableArray new];
    for (int i = MIN_AGE; i <= MAX_AGE; i++) {
        [self.ages addObject:[NSNumber numberWithInt:i]];
    }
	self.agePickerView.backgroundColor   = [UIColor clearColor];
	self.agePickerView.selectedTextColor = RED_COLOR;
	self.agePickerView.textColor   = WHITE_COLOR;
	self.agePickerView.delegate    = self;
	self.agePickerView.dataSource  = self;
	self.agePickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	self.agePickerView.selectionPoint = CGPointMake(self.view.frame.size.width/2.3, 0);
}

- (void)customize
{
    self.descriptionTextView.textColor = WHITE_COLOR;
    self.descriptionTextView.backgroundColor = BLUEDARK_COLOR;
    self.view.backgroundColor = BLUE_COLOR;
    self.genderSelect.backgroundColor = RED_COLOR;
    [self.genderSelect.layer setBorderWidth:1];
    [self.genderSelect.layer setBorderColor:RED_COLOR.CGColor];
    self.genderLikeSelect.backgroundColor = RED_COLOR;
    [self.genderLikeSelect.layer setBorderWidth:1];
    [self.genderLikeSelect.layer setBorderColor:RED_COLOR.CGColor];

}

-(void) populateProfile
{
    PFQuery *query = [UserParse query];
    [query getObjectInBackgroundWithId:[UserParse currentUser].objectId
                                 block:^(PFObject *object, NSError *error)
     {
         self.user = (UserParse *)object;
         NSLog(@"DESC %@", self.user.description);
         [self.user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
                 self.profilePhoto.image = [UIImage imageWithData:data];
             }
         }];
         [self.user.photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
                 self.profilePhoto1.image = [UIImage imageWithData:data];
             }
         }];
         [self.user.photo2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
                 self.profilePhoto2.image = [UIImage imageWithData:data];
             }
         }];
         [self.user.photo3 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
                 self.profilePhoto3.image = [UIImage imageWithData:data];
             }
         }];
         [self.user.photo4 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
                 self.profilePhoto4.image = [UIImage imageWithData:data];
             }
         }];
         if (![self.user.description isEqualToString:@""]) {
             NSLog(@"DESCRIPTION %@", self.user.description);
             self.descriptionTextView.text = self.user.description;
         }
     }];
}

- (IBAction)maleSelect:(id)sender
{
    self.user.isMale = YES;
    [UIView animateWithDuration:1 animations:^{
        self.genderSelect.frame = CGRectMake(80, self.genderSelect.frame.origin.y, self.genderSelect.frame.size.width, self.genderSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)femaleSelect:(id)sender
{
    self.user.isMale = NO;
    [UIView animateWithDuration:1 animations:^{
        self.genderSelect.frame = CGRectMake(173, self.genderSelect.frame.origin.y, self.genderSelect.frame.size.width, self.genderSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)maleLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:0];
    [UIView animateWithDuration:1 animations:^{
        self.genderLikeSelect.frame = CGRectMake(32, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)femaleLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:1];
    [UIView animateWithDuration:1 animations:^{
        self.genderLikeSelect.frame = CGRectMake(121, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)bothLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:2];
    [UIView animateWithDuration:1 animations:^{
        self.genderLikeSelect.frame = CGRectMake(215, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
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
	//self.infoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
}

- (IBAction)logOut:(id)sender {
    [UserParse logOut];
    [self performSegueWithIdentifier:@"logOut" sender:nil];
}

#pragma mark UItextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:DEFAULT_DESCRIPTION]) {
        textView.text = @"";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        self.user.description = self.descriptionTextView.text;
        [self.user saveInBackground];   
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= MAXLENGTH;
}

- (IBAction)changePicture:(UIButton *)button
{
    self.selectedPhoto = button.tag;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:MAX_PHOTOS+self.selectedPhoto];
    imageView.image = image;

    PFFile *file = [PFFile fileWithData:UIImagePNGRepresentation(image)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            return ;
        }
        switch (self.selectedPhoto) {
            case 1:
                self.user.photo1 = file;
                break;
            case 2:
                self.user.photo2 = file;
                break;
            case 3:
                self.user.photo3 = file;
                break;
            case 4:
                self.user.photo4 = file;
                break;
            default:
                self.user.photo = file;
                break;
        }
        [self.user saveInBackground];
    }];
    
}

@end
