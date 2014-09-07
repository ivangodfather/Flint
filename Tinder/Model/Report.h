//
//  Report.h
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 07/09/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserParse.h"


@interface Report : PFObject <PFSubclassing>
@property (nonatomic, strong) UserParse *user;
@property NSNumber *report;
@end
