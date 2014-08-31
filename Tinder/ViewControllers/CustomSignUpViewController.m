//
//  MySignUpViewController.m
//  Tinder
//
//  Created by John Blanchard on 8/26/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "CustomSignUpViewController.h"
#import "UserParse.h"
#import "V8HorizontalPickerView.h"


#define MAX_AGE 99+1
#define MIN_AGE 18

@interface CustomSignUpViewController () <UIPickerViewDataSource, UIPickerViewDelegate, PFSignUpViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, V8HorizontalPickerViewDataSource, V8HorizontalPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *nameImageView;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet V8HorizontalPickerView *agePickerView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property NSMutableArray* ageArray;
@property (weak, nonatomic) IBOutlet UIButton* ageButton;
@property (weak, nonatomic) IBOutlet UIView *genderSelect;
@property (weak, nonatomic) IBOutlet UIView *genderLikeSelect;
@property UIImage* photo;
@property PFFile* file;
@property UIActionSheet *actionSheet;
@property NSString* errorMessage;
@property NSMutableArray *ages;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *pickerSelect;
@property UserParse *theUser;
@property NSNumber* sexuality;
@property BOOL isMale;
@end

@implementation CustomSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    self.sexuality = [NSNumber numberWithInt:0];
    self.isMale = YES;
    [self customizeView];
    [self setTextDelegates];
    [self populateArray];
    [self createAgePickerView];
}

- (void)createAgePickerView
{
    self.ages = [NSMutableArray new];
    for (int i = MIN_AGE; i <= MAX_AGE; i++) {
        [self.ages addObject:[NSNumber numberWithInt:i]];
    }
	self.agePickerView.backgroundColor   = [UIColor clearColor];
	self.agePickerView.selectedTextColor = [UIColor whiteColor];
	self.agePickerView.textColor   = [UIColor lightGrayColor];
	self.agePickerView.delegate    = self;
	self.agePickerView.dataSource  = self;
	self.agePickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	self.agePickerView.selectionPoint = CGPointMake(self.view.frame.size.width/2.3, 0);

	// add carat or other view to indicate selected element
	UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
	self.agePickerView.selectionIndicatorView = indicator;
    //	pickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location

	// add gradient images to left and right of view if desired
    //	UIImageView *leftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_fade"]];
    //	pickerView.leftEdgeView = leftFade;
    //
    //	UIImageView *rightFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_fade"]];
    //	pickerView.rightEdgeView = rightFade;

	// add image to left of scroll area
    //	UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loopback"]];
    //	pickerView.leftScrollEdgeView = leftImage;
    //	pickerView.scrollEdgeViewPadding = 20.0f;
    //
    //	UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airplane"]];
    //	pickerView.rightScrollEdgeView = rightImage;

    //
    //	self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //	y = y + tmpFrame.size.height + spacing;
    //	tmpFrame = CGRectMake(x, y, width, 50.0f);
    //	self.nextButton.frame = tmpFrame;
    //	[self.nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //	[self.nextButton	setTitle:@"Center Element 0" forState:UIControlStateNormal];
    //	self.nextButton.titleLabel.textColor = [UIColor blackColor];
    //	[self.view addSubview:self.nextButton];
    //
    //	self.reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //	y = y + tmpFrame.size.height + spacing;
    //	tmpFrame = CGRectMake(x, y, width, 50.0f);
    //	self.reloadButton.frame = tmpFrame;
    //	[self.reloadButton addTarget:self action:@selector(reloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //	[self.reloadButton setTitle:@"Reload Data" forState:UIControlStateNormal];
    //	[self.view addSubview:self.reloadButton];
    //
    //	y = y + tmpFrame.size.height + spacing;
    //	tmpFrame = CGRectMake(x, y, width, 50.0f);
    //	self.infoLabel = [[UILabel alloc] initWithFrame:tmpFrame];
    //	self.infoLabel.backgroundColor = [UIColor blackColor];
    //	self.infoLabel.textColor = [UIColor whiteColor];
    //	self.infoLabel.textAlignment = UITextAlignmentCenter;
    //	[self.view addSubview:self.infoLabel];
}

