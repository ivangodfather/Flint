//
//  UserCollectionViewCell.m
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 30/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "UserCollectionViewCell.h"

@implementation UserCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
