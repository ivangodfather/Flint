//
//  Report.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 07/09/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "Report.h"

@implementation Report
@dynamic user;
@dynamic report;

+ (void)load {
    [self registerSubclass];

}

+ (NSString *)parseClassName {
    return @"Report";
}

@end