- (void)customizeView
{
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];

    [self.genderSelect.layer setBorderWidth:1];
    [self.genderSelect.layer setBorderColor:RED_COLOR.CGColor];
    [self.genderLikeSelect.layer setBorderWidth:1];
    [self.genderLikeSelect.layer setBorderColor:RED_COLOR.CGColor];
    [self.pickerSelect.layer setBorderWidth:1];
    [self.pickerSelect.layer setBorderColor:RED_COLOR.CGColor];
    [self.signUpButton.layer setBorderWidth:1];
    [self.signUpButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.profileImageView.layer setBorderWidth:1];
    [self.profileImageView.layer setBorderColor:RED_COLOR.CGColor];


}



- (IBAction)maleSelect:(id)sender
{
    self.isMale = YES;
    [UIView animateWithDuration:1 animations:^{
        self.genderSelect.frame = CGRectMake(80, self.genderSelect.frame.origin.y, self.genderSelect.frame.size.width, self.genderSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)femaleSelect:(id)sender
{
    self.isMale = NO;
    [UIView animateWithDuration:1 animations:^{
        self.genderSelect.frame = CGRectMake(173, self.genderSelect.frame.origin.y, self.genderSelect.frame.size.width, self.genderSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)maleLikeSelect:(id)sender
{
    self.sexuality = [NSNumber numberWithInt:0];
    [UIView animateWithDuration:1 animations:^{
        self.genderLikeSelect.frame = CGRectMake(28, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)femaleLikeSelect:(id)sender
{
    self.sexuality = [NSNumber numberWithInt:1];
    [UIView animateWithDuration:1 animations:^{
        self.genderLikeSelect.frame = CGRectMake(118, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)bothLikeSelect:(id)sender
{
    self.sexuality = [NSNumber numberWithInt:2];
    [UIView animateWithDuration:1 animations:^{
        self.genderLikeSelect.frame = CGRectMake(210, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, self.genderLikeSelect.frame.size.height);
        self.theUser.sexuality = [NSNumber numberWithInt:2];
    } completion:^(BOOL finished) {
    }];
}


#pragma mark - textField delegates
-(void)endTheEditing
{
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

-(void)setTextDelegates
{
    self.nameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    [self.nameTextField addTarget:self
                           action:@selector(endTheEditing)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.emailTextField addTarget:self
                            action:@selector(endTheEditing)
                  forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self
                               action:@selector(endTheEditing)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

#pragma mark - PickerView delegate methods
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.ageArray.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSNumber* num = [self.ageArray objectAtIndex:row];
    return [NSString stringWithFormat:@"%@", num];

}

#pragma mark - Button pressed methods
- (IBAction)pickImage:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)signUpHit:(id)sender
{
    if ([self checkForValidSignUp]) {
        [self onValidSignUpCreateUser];
    } else {
        [self presentErrorMessage];
    }
}

- (IBAction)ageHit:(id)sender
{
    self.actionSheet = [[UIActionSheet alloc] init];
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    self.picker.hidden = NO;
    self.picker.dataSource = self;
    self.picker.delegate = self;
    [self.picker reloadAllComponents];
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.backgroundColor = [UIColor redColor];
    [pickerToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self     action:@selector(doneButtonPressed:)];
    [barItems addObject:doneBtn];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [barItems addObject:cancelBtn];
    [pickerToolbar setItems:barItems animated:YES];
    [self.actionSheet addSubview:pickerToolbar];
    [self.actionSheet addSubview:self.picker];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 475)];
    [self.picker reloadAllComponents];
    [self.actionSheet reloadInputViews];
}


#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.file = [PFFile fileWithData:UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage])];
    self.profileImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.file saveInBackground];
}

#pragma mark - create user
-(BOOL)checkForValidSignUp
{
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""] || [self.nameTextField.text isEqualToString:@""] || self.file == nil || [self.ageButton.titleLabel.text isEqualToString:@"age"])
    {
        [self populateErrorMessage];
        return NO;
    } else {
        return YES;
    }
}

-(void) populateErrorMessage
{
    self.errorMessage = [[NSMutableString alloc] initWithString:@""];
    if ([self.emailTextField.text isEqualToString:@""]) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Missing an email\n"];
    }
    if ([self.nameTextField.text isEqualToString:@""]) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Missing a username\n"];
    }
    if ([self.passwordTextField.text isEqualToString:@""]) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Missing a password\n"];
    }
    if ([self.ageButton.titleLabel.text isEqualToString:@"age"] ) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Tap the age button to enter an age\n"];
    }
    if (self.file == nil) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Tap the photo button to pick a profile picture\n"];
    }
}

-(void) onValidSignUpCreateUser
{
    NSInteger row = [self.picker selectedRowInComponent:0];
    self.theUser = [UserParse object];
    self.theUser.username = self.nameTextField.text;
    self.theUser.email = self.emailTextField.text;
    self.theUser.age = [self.ageArray objectAtIndex:row];
    self.theUser.password = self.passwordTextField.text;
    self.theUser.photo = self.file;
    self.theUser.isMale = self.isMale;
    self.theUser.sexuality = self.sexuality;

    [self.theUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"age %@\n name %@\n email %@\n password %@\n photo %@\n sexuality %@\n isMale %d", self.theUser.age, self.theUser.username, self.theUser.email, self.theUser.password, self.theUser.photo, self.theUser.sexuality, self.theUser.isMale);
            [self performSegueWithIdentifier:@"signup" sender:self];
        } else {
            if (error.code == 202) {
                self.errorMessage = [NSString stringWithFormat:@"username: %@ already taken", self.nameTextField.text];
            }
            if (error.code == 203) {
                self.errorMessage = [NSString stringWithFormat:@"email: %@ already taken", self.emailTextField.text];
            }
            [self presentErrorMessage];
        }
    }];
}

