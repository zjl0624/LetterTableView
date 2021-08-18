//
//  LetterTableView.h
//  LetterTableViewProject
//
//  Created by zjl on 2021/8/12.
//

#import <UIKit/UIKit.h>
@class LetterTableItemModel;
@protocol LetterTableViewDelegate <NSObject>
@optional
- (void)clickItem:(LetterTableItemModel *)item;

@end
NS_ASSUME_NONNULL_BEGIN

@interface LetterTableView : UIView


- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray<LetterTableItemModel *> *)dataArray delegate:(id<LetterTableViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END


@interface LetterTableItemModel : NSObject

- (instancetype)initWithContent:(NSString *)content;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *firstChar;
@end
