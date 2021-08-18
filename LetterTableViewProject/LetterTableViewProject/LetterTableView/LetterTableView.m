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
static CGFloat const letterTableViewWidth = 20;
static CGFloat const letterTableViewCellHeight = 20;
static CGFloat const contentTableViewCellHeight = 52;
static CGFloat const contentTableViewSectionHeaderHeight = 32;
@interface LetterTableView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UITableView *letterTableView;
@property (nonatomic,strong) NSMutableArray<LetterWordItemModel *> *letterDataArray;
@property (nonatomic,strong) NSArray<NSArray<LetterTableItemModel *> *> *dataArray;
@property (nonatomic,weak) id<LetterTableViewDelegate> delegate;
@property (nonatomic,strong) LetterTipsView *letterTipsView;

@end
@implementation LetterTableView

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray<LetterTableItemModel *> *)dataArray delegate:(id<LetterTableViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        _letterDataArray = [[NSMutableArray alloc] init];
        NSArray *charArr = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
        [charArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LetterWordItemModel *item = [[LetterWordItemModel alloc] init];
            item.content = obj;
            [_letterDataArray addObject:item];
        }];
        
        NSMutableArray *resultArr = [[NSMutableArray alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < _letterDataArray.count; i++) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [array addObject:arr];
        }
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
        [self initTableView];
        [self initLetterTableView];
        _delegate = delegate;
        [self initLetterTipsView];
    }
    return self;
}

- (void)initDataArray {
    
}

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ContentTableViewCell" bundle:nil] forCellReuseIdentifier:contentCellIdentifier];
    
}

- (void)initLetterTableView {
    _letterTableView = [[UITableView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - letterTableViewWidth, [[UIScreen mainScreen] bounds].size.height/2 - letterTableViewCellHeight * _letterDataArray.count/2, letterTableViewWidth, letterTableViewCellHeight * _letterDataArray.count)];
    [self addSubview:_letterTableView];
    _letterTableView.dataSource = self;
    _letterTableView.delegate = self;
    [_letterTableView registerNib:[UINib nibWithNibName:@"LetterTableViewCell" bundle:nil] forCellReuseIdentifier:letterCellIdentifier];
    _letterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _letterTableView.backgroundColor = [UIColor clearColor];
    _letterTableView.bounces = NO;
    
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
        return [UIView new];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        [self.delegate clickItem:_dataArray[indexPath.section][indexPath.row]];
    }else {
        [_letterDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LetterWordItemModel *item = obj;
            if (idx == indexPath.row) {
                item.isCheck = YES;
            }else {
                item.isCheck = NO;
            }
        }];
        [_letterTableView reloadData];
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *arr = obj;
            if (arr.count > 0) {
                LetterTableItemModel *item = arr[0];
                if ([item.firstChar isEqualToString:[((LetterWordItemModel *)_letterDataArray[indexPath.row]).content uppercaseString]]) {
                    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    *stop = YES;
                }
                
            }
        }];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tableView) {
        NSArray <UITableViewCell *> *cellArray = [self.tableView visibleCells];
        NSInteger nowSection = -1;
        if (cellArray) {
            UITableViewCell *cell = [cellArray firstObject];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            nowSection = indexPath.section;
        }
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

- (void)letterPan:(UIPanGestureRecognizer *)pan {
    NSInteger state = pan.state;
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"1");
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        NSLog(@"2");
        CGPoint p = [pan locationInView:_letterTableView];
        NSInteger index = (NSInteger)p.y / letterTableViewCellHeight;
        if (index > _letterDataArray.count - 1) {
            index = _letterDataArray.count - 1;
        }
        if (index < 0) {
            index = 0;
        }
        [_letterDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LetterWordItemModel *item = obj;
            if (idx == index) {
                item.isCheck = YES;
            }else {
                item.isCheck = NO;
            }
        }];
        [_letterTableView reloadData];
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *arr = obj;
            if (arr.count > 0) {
                LetterTableItemModel *item = arr[0];
                if ([item.firstChar isEqualToString:((LetterWordItemModel *)_letterDataArray[index]).content]) {
                    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    *stop = YES;
                }
                
            }
        }];
        _letterTipsView.contentLabel.text = ((LetterWordItemModel *)_letterDataArray[index]).content;
        _letterTipsView.frame = CGRectMake(CGRectGetMinX(_letterTableView.frame)-62, CGRectGetMinY(_letterTableView.frame) + index * letterTableViewCellHeight - 26 + letterTableViewCellHeight/2, 62, 52);
        _letterTipsView.contentLabel.frame = CGRectMake(0, 0, CGRectGetWidth(_letterTipsView.frame), CGRectGetHeight(_letterTipsView.frame));
    }else {
        NSLog(@"3");
        _letterTipsView.frame = CGRectMake(0, 0, 0, 0);
    }

    

}

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
