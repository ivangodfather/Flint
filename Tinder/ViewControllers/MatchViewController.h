//
//  MatchViewController.h
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 04/09/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserParse.h"

@interface MatchViewController : UIViewController
@property UIImage *userImage;
@property UIImage *matchImage;
@property UserParse *user;
@property UserParse *matchUser;
@end
