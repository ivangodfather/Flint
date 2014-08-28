#import "MessageParse.h"

@implementation MessageParse

@dynamic fromUserParse;
@dynamic toUserParse;
@dynamic text;
@dynamic image;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"MessageParse";
}

@end
