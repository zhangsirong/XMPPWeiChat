//
//  UIImageView+HeadImage.h
//  MYWeiChat
//
//  Created by hp on 6/20/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (HeadImage)

- (void)imageWithUsername:(NSString*)username placeholderImage:(UIImage*)placeholderImage;

@end

@interface UILabel (Prase)

- (void)setTextWithUsername:(NSString *)username;

@end
