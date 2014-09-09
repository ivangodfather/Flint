//
//  SidebarTableViewController.m
//  WordReminder
//
//  Created by Ivan Ruiz Monjo on 10/08/14.
//  Copyright (c) 2014 Ivan Ruiz Monjo. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"
#import "UserParse.h"


@interface SidebarTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *matchImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messagesImageView;
@property (weak, nonatomic) IBOutlet UILabel *messagesLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellShare;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellLocation;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *matchLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMatch;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMessage;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileCell;

@end

@implementation SidebarTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cellMatch.backgroundColor = BLUE_COLOR;
    PFQuery *query = [UserParse query];
    self.view.backgroundColor = BLUEDARK_COLOR;

    UIView *backgroundSelectedCell = [[UIView alloc] init];
    [backgroundSelectedCell setBackgroundColor:BLUE_COLOR];

    for (int section = 0; section < [self.tableView numberOfSections]; section++)
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellPath];

            [cell setSelectedBackgroundView:backgroundSelectedCell];
        }

    [query whereKey:@"objectId" equalTo:[UserParse currentUser].objectId];
    [query getObjectInBackgroundWithId:[UserParse currentUser].objectId
                                 block:^(PFObject *object, NSError *error) {

                                     UserParse *theUser = (UserParse *)object;
                                     [theUser[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                         if (!error) {
                                             self.profileImageView.image = [UIImage imageWithData:data];
                                             self.profileImageView.layer.cornerRadius = 62;
                                             self.profileImageView.clipsToBounds = YES;
                                             [self.profileImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
                                             [self.profileImageView.layer setBorderWidth:2.0];
                                         }
                                     }];
                                 }];
}


- (void)viewWillAppear:(BOOL)animated
{
    CGRect frame = self.profileImageView.frame;
    frame.origin.y -= 100;
    self.profileImageView.frame = frame;
    [super viewWillAppear:animated];
    [UIView animateWithDuration:1.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            CGRect frame = self.profileImageView.frame;
                            frame.origin.y += 100;
                            self.profileImageView.frame = frame;
                        } completion:^(BOOL finished) {

                        }];

    for (int i = 1; i < 7; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        CGRect cellFrame = cell.frame;
        cellFrame.origin.x -= cellFrame.size.width;
        cell.frame = cellFrame;

        [UIView animateWithDuration:0.3
                              delay:i*0.12+0.2
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.05
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
                                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                                CGRect cellFrame = cell.frame;
                                cellFrame.origin.x += cellFrame.size.width;
                                cell.frame = cellFrame;
                            } completion:^(BOOL finished) {

                            }];
    }

}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath.row == 1) {
        self.cellMatch.backgroundColor = BLUE_COLOR;
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellLocation.backgroundColor = [UIColor clearColor];
    }
    if (indexPath.row == 2) {
        self.cellMessage.backgroundColor = BLUE_COLOR;
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellLocation.backgroundColor = [UIColor clearColor];
    }
    if (indexPath.row == 3) {
        self.profileCell.backgroundColor = BLUE_COLOR;
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.cellLocation.backgroundColor = [UIColor clearColor];
    }
    if (indexPath.row == 4) {
        self.cellShare.backgroundColor = BLUE_COLOR;
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.cellLocation.backgroundColor = [UIColor clearColor];
    }

    if (indexPath.row == 5) {
        [UserParse logOut];
        return;
    }

    //UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;



    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;

        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: YES ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
    
}

- (IBAction)shareButton:(id)sender
{
    NSString *text = @"Discover people that likes you nearby!";
    NSURL *url = [NSURL URLWithString:@"http://www.google.es"];
    UIImage *image = [UIImage imageNamed:@"logo_mini"];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url, image] applicationActivities:nil];

    [self presentViewController:controller animated:YES completion:nil];

}


@end
