//
//  UserMessagesViewController.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 30/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "UserMessagesViewController.h"
#import "UserCollectionViewCell.h"
#import "ImageViewController.h"
#import "Report.h"

@interface UserMessagesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@property NSMutableArray *messages;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *messagesView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property UIImage *toPhoto;
@property UIImage *fromPhoto;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@end

@implementation UserMessagesViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPhotos];
    [self getMessages];


    self.title = self.toUserParse.username;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddeKeyBoard)];
    [self.collectionView addGestureRecognizer:tapGestureRecognizer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessage:) name:receivedMessage object:nil];

    [self customize];
}

- (void)customize
{
    self.view.backgroundColor = WHITE_COLOR;
    self.collectionView.backgroundColor = WHITE_COLOR;
    self.messagesView.backgroundColor = BLUE_COLOR;
    UIImage *temp = [[UIImage imageNamed:@"x"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStyleBordered target:self action:@selector(popVC)];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendPressed:(id)sender
{
    if ([self.textField.text isEqualToString:@""]) {
        return;
    }
    MessageParse *message = [MessageParse object];
    message.text = self.textField.text;
    message.createdAt = [NSDate date];
    message.fromUserParse = [UserParse currentUser];
    message.toUserParse = self.toUserParse;
    message.read = NO;
    [message saveInBackground];
    [self.messages addObject:message];
    NSInteger item = [self.collectionView numberOfItemsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item  inSection:0];

    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];

    [self scrollCollectionView];
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:self.toUserParse];
    [query orderByDescending:@"createdAt"];
    [query setLimit:1];

    [PFPush sendPushMessageToQueryInBackground:query
                                   withMessage:message.text];
    self.textField.text = @"";
}


#pragma mark - UICollectionViewDatasource
#define MARGIN 10
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageParse *message = [self.messages objectAtIndex:indexPath.row];
    UserCollectionViewCell *cell;

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    if ([[message createdAt] timeIntervalSinceNow] * -1 < 60 * 60 * 24) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }

    //Image from me
    if ((message.sendImage || message.image) && [message.fromUserParse.objectId isEqualToString:[UserParse currentUser].objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fromCellImage" forIndexPath:indexPath];
        cell.userImageView.image = self.fromPhoto;
        __block UIImage *image;
        if (message.sendImage) {
            image = message.sendImage;
            cell.photoImageView.image = message.sendImage;
        } else {
            cell.photoImageView.backgroundColor = [UIColor redColor];
            [message.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.photoImageView.image = image;
                });

            }];
        }
        cell.photoImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
        [cell.photoImageView addGestureRecognizer:tap];
    }

    //Image from other
    if (message.image && [message.fromUserParse.objectId isEqualToString:self.toUserParse.objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"toCellImage" forIndexPath:indexPath];
        cell.userImageView.image = self.toPhoto;
        cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
        __block UIImage *image;
        [message.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.photoImageView.image = image;
            });

        }];
        cell.photoImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
        [cell.photoImageView addGestureRecognizer:tap];
    }

    //Text from me
    if (!message.image && !message.sendImage && [message.fromUserParse.objectId isEqualToString:[UserParse currentUser].objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fromCell" forIndexPath:indexPath];
        cell.userImageView.image = self.fromPhoto;
        cell.messageLabel.textColor = BLACK_COLOR;
    }

    //Text from other
    if (!message.image && !message.sendImage &&[message.fromUserParse.objectId isEqualToString:self.toUserParse.objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"toCell" forIndexPath:indexPath];
        cell.userImageView.image = self.toPhoto;
        cell.messageLabel.textColor = BLACK_COLOR;
    }
    UIView *view = [cell.contentView viewWithTag:666];
    [view removeFromSuperview];
    cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width/2;
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.layer.borderWidth = 2.0,
    cell.userImageView.layer.borderColor = BLUE_COLOR.CGColor;



    cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
    cell.dateLabel.textColor = BLACK_COLOR;
    cell.messageLabel.text = message.text;

    if (!message.image && !message.sendImage) {
        NSDictionary *attributes = @{NSFontAttributeName: cell.messageLabel.font};
        cell.messageLabel.numberOfLines = 0;
        CGRect rect = [message.text boundingRectWithSize:CGSizeMake(150, 100)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attributes
                                                 context:nil];
        rect.origin = cell.messageLabel.frame.origin;
        CGRect outlineRect = CGRectInset(rect, -15, -10);
        if (!message.image && !message.sendImage && [message.fromUserParse.objectId isEqualToString:[UserParse currentUser].objectId]) {
            rect.origin.x = cell.userImageView.frame.origin.x - outlineRect.size.width;
        }
        outlineRect.origin = rect.origin;
        outlineRect.origin.x -= MARGIN*1.5;
        outlineRect.origin.y -= MARGIN/1.5;

        UIView *bubbleView = [[UIView alloc] initWithFrame:outlineRect];
        if ( [message.fromUserParse.objectId isEqualToString:[UserParse currentUser].objectId]) {
            bubbleView.backgroundColor = BLUE_COLOR;
        } else {
            bubbleView.backgroundColor = GRAY_COLOR;
        }
        bubbleView.alpha = 0.5;
        bubbleView.layer.cornerRadius = 10.0f;
        bubbleView.tag = 666;


        cell.messageLabel.frame = rect;
        [cell.contentView addSubview:bubbleView];
        [cell.contentView sendSubviewToBack:bubbleView];

    }


    return cell;
}

