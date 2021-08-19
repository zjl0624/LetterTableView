//
//  LetterTableViewCell.h
//  LetterTableViewProject
//
//  Created by zjl on 2021/8/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LetterTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *letterWordLabel;

@end

NS_ASSUME_NONNULL_END
@interface LetterWordItemModel : NSObject
@property (nonatomic,strong) NSString *content;
@property (nonatomic,assign) BOOL isCheck;//是否被选中
@end
