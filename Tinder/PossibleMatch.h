//
//  PossibleMatch.h
//  Tinder
//
//  Created by John Blanchard on 9/2/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserParse.h"

@interface PossibleMatch : PFObject <PFSubclassing>
@property (nonatomic, strong) UserParse* fromUser;
@property (nonatomic, strong) UserParse* toUser;
@property NSString* fromUserEmail;
@property NSString* toUserEmail;
@property NSString* toUserApproved;
@property NSString* match;
@end