-(CGPoint)centerOfCGFrame:(CGRect)rect
{
    return CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageParse *message = [self.messages objectAtIndex:indexPath.row];
    if (message.image || message.sendImage) {
        return CGSizeMake(310, 142);
    } else {
        return CGSizeMake(310, 80);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Other Stuff

- (void)getMessages
{
    PFQuery *query1 = [MessageParse query];
    [query1 whereKey:@"fromUserParse" equalTo:[PFUser currentUser]];
    [query1 whereKey:@"toUserParse" equalTo:self.toUserParse];
    [query1 whereKey:@"text" notEqualTo:@""];

    PFQuery *query2 = [MessageParse query];
    [query2 whereKey:@"fromUserParse" equalTo:self.toUserParse];
    [query2 whereKey:@"toUserParse" equalTo:[PFUser currentUser]];
    [query2 whereKey:@"text" notEqualTo:@""];


    PFQuery *orQUery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [orQUery orderByAscending:@"createdAt"];

    [orQUery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.messages = [objects mutableCopy];
        [self.collectionView reloadData];
        [self scrollCollectionView];
        for (MessageParse *message in objects) {
            message.read = YES;
            [message saveInBackground];
        }
    }];
}

- (void)getNewMessage:(NSNotification *)note
{

    PFQuery *query = [MessageParse query];
    [query whereKey:@"fromUserParse" equalTo:self.toUserParse];
    [query whereKey:@"toUserParse" equalTo:[PFUser currentUser]];
    [query whereKey:@"read" equalTo:[NSNumber numberWithBool:NO]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (MessageParse *message in objects) {
            [self.messages addObject:message];
            message.read = YES;
            [message saveInBackground];

            NSInteger item = [self.collectionView numberOfItemsInSection:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item  inSection:0];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        }
        [self scrollCollectionView];

    }];
}

- (void)getPhotos
{
    __block int count = 0;
    PFQuery *queryFrom = [UserParse query];
    [queryFrom getObjectInBackgroundWithId:[UserParse currentUser].objectId
                                     block:^(PFObject *object, NSError *error)
     {
         PFFile *file = [object objectForKey:@"photo"];
         [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             self.fromPhoto = [UIImage imageWithData:data];
             count++;
             if (count == 2) {
                 [self.collectionView reloadData];
             }
         }];
     }];
    PFQuery *queryTo = [UserParse query];

    [queryTo getObjectInBackgroundWithId:self.toUserParse.objectId
                                   block:^(PFObject *object, NSError *error)
     {
         PFFile *file = [object objectForKey:@"photo"];
         [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             self.toPhoto = [UIImage imageWithData:data];
             count++;
             if (count == 2) {
                 [self.collectionView reloadData];
             }
         }];
     }];


}

