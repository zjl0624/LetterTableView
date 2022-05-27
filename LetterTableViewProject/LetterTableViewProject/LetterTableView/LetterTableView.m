//
//  LetterTableView.m
//  LetterTableViewProject
//
//  Created by zjl on 2021/8/12.
//

#import "LetterTableView.h"
#import "ContentTableViewCell.h"
#import "LetterTableViewCell.h"
#import "LetterTipsView.h"

static NSString * const contentCellIdentifier = @"contentCell";
static NSString * const letterCellIdentifier = @"letterCell";
static CGFloat const letterTableViewWidth = 20;//字母表宽度
static CGFloat const letterTableViewCellHeight = 20;//字母表高度
static CGFloat const contentTableViewCellHeight = 52;//内容列表高度
static CGFloat const contentTableViewSectionHeaderHeight = 32;//内容sectionheader高度
@interface LetterTableView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UITableView *letterTableView;
@property (nonatomic,strong) NSMutableArray<LetterWordItemModel *> *letterDataArray;//abcd等26个字母加上一个#数组
@property (nonatomic,strong) NSArray<NSArray<LetterTableItemModel *> *> *dataArray;//内容数组
@property (nonatomic,weak) id<LetterTableViewDelegate> delegate;
@property (nonatomic,strong) LetterTipsView *letterTipsView;

@end
@implementation LetterTableView

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray<LetterTableItemModel *> *)dataArray delegate:(id<LetterTableViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *charArr = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
        
        [self initLetterDataArray:charArr];//构造字母表数组
        [self initDataArray:dataArray charArr:charArr];//构造内容数据源数组
        [self initTableView];
        [self initLetterTableView];
        _delegate = delegate;
        [self initLetterTipsView];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
}
//构造字母表数组
- (void)initLetterDataArray:(NSArray *)charArr{
    _letterDataArray = [[NSMutableArray alloc] init];
    [charArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LetterWordItemModel *item = [[LetterWordItemModel alloc] init];
        item.content = obj;
        [_letterDataArray addObject:item];
    }];
}
//构造内容数据源数组
- (void)initDataArray:(NSArray<LetterTableItemModel *> *)dataArray charArr:(NSArray *)charArr{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < _letterDataArray.count; i++) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [array addObject:arr];
    }
    //获取每个字符串的第一个字的第一个拼音字母
    [dataArray enumerateObjectsUsingBlock:^(LetterTableItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableString *pinyin = [[NSMutableString alloc] initWithString:obj.content];
        CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripDiacritics, NO);
        obj.firstChar = [[pinyin substringToIndex:1] uppercaseString];
        NSUInteger index = [charArr indexOfObject:obj.firstChar];
        if (index >= 0 && index < _letterDataArray.count) {
            [array[index] addObject:obj];
        }else {
            obj.firstChar = @"#";
            [array[_letterDataArray.count - 1] addObject:obj];
        }
    }];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *ar = obj;
        if (ar.count > 0) {
            [resultArr addObject:obj];
        }
    }];
    _dataArray = [resultArr copy];
}

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];//确定内容列表的位置和大小
    [self addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ContentTableViewCell" bundle:nil] forCellReuseIdentifier:contentCellIdentifier];
}

- (void)initLetterTableView {
    _letterTableView = [[UITableView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - letterTableViewWidth, [[UIScreen mainScreen] bounds].size.height/2 - (letterTableViewCellHeight * _letterDataArray.count/2 + 22), letterTableViewWidth, letterTableViewCellHeight * _letterDataArray.count + 22)];//确定字母表的位置和大小
    [self addSubview:_letterTableView];
    _letterTableView.dataSource = self;
    _letterTableView.delegate = self;
    [_letterTableView registerNib:[UINib nibWithNibName:@"LetterTableViewCell" bundle:nil] forCellReuseIdentifier:letterCellIdentifier];
    _letterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _letterTableView.backgroundColor = [UIColor clearColor];
    _letterTableView.bounces = NO;
    
    //给字母表添加拖动手势
    UIPanGestureRecognizer *letterPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(letterPan:)];
    [_letterTableView addGestureRecognizer:letterPan];

}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _tableView) {
        return _dataArray.count;
    }else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return ((NSArray *)_dataArray[section]).count;
    }else {
        return _letterDataArray.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        ContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contentCellIdentifier];
        cell.contentLabel.text = _dataArray[indexPath.section][indexPath.row].content;
        return cell;
    }else {
        LetterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:letterCellIdentifier];
        cell.letterWordLabel.text = _letterDataArray[indexPath.row].content;
        //配置字母表字母选中样式
        if (_letterDataArray[indexPath.row].isCheck) {
            cell.letterWordLabel.textColor = [UIColor whiteColor];
            cell.letterWordLabel.backgroundColor = [UIColor colorWithRed:0x56/255.0f green:0x70/255.0f blue:0xfe/255.0f alpha:1.0f];
        }else {
            cell.letterWordLabel.textColor = [UIColor colorWithRed:0xa2/255.0f green:0xa7/255.0f blue:0xc7/255.0f alpha:1.0f];
            cell.letterWordLabel.backgroundColor = [UIColor clearColor];
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        return contentTableViewCellHeight;
    }else {
        return letterTableViewCellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return contentTableViewSectionHeaderHeight;
    }else {
        return 0.000001;
    }
}

