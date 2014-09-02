#import <Parse/Parse.h>
#import "UserParse.h"

@interface MessageParse : PFObject <PFSubclassing>

@property (nonatomic, strong) UserParse *fromUserParse;
@property (nonatomic, strong) UserParse *toUserParse;
@property NSString* fromUserParseEmail;
@property NSString* toUserParseEmail;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic) BOOL read;

@property UIImage *sendImage;

@end