- (void)scrollCollectionView
{
    if (self.messages.count > 0) {
        NSInteger item = [self.collectionView numberOfItemsInSection:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item -1 inSection:0];

        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)hiddeKeyBoard
{
    [self.textField resignFirstResponder];
    CGRect messagesViewFrame = self.messagesView.frame;
    CGRect collectionViewFrame = self.collectionView.frame;

    messagesViewFrame.origin.y = self.view.frame.size.height - messagesViewFrame.size.height;
    collectionViewFrame.size.height = self.view.frame.size.height - messagesViewFrame.size.height;

    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            self.messagesView.frame = messagesViewFrame;
                            self.collectionView.frame = collectionViewFrame;

                        } completion:^(BOOL finished) {

                        }];
}


- (IBAction)sendPhoto:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.messages.count>2) {
        [self performSelector:@selector(scrollCollectionView) withObject:nil afterDelay:0.0];
    }
    CGRect messagesViewFrame = self.messagesView.frame;
    CGRect collectionViewFrame = self.collectionView.frame;

    messagesViewFrame.origin.y = self.view.frame.size.height - KEYBOARD_HEIGHT - messagesViewFrame.size.height;
    collectionViewFrame.size.height = messagesViewFrame.origin.y;

    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            self.messagesView.frame = messagesViewFrame;
                            self.collectionView.frame = collectionViewFrame;

                        } completion:^(BOOL finished) {

                        }];

}

#pragma mark - ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self hiddeKeyBoard];
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    MessageParse *message = [MessageParse object];
    message.fromUserParse = [UserParse currentUser];
    message.toUserParse = self.toUserParse;
    message.read = NO;
    [self.messages addObject:message];

    message.sendImage = image;
    NSInteger item = [self.collectionView numberOfItemsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    [self scrollCollectionView];


    PFFile *file = [PFFile fileWithData:UIImagePNGRepresentation(image)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        message.image = file;
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFQuery *query = [PFInstallation query];
            [query whereKey:@"user" equalTo:self.toUserParse];
            [query orderByDescending:@"createdAt"];
            [query setLimit:1];

            [PFPush sendPushMessageToQueryInBackground:query
                                           withMessage:[NSString stringWithFormat:@"New image from %@",[PFUser currentUser].username]];
        }];
    }];
}

- (void)tappedImage:(UITapGestureRecognizer *)tap
{
    [self performSegueWithIdentifier:@"image" sender:tap.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"image"]) {
        ImageViewController *vc = segue.destinationViewController;
        UIImageView *imageView = (UIImageView *)sender;
        vc.image = imageView.image;
    }
}


- (IBAction)actionPressed:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report",@"Unmatch", nil];
    [sheet showInView:self.view];
}

#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        PFQuery *query = [Report query];
        [query whereKey:@"user" equalTo:self.toUserParse];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            Report *report = objects.firstObject;
            if (!report) {
                Report *repo = [Report object];
                report = repo;
                report.user = self.toUserParse;
            }
            report.report = [NSNumber numberWithInt:report.report.intValue + 1];
            [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Saved!");
            }];

        }];
    }
    if (buttonIndex == 1) {
        PFQuery *query1 = [MessageParse query];
        [query1 whereKey:@"fromUserParse" equalTo:[PFUser currentUser]];
        [query1 whereKey:@"toUserParse" equalTo:self.toUserParse];
        [query1 whereKey:@"text" notEqualTo:@""];

        PFQuery *query2 = [MessageParse query];
        [query2 whereKey:@"fromUserParse" equalTo:self.toUserParse];
        [query2 whereKey:@"toUserParse" equalTo:[PFUser currentUser]];
        [query2 whereKey:@"text" notEqualTo:@""];
        
        
        PFQuery *orQUery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
        
        [orQUery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //[orQUery ]
        }];
    }
}

@end
