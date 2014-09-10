//
//	CDemoCollectionViewController.m
//	Coverflow
//
//	Created by Jonathan Wight on 9/24/12.
//	Copyright 2012 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//		  conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//		  of conditions and the following disclaimer in the documentation and/or other materials
//		  provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Jonathan Wight.

#import "CDemoCollectionViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "CDemoCollectionViewCell.h"
#import "CCoverflowCollectionViewLayout.h"
#import "CReflectionView.h"
#import "UserParse.h"

@interface CDemoCollectionViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (readwrite, nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (readwrite, nonatomic, strong) NSMutableArray *assets;
@property (readwrite, nonatomic, strong) NSCache *imageCache;
@property int selectedImage;
@property UserParse *user;
@property int myCounter;
@end

@implementation CDemoCollectionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

    self.assets = [NSMutableArray new];
    PFQuery *query = [UserParse query];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [query getObjectInBackgroundWithId:[UserParse currentUser].objectId
                                 block:^(PFObject *object, NSError *error)
     {
         UIImage *image = [UIImage imageNamed:@"userPlaceholder"];
         for (int i = 0; i < 5; i++) {
             [self.assets addObject:image];
         }
         self.user = (UserParse *)object;
//         [self.user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//             if (!error) {
//                 [self.assets replaceObjectAtIndex:0 withObject:[UIImage imageWithData:data]];
//             }
//             [self.collectionView reloadData];
//         }];



         self.user = (UserParse *)object;
         [self.user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:0 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
         [self.user.photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:1 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
         [self.user.photo2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:2 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
         [self.user.photo3 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:3 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
         [self.user.photo4 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:4 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
     }];
}

- (void)check
{


}



#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
	return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	CDemoCollectionViewCell *theCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DEMO_CELL" forIndexPath:indexPath];

	if (theCell.gestureRecognizers.count == 0)
    {
		[theCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)]];
    }

    UIImage *theImage = [self.assets objectAtIndex:indexPath.row];
//    theCell.imageView.layer.cornerRadius = theCell.imageView.frame.size.width/2;
//    theCell.imageView.clipsToBounds = YES;
//    theCell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    theCell.imageView.image = theImage;
    theCell.backgroundColor = [UIColor clearColor];

	return(theCell);
}





#pragma mark -

- (void)tapCell:(UITapGestureRecognizer *)inGestureRecognizer
{
	NSIndexPath *theIndexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
    self.selectedImage = (int)theIndexPath.row;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo",@"Choose from library",nil];
    [sheet showInView:self.parentViewController.view];

    //	NSLog(@"%@", [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:theIndexPath]);
    //	NSURL *theURL = [self.assets objectAtIndex:theIndexPath.row];
    //	NSLog(@"%@", theURL);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    if (buttonIndex ==  1) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];

    }
    if (buttonIndex == 2) {
        NSLog(@"2");
    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.assets replaceObjectAtIndex:self.selectedImage withObject:image];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedImage inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image,0.9)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            return ;
        }
        switch (self.selectedImage) {
            case 1:
                self.user.photo1 = file;
                break;
            case 2:
                self.user.photo2 = file;
                break;
            case 3:
                self.user.photo3 = file;
                break;
            case 4:
                self.user.photo4 = file;
                break;
            default:
                self.user.photo = file;
                break;
        }
        [self.user saveInBackground];
    }];

}


@end
