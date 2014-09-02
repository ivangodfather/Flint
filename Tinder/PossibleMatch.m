//
//  PossibleMatch.m
//  Tinder
//
//  Created by John Blanchard on 9/2/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "PossibleMatch.h"

@implementation PossibleMatch 
@dynamic fromUser;
@dynamic toUser;
@dynamic fromUserEmail;
@dynamic toUserEmail;
@dynamic toUserApproved;
@dynamic match;

+ (void)load {
    [self registerSubclass];
}



+ (NSString *)parseClassName {
    return @"PossibleMatch";
}

@end
