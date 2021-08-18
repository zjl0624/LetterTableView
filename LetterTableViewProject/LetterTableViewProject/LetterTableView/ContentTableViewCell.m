//
//  ContentTableViewCell.m
//  LetterTableViewProject
//
//  Created by zjl on 2021/8/12.
//

#import "ContentTableViewCell.h"
@interface ContentTableViewCell()

@end
@implementation ContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
