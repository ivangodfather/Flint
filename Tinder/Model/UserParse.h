//
//  UserParse.h
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 26/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import <Parse/Parse.h>

@interface UserParse : PFUser <PFSubclassing>
@property NSNumber* age;
@property BOOL isMale;
@property PFFile* photo;
@property NSNumber* sexuality;
@end