-(void)presentErrorMessage
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:self.errorMessage delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Class Methods
-(void)populateArray
{
    self.ageArray = [NSMutableArray new];
    for (int i = MIN_AGE; i <= MAX_AGE; i++) {
        [self.ageArray addObject:[NSNumber numberWithInt:i]];
    }
    [self.picker reloadAllComponents];
}

- (void)cancelButtonPressed:(id)sender
{
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)doneButtonPressed:(id)sender
{
    int row = [self.picker selectedRowInComponent:0];
    [self.ageButton setTitle:[NSString stringWithFormat:@"%@",[self.ageArray objectAtIndex:row]] forState:UIControlStateNormal];
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
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

+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (IBAction)nameBegin:(id)sender {
    self.nameTextField.alpha = 1;
    self.emailTextField.alpha = 0.5;
    self.passwordTextField.alpha = 0.5;
    self.nameImageView.alpha = 1.0;
    self.emailImageView.alpha = 0.5;
    self.passwordImageView.alpha = 0.5;
}
- (IBAction)nameEnd:(id)sender {
}
- (IBAction)emailBegin:(id)sender {
    self.nameTextField.alpha = 0.5;
    self.emailTextField.alpha = 1;
    self.passwordTextField.alpha = 0.5;
    self.nameImageView.alpha = 0.5;
    self.emailImageView.alpha = 1.0;
    self.passwordImageView.alpha = 0.5;
}
- (IBAction)emailEnd:(id)sender {
}
- (IBAction)passwordBegin:(id)sender {
    self.nameTextField.alpha = 0.5;
    self.emailTextField.alpha = 0.5;
    self.passwordTextField.alpha = 1;
    self.nameImageView.alpha = 0.5;
    self.emailImageView.alpha = 0.5;
    self.passwordImageView.alpha = 1;
}
- (IBAction)passwordEnd:(id)sender {
}


@end
