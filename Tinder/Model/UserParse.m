//
//  UserParse.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 26/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "UserParse.h"

@implementation UserParse

@dynamic age;
@dynamic photo;
@dynamic photo1;
@dynamic photo2;
@dynamic photo3;
@dynamic photo4;
@dynamic isMale;
@dynamic desc;
@dynamic sexuality;
@dynamic matches;
@dynamic distance;
@dynamic address;
@dynamic geoPoint;
@dynamic useAddress;

+ (void)load {
    [self registerSubclass];
    
}

- (NSUInteger)hash
{
    return self.objectId.intValue;
}

- (BOOL)isEqual:(UserParse *)user
{
    return [self.objectId isEqualToString:user.objectId];
}

@end
