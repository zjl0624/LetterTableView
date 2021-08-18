//
//  LetterTableViewCell.m
//  LetterTableViewProject
//
//  Created by zjl on 2021/8/12.
//

#import "LetterTableViewCell.h"

@implementation LetterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.letterWordLabel.layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@implementation LetterWordItemModel

@end
