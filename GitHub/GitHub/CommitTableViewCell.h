//
//  CommitTableViewCell.h
//  GitHub
//
//  Created by Anamika Sharma on 28/04/17.
//  Copyright © 2017 Anamika Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommitTableViewCell : UITableViewCell

-(void)setMessage:(NSString*)message;
-(void)setUserImageView:(NSString*)imageUrl;
-(void)setCommitId:(NSString*)commitId;
-(void)setUserName:(NSString*)name;

@end
