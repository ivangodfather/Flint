//
//  UserMessagesViewController.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 30/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "UserMessagesViewController.h"
#import "UserCollectionViewCell.h"

@interface UserMessagesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>
@property NSMutableArray *messages;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *messagesView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property UIImage *toPhoto;
@property UIImage *fromPhoto;
@end

@implementation UserMessagesViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPhotos];

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
    self.collectionView.backgroundColor = BLUE_COLOR;
    self.messagesView.backgroundColor = BLUEDARK_COLOR;
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


    //[self hiddeKeyBoard];
#warning ASK DAVE
    //BUG ?
    NSLog(@"collection %@",NSStringFromCGRect(self.collectionView.frame));
    NSLog(@"view %@",NSStringFromCGRect(self.messagesView.frame));
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    NSLog(@"collection %@",NSStringFromCGRect(self.collectionView.frame));
    NSLog(@"view %@",NSStringFromCGRect(self.messagesView.frame));

    [self scrollCollectionView];
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:self.toUserParse];


    [PFPush sendPushMessageToQueryInBackground:query
                                   withMessage:message.text];
    self.textField.text = @"";



}

#pragma mark - UICollectionViewDatasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageParse *message = [self.messages objectAtIndex:indexPath.row];
    UserCollectionViewCell *cell;
    if ([message.fromUserParse.objectId isEqualToString:[UserParse currentUser].objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fromCell" forIndexPath:indexPath];
        cell.userImageView.image = self.fromPhoto;
        cell.messageTextView.textColor = BLACK_COLOR;
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"toCell" forIndexPath:indexPath];
        cell.userImageView.image = self.toPhoto;
    }

    cell.userImageView.layer.cornerRadius = 26;
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.layer.borderWidth = 2.0,
    cell.userImageView.layer.borderColor = [UIColor whiteColor].CGColor;

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    if ([[message createdAt] timeIntervalSinceNow] * -1 < 60 * 60 * 24) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }

    cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
    cell.messageTextView.text = message.text;

    return cell;
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

    PFQuery *query2 = [MessageParse query];
    [query2 whereKey:@"fromUserParse" equalTo:self.toUserParse];
    [query2 whereKey:@"toUserParse" equalTo:[PFUser currentUser]];

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
        NSLog(@"objects %@", objects);
        for (MessageParse *message in objects) {
            NSLog(@"mensaje %@", message.text);
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
                 [self getMessages];
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
                 [self getMessages];
             }
         }];
     }];


}

- (void)scrollCollectionView
{
    NSInteger item = [self.collectionView numberOfItemsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item -1 inSection:0];

    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

#pragma mark - TextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.messages.count>2) {
        [self performSelector:@selector(scrollCollectionView) withObject:nil afterDelay:0.0];
    }
    CGRect messagesViewFrame = self.messagesView.frame;
    CGRect collectionViewFrame = self.collectionView.frame;

    messagesViewFrame.origin.y = self.view.frame.size.height - KEYBOARD_HEIGHT - messagesViewFrame.size.height;
    collectionViewFrame.size.height = messagesViewFrame.origin.y;

    [UIView animateWithDuration:0.25 animations:^{
        self.collectionView.frame=collectionViewFrame;
        self.messagesView.frame=messagesViewFrame;
    }];

}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self.view endEditing:YES];
//    return YES;
//}

-(void)hiddeKeyBoard
{
    [self.textField resignFirstResponder];
    CGRect messagesViewFrame = self.messagesView.frame;
    CGRect collectionViewFrame = self.collectionView.frame;

    messagesViewFrame.origin.y = self.view.frame.size.height - messagesViewFrame.size.height;
    collectionViewFrame.size.height = self.view.frame.size.height - messagesViewFrame.size.height;

    [UIView animateWithDuration:0.25 animations:^{
        self.messagesView.frame = messagesViewFrame;
        self.collectionView.frame = collectionViewFrame;
    }];
}



@end
