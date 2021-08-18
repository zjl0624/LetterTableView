//
//  ViewController.m
//  LetterTableViewProject
//
//  Created by zjl on 2021/8/12.
//

#import "ViewController.h"
#import "LetterTableView.h"

@interface ViewController ()<LetterTableViewDelegate>
@property (nonatomic,strong) LetterTableView *letterView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 20; i++) {
        LetterTableItemModel *item = [[LetterTableItemModel alloc] initWithContent:[NSString stringWithFormat:@"成都%ld",i]];
        [dataArray addObject:item];
    }
    
    for (NSInteger i = 0; i < 20; i++) {
        LetterTableItemModel *item = [[LetterTableItemModel alloc] initWithContent:[NSString stringWithFormat:@"德阳%ld",i]];
        [dataArray addObject:item];
    }
    
    for (NSInteger i = 0; i < 20; i++) {
        LetterTableItemModel *item = [[LetterTableItemModel alloc] initWithContent:[NSString stringWithFormat:@"南充%ld",i]];
        [dataArray addObject:item];
    }
    
    for (NSInteger i = 0; i < 3; i++) {
        LetterTableItemModel *item = [[LetterTableItemModel alloc] initWithContent:[NSString stringWithFormat:@"%ld其他",i]];
        [dataArray addObject:item];
    }
    
    _letterView = [[LetterTableView alloc] initWithFrame:CGRectMake(0, 88, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 88) dataArray:dataArray delegate:self];
    [self.view addSubview:_letterView];
}



- (void)clickItem:(LetterTableItemModel *)item {
    
}
@end
