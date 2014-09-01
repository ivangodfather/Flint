//
//  UserCollectionViewCell.h
//  Tinder
//
//  Created by Ivan Ruiz Monjo on 30/08/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@end