//配置sectionHeader的样式
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, contentTableViewSectionHeaderHeight)];
        view.backgroundColor = [UIColor colorWithRed:0xf2/255.0f green:0xf2/255.0f blue:0xf2/255.0f alpha:1.0f];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, [[UIScreen mainScreen] bounds].size.width, contentTableViewSectionHeaderHeight)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0xa2/255.0f green:0xa7/255.0f blue:0xc7/255.0f alpha:1.0f];
        [view addSubview:label];
        if (_dataArray.count > section) {
            if (((NSArray *)_dataArray[section]).count > 0) {
                LetterTableItemModel *item = _dataArray[section][0];
                label.text = item.firstChar;
            }
        }
        
        return view;
    }else {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, letterTableViewWidth, 0.00001)];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        //点击cell时调用，传入当前cell的model
        [self.delegate clickItem:_dataArray[indexPath.section][indexPath.row]];
    }else {
        //更新字母表选中状态
        [_letterDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LetterWordItemModel *item = obj;
            if (idx == indexPath.row) {
                item.isCheck = YES;
            }else {
                item.isCheck = NO;
            }
        }];
        [_letterTableView reloadData];
        //滚动到选中字母的位置
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *arr = obj;
            if (arr.count > 0) {
                LetterTableItemModel *item = arr[0];
                //如果选中的字母，列表中没有 则不动
                if ([item.firstChar isEqualToString:[((LetterWordItemModel *)_letterDataArray[indexPath.row]).content uppercaseString]]) {
                    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    *stop = YES;
                }
                
            }
        }];
    }
}

//监听列表滑动事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tableView) {
        //获取当前显示的section是哪个
        NSArray <UITableViewCell *> *cellArray = [self.tableView visibleCells];
        NSInteger nowSection = -1;
        if (cellArray) {
            UITableViewCell *cell = [cellArray firstObject];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            nowSection = indexPath.section;
        }
        //同时更改字母表选中状态
        if (_dataArray.count > 0) {
            if (((NSMutableArray *)_dataArray[nowSection]).count > 0) {
                LetterTableItemModel *item = _dataArray[nowSection][0];
                [_letterDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    LetterWordItemModel *o = obj;
                    if ([item.firstChar isEqualToString:o.content]) {
                        o.isCheck = YES;
                    }else {
                        o.isCheck = NO;
                    }
                }];
                [_letterTableView reloadData];
            }
        }

    }
}

//滑动手势触发的方法
- (void)letterPan:(UIPanGestureRecognizer *)pan {
    NSInteger state = pan.state;
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        //滑动中时，获取当前手指所在位置
        CGPoint p = [pan locationInView:_letterTableView];
        NSInteger index = (NSInteger)p.y / letterTableViewCellHeight - 1;
        //确保滑动的位置不超过最后一行
        if (index > _letterDataArray.count - 1) {
            index = _letterDataArray.count - 1;
        }
        //确保滑动的位置不小于第一行
        if (index < 0) {
            index = 0;
        }
        //根据手指位置，更改字母表选中状态
        [_letterDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LetterWordItemModel *item = obj;
            if (idx == index) {
                item.isCheck = YES;
            }else {
                item.isCheck = NO;
            }
        }];
        [_letterTableView reloadData];
        //滑动列表到指定位置
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *arr = obj;
            if (arr.count > 0) {
                LetterTableItemModel *item = arr[0];
                //如果选中的字母没有对应的内容 则不动
                if ([item.firstChar isEqualToString:((LetterWordItemModel *)_letterDataArray[index]).content]) {
                    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    *stop = YES;
                }
                
            }
        }];
        //在滑动时，显示提示当前选中的是哪个字母的提示view
        _letterTipsView.contentLabel.text = ((LetterWordItemModel *)_letterDataArray[index]).content;
        //确定提示view的显示位置
        _letterTipsView.frame = CGRectMake(CGRectGetMinX(_letterTableView.frame)-62, CGRectGetMinY(_letterTableView.frame) + index * letterTableViewCellHeight - 26 + letterTableViewCellHeight/2 + 22, 62, 52);
        _letterTipsView.contentLabel.frame = CGRectMake(0, 0, CGRectGetWidth(_letterTipsView.frame), CGRectGetHeight(_letterTipsView.frame));
    }else {
        //手指离开时，隐藏提示View
        _letterTipsView.frame = CGRectMake(0, 0, 0, 0);
    }

    

}

//初始化选中字母提示View
- (void)initLetterTipsView {
    _letterTipsView = [[LetterTipsView alloc] init];
    [self addSubview:_letterTipsView];
}

@end


@implementation LetterTableItemModel
- (instancetype)initWithContent:(NSString *)content {
    self = [super init];
    if (self) {
        _content = content;
    }
    return self;
}
@end
