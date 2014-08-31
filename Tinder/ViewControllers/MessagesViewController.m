//
//  MessagesViewController.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 26/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "MessagesViewController.h"
#import "UserParse.h"
#import "MessageParse.h"
#import "UserTableViewCell.h"
#import "SPHViewController.h"
#import "UserMessagesViewController.h"

#define SECONDS_DAY 24*60*60

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property NSMutableArray *usersParseArray;
@property NSArray *filteredUsersArray;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property NSMutableArray *messages;
@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 20)];
    self.searchTextField.leftView = paddingView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:receivedMessage object:nil];

    [self loadChatPersons];

    [self customize];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];



#warning Move to signin delegate
    if ([PFUser currentUser]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
        [currentInstallation saveInBackground];
    }
}

- (void)customize
{
    self.tableView.backgroundColor = BLUE_COLOR;
    self.tableView.separatorColor = BLUEDARK_COLOR;
    self.searchTextField.backgroundColor = BLUEDARK_COLOR;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)receivedNotification:(NSNotification *)notification
{
    [self.usersParseArray removeAllObjects];
    [self.messages removeAllObjects];
    [self loadChatPersons];
}

- (void)loadChatPersons
{
    self.usersParseArray = [NSMutableArray new];
    self.messages = [NSMutableArray new];
    self.filteredUsersArray = [NSArray new];

    PFQuery *messageQueryFrom = [MessageParse query];
    [messageQueryFrom whereKey:@"fromUserParse" equalTo:[UserParse currentUser]];
    PFQuery *messageQueryTo = [MessageParse query];
    [messageQueryTo whereKey:@"toUserParse" equalTo:[UserParse currentUser]];
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[messageQueryFrom, messageQueryTo]];
    [both orderByDescending:@"createdAt"];

    [both findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableSet *users = [NSMutableSet new];
        for (MessageParse *message in objects) {
            if(![message.fromUserParse.objectId isEqualToString:[UserParse currentUser].objectId]) {
                NSUInteger count = users.count;
                [users addObject:message.fromUserParse];
                if (users.count > count) {
                    [self.messages addObject:message];
                    [self.usersParseArray addObject:message.fromUserParse];
                }
            }
            if(![message.toUserParse.objectId isEqualToString:[UserParse currentUser].objectId]) {
                NSUInteger count = users.count;
                [users addObject:message.toUserParse];
                if (users.count > count) {
                    [self.messages addObject:message];
                    [self.usersParseArray addObject:message.toUserParse];
                }
            }
        }
        [self.tableView reloadData];
    }];
}

#pragma mark TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UserParse *user;
    if (self.filteredUsersArray.count) {
        user = [self.filteredUsersArray objectAtIndex:indexPath.row];
    } else {
        user = [self.usersParseArray objectAtIndex:indexPath.row];
    }

    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        cell.nameTextLabel.text = user.username;
        cell.userImageView.layer.cornerRadius = 26;
        cell.userImageView.clipsToBounds = YES;
        cell.userImageView.layer.borderWidth = 2.0,
        cell.userImageView.layer.borderColor = [UIColor whiteColor].CGColor;

        UIImageView *accesory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accesory"]];
        accesory.frame = CGRectMake(15, 0, 15, 15);
        accesory.contentMode = UIViewContentModeScaleAspectFit;
        cell.accessoryView = accesory;

        MessageParse *message = [self.messages objectAtIndex:indexPath.row];
        cell.lastMessageLabel.text = message.text;
        if (!message.read) {
            cell.lastMessageLabel.textColor = RED_COLOR;
        } else {
            cell.lastMessageLabel.textColor = BLACK_COLOR;
        }
        cell.dateLabel.textColor = BLACK_COLOR;
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDoesRelativeDateFormatting:YES];
        if ([[message createdAt] timeIntervalSinceNow] * -1 < SECONDS_DAY) {
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
        } else {
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
        }
        cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = RED_COLOR;
        [cell setSelectedBackgroundView:bgColorView];
        [user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.userImageView.image = [UIImage imageWithData:data];
        }];


    }];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.filteredUsersArray.count) {
        return self.filteredUsersArray.count;
    }
    return self.usersParseArray.count;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chat"]) {
        UserMessagesViewController *vc = segue.destinationViewController;
        vc.toUserParse = [self.usersParseArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
}

- (IBAction)searchTextFieldChanged:(UITextField *)textfield
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username CONTAINS %@",textfield.text];
    self.filteredUsersArray = [self.usersParseArray filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

- (IBAction)searchTextFieldEnd:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)sendPhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

#pragma mark KeyBoard Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    [UIView animateWithDuration:1.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            CGRect rect = self.cameraButton.frame;
                            rect.origin.y -= 200;
                            self.cameraButton.frame = rect;
                        } completion:^(BOOL finished) {

                        }];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [UIView animateWithDuration:1.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            CGRect rect = self.cameraButton.frame;
                            rect.origin.y += 200;
                            self.cameraButton.frame = rect;
                        } completion:^(BOOL finished) {

                        }];
}
@end
