//
//  LanguageViewController.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/12/27.
//

#import "LanguageViewController.h"
#import "LanguageTbc.h"

@interface LanguageViewController ()<UITableViewDataSource,UITableViewDelegate,LanguagePtl>
@property (weak, nonatomic) IBOutlet UITableView *languageTable;
@property (weak, nonatomic) IBOutlet UIButton *existBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeight;
@property (strong,nonatomic) NSArray *itemArray;
@property (assign,nonatomic) NSInteger indexRow;
@property (assign,nonatomic) NSInteger selectedRow;
@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LanguageCls share] add:self];
    _indexRow = [self setLanguage];
    _selectedRow = _indexRow;
    _titleLabel.text = kJL_TXT("set_language");
    _itemArray = @[kJL_TXT("follow_system"),kJL_TXT("simplified_chinese"),kJL_TXT("english"),kJL_TXT("japanese")];
    _languageTable.delegate = self;
    _languageTable.dataSource = self;
    _languageTable.rowHeight = 55;
    _languageTable.tableFooterView = [UIView new];
    [_languageTable registerNib:[UINib nibWithNibName:@"LanguageTbc" bundle:nil] forCellReuseIdentifier:@"LanguageTbc"];
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-60, kJL_HeightNavBar - 32, 60, 45)];
    [_confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_confirmBtn setTitle:kJL_TXT("confirm") forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [_confirmBtn setUserInteractionEnabled:false];
    [self.view addSubview:_confirmBtn];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    _titleHeight.constant = kJL_HeightNavBar+10;
}

- (IBAction)existBtnAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)confirmAction{
    switch (_selectedRow) {
        case 0:{
            kJL_SET("");
        }break;
        case 1:{
            kJL_SET("zh-Hans");
        }break;
        case 2:{
            kJL_SET("en");
        }break;
        case 3:
            kJL_SET("ja");
        default:
            break;
    }
    [_confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _indexRow = [self setLanguage];
    _selectedRow = _indexRow;
    [_confirmBtn setUserInteractionEnabled:false];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LanguageTbc *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageTbc" forIndexPath:indexPath];
    cell.titleLab.text = _itemArray[indexPath.row];
    if (indexPath.row == _indexRow){
        cell.selectImgv.hidden = false;
    }else{
        cell.selectImgv.hidden = true;
    }
    if (indexPath.row == _selectedRow) {
        cell.selectImgv.hidden = false;
    }else{
        cell.selectImgv.hidden = true;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    _selectedRow = indexPath.row;
    if (_indexRow == _selectedRow) {
        [_confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_confirmBtn setUserInteractionEnabled:false];
    }else{
        [_confirmBtn setTitleColor:kColor_0000 forState:UIControlStateNormal];
        [_confirmBtn setUserInteractionEnabled:true];
    }
    [tableView reloadData];
}

-(NSInteger)setLanguage{
    if ([kJL_GET isEqualToString:@"zh-Hans"]) {
        return 1;
    }else if ([kJL_GET isEqualToString:@"en"]) {
        return 2;
    }else if ([kJL_GET isEqualToString:@"ja"]){
        return 3;
    }else{
        return 0;
    }
}

-(void)languageChange{
    _titleLabel.text = kJL_TXT("set_language");
    [_confirmBtn setTitle:kJL_TXT("confirm") forState:UIControlStateNormal];
    _indexRow = [self setLanguage];
    _itemArray = @[kJL_TXT("follow_system"),kJL_TXT("simplified_chinese"),kJL_TXT("english"),kJL_TXT("japanese")];
    [_languageTable reloadData];
}



@end
