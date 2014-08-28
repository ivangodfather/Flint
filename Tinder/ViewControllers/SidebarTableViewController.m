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
@end

@implementation SidebarTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFQuery *query = [UserParse query];
    [query whereKey:@"objectId" equalTo:[UserParse currentUser].objectId];
    [query getObjectInBackgroundWithId:[UserParse currentUser].objectId
                                 block:^(PFObject *object, NSError *error) {

                                     UserParse *theUser = (UserParse *)object;
                                     [theUser[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                         if (!error) {
                                             self.profileImageView.image = [UIImage imageWithData:data];
                                             self.profileImageView.layer.cornerRadius = 60;
                                             self.profileImageView.clipsToBounds = YES;
                                         }
                                     }];
                                 }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = [UserParse currentUser].username;
            break;
        case 1:
            sectionName = NSLocalizedString(@"Messages", @"Messages");
            break;
            // ...
        default:
            sectionName = @"Profile";
            break;
    }
    return sectionName;
}

@end
