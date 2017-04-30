//
//  CommitTableViewCell.m
//  GitHub
//
//  Created by Anamika Sharma on 28/04/17.
//  Copyright © 2017 Anamika Sharma. All rights reserved.
//

#import "CommitTableViewCell.h"

@implementation CommitTableViewCell{
    
    __weak IBOutlet UILabel *userNameLabel;
    __weak IBOutlet UIImageView *userImage;
    __weak IBOutlet UILabel *messageLabel;
    __weak IBOutlet UILabel *commitIdLabel;
    __weak IBOutlet UISwitch *bookMarkSwitch;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessage:(NSString*)message{
    messageLabel.text = message;
//    messageLabel.adjustsFontSizeToFitWidth = YES;
//    messageLabel.minimumScaleFactor = 8 / messageLabel.font.pointSize;
//    messageLabel.numberOfLines = 1;
}
-(void)setUserImageView:(NSString*)imageUrl{
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(q, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *img = [[UIImage alloc] initWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            userImage.layer.cornerRadius = userImage.frame.size.width / 2;
            userImage.clipsToBounds = YES;
            [userImage setImage:img];
            
        });
    });    
}
-(void)setCommitId:(NSString*)commitId{
    commitIdLabel.text = commitId;
//    commitIdLabel.adjustsFontSizeToFitWidth = YES;
//    commitIdLabel.minimumScaleFactor = 8 / commitIdLabel.font.pointSize;
//    commitIdLabel.numberOfLines = 1;
}
-(void)setUserName:(NSString*)name{
    userNameLabel.text = name;
    userNameLabel.adjustsFontSizeToFitWidth = YES;
    userNameLabel.minimumScaleFactor = 8 / userNameLabel.font.pointSize;
    userNameLabel.numberOfLines = 1;
}
- (IBAction)bookmarkSwitchClicked:(id)sender {
    //add to bookMarked array
    NSString * bookmarkedCommitId = commitIdLabel.text;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdated"
                                                        object:bookmarkedCommitId];
}

@end
