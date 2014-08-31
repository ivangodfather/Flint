#import "MessageParse.h"

@implementation MessageParse

@dynamic fromUserParse;
@dynamic toUserParse;
@dynamic text;
@dynamic image;
@dynamic createdAt;
@dynamic read;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"MessageParse";
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"from:%@\n to:%@\n text:%@\n date:%@\n",self.fromUserParse, self.toUserParse, self.text, self.createdAt];
}

@end
