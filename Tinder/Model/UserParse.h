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
@property NSString* isMale;
@property PFFile* photo;
@property PFFile* photo1;
@property PFFile* photo2;
@property PFFile* photo3;
@property PFFile* photo4;
@property NSString *desc;
@property NSNumber *distance;
@property NSNumber* sexuality;
@property NSMutableArray* matches;
@property NSString* address;
@property PFGeoPoint* geoPoint;
@property NSNumber *report;
@end
