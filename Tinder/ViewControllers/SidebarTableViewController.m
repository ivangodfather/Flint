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
//    self.matchImageView.alpha = [SidebarTableViewController ipMaskedImageNamed:@"burn" color:RED_COLOR];
//    self.messagesImageView.image = [UIImage imageNamed:@"messages"];
//    self.avatarImageView.image = [UIImage imageNamed:@"avatar"];
//    self.matchLabel.alpha = 1;
//    self.messagesLabel.alpha = 0.5;
//    self.profileLabel.alpha = 0.5;
    self.cellMatch.backgroundColor = RED_COLOR;
    self.cellMessage.contentView.alpha = 0.5;
    self.profileCell.contentView.alpha = 0.5;
    self.cellShare.contentView.alpha = 0.5;
    PFQuery *query = [UserParse query];
    self.view.backgroundColor = BLUEDARK_COLOR;

    UIView *backgroundSelectedCell = [[UIView alloc] init];
    [backgroundSelectedCell setBackgroundColor:RED_COLOR];

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath.row == 1) {
        self.cellMatch.backgroundColor = RED_COLOR;
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellMatch.contentView.alpha = 1;
        self.cellMessage.contentView.alpha = 0.5;
        self.profileCell.contentView.alpha = 0.5;
        self.cellShare.contentView.alpha = 0.5;
    }
    if (indexPath.row == 2) {
        self.cellMessage.backgroundColor = RED_COLOR;
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellMessage.contentView.alpha = 1;
        self.profileCell.contentView.alpha = 0.5;
        self.cellMatch.contentView.alpha = 0.5;
        self.cellShare.contentView.alpha = 0.5;
    }
    if (indexPath.row == 3) {
        self.cellMatch.contentView.alpha = 0.5;
        self.cellMessage.contentView.alpha = 0.5;
        self.cellShare.contentView.alpha = 0.5;
        self.profileCell.contentView.alpha = 1;
        self.profileCell.backgroundColor = RED_COLOR;
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellMessage.backgroundColor = [UIColor clearColor];

    }
    if (indexPath.row == 4) {
        self.cellMatch.contentView.alpha = 0.5;
        self.cellMessage.contentView.alpha = 0.5;
        self.cellShare.contentView.alpha = 1;
        self.profileCell.contentView.alpha = 0.5;
        self.cellShare.backgroundColor = RED_COLOR;
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellMessage.backgroundColor = [UIColor clearColor];

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



@end
