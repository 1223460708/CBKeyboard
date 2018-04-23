//
//  CBCustomKeyboard.m
//  莱付
//
//  Created by 炳神 on 2018/4/20.
//  Copyright © 2018年 clearning. All rights reserved.
//

#import "CBCustomKeyboard.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@implementation CBRatio
+ (CGFloat)widthRatio:(CGFloat)width{
    return Screen_Width / 375 * width;
}
+ (CGFloat)heightRation:(CGFloat)height{
    if (Screen_Height == 812) {
        return height *1.0;
    }
    return Screen_Height / 667 * height;
}
@end


#pragma mark ---数字键盘
@implementation CBCustomKeyboard
{
    CGRect cb_frame;

    int horSplitNum;
    int verSplitNum;
    CGFloat viewWidth;
    CGFloat viewHeight;
    CGFloat lineSpacing;
    
    NSArray *numberArray;
}
#pragma mark ---lazy
- (UICollectionView *)numberCollection{
    if(!_numberCollection){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize = CGSizeMake((viewWidth - lineSpacing*3)/horSplitNum, (viewHeight - lineSpacing*3) / verSplitNum);
        flowlayout.sectionInset = UIEdgeInsetsMake(0.5, 0, 0, 0);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _numberCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, viewWidth - (viewWidth / horSplitNum), viewHeight) collectionViewLayout:flowlayout];
        _numberCollection.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        _numberCollection.delegate = self;
        _numberCollection.dataSource = self;
        _numberCollection.scrollEnabled = NO;
        [_numberCollection registerClass:[CBLetterCCell class] forCellWithReuseIdentifier:@"CBLetterCCell"];
    }
    return _numberCollection;
}
- (UIButton *)deleteBtn{
    if (!_deleteBtn){
        _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.numberCollection.bounds.size.width+lineSpacing, lineSpacing, cb_frame.size.width / 4, viewHeight/2)];
        _deleteBtn.backgroundColor = [UIColor whiteColor];
        [_deleteBtn setImage:[UIImage imageNamed:@"Resources.bundle/keyDelete.png"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}
- (UIButton *)keyboardDown{
    if (!_keyboardDown){
        _keyboardDown = [[UIButton alloc]initWithFrame:CGRectMake(self.numberCollection.bounds.size.width+lineSpacing, _deleteBtn.bounds.size.height+lineSpacing*2, cb_frame.size.width / 4, viewHeight/2)];
        _keyboardDown.backgroundColor = [UIColor whiteColor];
        [_keyboardDown setImage:[UIImage imageNamed:@"Resources.bundle/keyboardDown.png"] forState:UIControlStateNormal];
        [_keyboardDown addTarget:self action:@selector(keyboardDownnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardDown;
}



- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        cb_frame = frame;
        self.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        [self InitializeProperty];
        [self initNumberKeyboardView];
    }
    return self;
}

- (void)InitializeProperty{
    horSplitNum = 4;
    verSplitNum = 4;
    viewWidth = cb_frame.size.width;
    viewHeight = cb_frame.size.height;
    lineSpacing = 0.5;
    numberArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",self.isPoint ? @"" : @"ABC",@"0",self.isPoint ? @"." : @"@#&"];
    self.inputString = @"";
}


- (void) initNumberKeyboardView{
    
    [self addSubview:self.numberCollection];
    [self addSubview:self.deleteBtn];
    [self addSubview:self.keyboardDown];
    self.LetterKeyboard = [[CBCustomLetterKeyboard alloc] initWithFrame:CGRectMake(0, 0, cb_frame.size.width, cb_frame.size.height)];
    [self.LetterKeyboard setHidden:YES];
    __weak typeof(self) weakSelf = self;
    self.LetterKeyboard.myBlock = ^(KEYBOARDCLICKSTATUS status,NSString *text) {
        switch (status) {
            case SWITHNUMORLETTER: //隐藏字母键盘
            {
                [weakSelf.LetterKeyboard setHidden:YES];
            }
                break;
            case KEYBOARDDOWN:
                if (self.myBlock!=nil){
                    weakSelf.myBlock(KEYBOARDDOWN,nil);
                }
                
                break;
            case SYMBOL: //显示符号键盘
                [weakSelf.LetterKeyboard setHidden:YES];
                [weakSelf.SymbolKeyboard setHidden:NO];
                break;
            case OUTPUTSTRING:
                weakSelf.inputString = [NSString stringWithFormat:@"%@%@",weakSelf.inputString,weakSelf.LetterKeyboard.inputString];
                if (self.myBlock!=nil){
                    weakSelf.myBlock(OUTPUTSTRING,weakSelf.inputString);
                }
                break;
            case DELETE:
                if(weakSelf.inputString.length == 0){
                    return;
                }
                weakSelf.inputString = [weakSelf.inputString substringToIndex:[weakSelf.inputString length] - 1];
                if (self.myBlock!=nil){
                    weakSelf.myBlock(OUTPUTSTRING,weakSelf.inputString);
                }
                
                break;
            default:
                break;
        }
    };
    [self addSubview:self.LetterKeyboard];
    
    self.SymbolKeyboard = [[CBCustomSymbolKeyboard alloc]initWithFrame:CGRectMake(0, 0, cb_frame.size.width, cb_frame.size.height)];
    [self.SymbolKeyboard setHidden:YES];
    self.SymbolKeyboard.myBlock = ^(KEYBOARDCLICKSTATUS status,NSString *text) {
        switch (status) {
            case SWITHNUMORLETTER: //隐藏符号键盘
            {
                [weakSelf.SymbolKeyboard setHidden:YES];
            }
                break;
            case KEYBOARDDOWN: //键盘收起
                if (self.myBlock!=nil){
                    weakSelf.myBlock(KEYBOARDDOWN,nil);
                }
                break;
            case LETTER: //字母
                [weakSelf.LetterKeyboard setHidden:NO];
                [weakSelf.SymbolKeyboard setHidden:YES];
                break;
            case OUTPUTSTRING: //输出
                weakSelf.inputString = [NSString stringWithFormat:@"%@%@",weakSelf.inputString,weakSelf.SymbolKeyboard.inputString];
                if (self.myBlock!=nil){
                    weakSelf.myBlock(OUTPUTSTRING,weakSelf.inputString);
                }
                
                break;
            case DELETE: //删除
                if(weakSelf.inputString.length == 0){
                    return;
                }
                weakSelf.inputString = [weakSelf.inputString substringToIndex:[weakSelf.inputString length] - 1];
                if (self.myBlock!=nil){
                    weakSelf.myBlock(OUTPUTSTRING,weakSelf.inputString);
                }
                
                break;
            default:
                break;
        }
    };
    [self addSubview:self.SymbolKeyboard];
    
}




#pragma mark ---UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 12;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CBLetterCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CBLetterCCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [cell initCell:indexPath.row wihtDataSource:numberArray];
    return cell;
}

#pragma mark ---UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 9: //切换英文键盘
        {
            if(!self.isPoint){
                [self.LetterKeyboard setHidden:NO];
            }
            
        }
            break;
        case 11: //切换符号键盘
        {
            if (self.isPoint){
                self.inputString = [NSString stringWithFormat:@"%@%@",self.inputString,@"."];
                self.myBlock(OUTPUTSTRING,self.inputString);
            }else {
                [self.SymbolKeyboard setHidden:NO];
            }
            
        }
            break;
        case 10:
            self.inputString = [NSString stringWithFormat:@"%@%@",self.inputString,@"0"];
            self.myBlock(OUTPUTSTRING,self.inputString);
            break;
        default:
        {
            self.inputString = [NSString stringWithFormat:@"%@%d",self.inputString,[numberArray[indexPath.row] intValue]];
            self.myBlock(OUTPUTSTRING,self.inputString);
        }
            break;
    }
    
}

#pragma mark ---UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.5;
}


#pragma mark --数字 删除
- (void)deleteBtnClick{
    if(self.inputString.length == 0){
        return;
    }
    self.inputString = [self.inputString substringToIndex:[self.inputString length] - 1];
    self.myBlock(OUTPUTSTRING,self.inputString);
}
#pragma mark --键盘 收起
- (void)keyboardDownnClick{
    if (self.myBlock != nil){
        self.myBlock(KEYBOARDDOWN,nil);
    }
    
}
    
- (void)setInputString:(NSString *)inputString{
    _inputString = inputString;
}
- (void)setMark:(NSString *)mark{
    _mark = mark;
    [self.LetterKeyboard.safeKeyboardTipBtn setTitle:_mark forState:UIControlStateNormal];
}

- (void)setIsPoint:(BOOL)isPoint{
    _isPoint = isPoint;
    numberArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",self.isPoint ? @"" : @"ABC",@"0",self.isPoint ? @"." : @"@#&"];
    
    [self.numberCollection reloadData];
}

@end



#pragma mark 字母键盘
@implementation CBCustomLetterKeyboard
{
    CGRect cb_frame;
    CGFloat viewWidth;
    CGFloat viewHeight;
    CGFloat collectionViewSpacing;
    CGFloat collectionViewHeight;
    CGFloat itemSizeSpacing;
    
    NSArray <NSString*>*qpArray;
    NSArray <NSString*>*alArray;
    NSArray <NSString*>*zmArray;
    NSArray <NSString*>*symbolArray;
}

#pragma mark -lazy
- (UICollectionView *)qpCollectionView{
    if(!_qpCollectionView){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize = CGSizeMake((viewWidth - itemSizeSpacing*11)/10, collectionViewHeight);
        flowlayout.sectionInset = UIEdgeInsetsMake(0, [CBRatio widthRatio:5], 0, [CBRatio widthRatio:5]);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _qpCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, collectionViewSpacing, cb_frame.size.width, collectionViewHeight) collectionViewLayout:flowlayout];
        _qpCollectionView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        _qpCollectionView.delegate = self;
        _qpCollectionView.dataSource = self;
        _qpCollectionView.scrollEnabled = NO;
        [_qpCollectionView registerClass:[CBLetterCCell class] forCellWithReuseIdentifier:@"CBLetterCCell"];
        
    }
    return _qpCollectionView;
}

- (UICollectionView *)alCollectionView{
    if(!_alCollectionView){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize = CGSizeMake((viewWidth - itemSizeSpacing*11)/10, collectionViewHeight);
        flowlayout.sectionInset = UIEdgeInsetsMake(0, [CBRatio widthRatio:21], 0, [CBRatio widthRatio:21]);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _alCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, collectionViewSpacing*2+collectionViewHeight, cb_frame.size.width, collectionViewHeight) collectionViewLayout:flowlayout];
        _alCollectionView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        _alCollectionView.delegate = self;
        _alCollectionView.dataSource = self;
        _alCollectionView.scrollEnabled = NO;
        [_alCollectionView registerClass:[CBLetterCCell class] forCellWithReuseIdentifier:@"CBLetterCCell"];
    }
    return _alCollectionView;
}

- (UICollectionView *)zmCollectionView{
    if(!_zmCollectionView){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize = CGSizeMake((viewWidth - itemSizeSpacing*11)/10, collectionViewHeight);
        flowlayout.sectionInset = UIEdgeInsetsMake(0, [CBRatio widthRatio:5], 0, [CBRatio widthRatio:5]);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _zmCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake([CBRatio widthRatio:55], collectionViewSpacing*3+collectionViewHeight*2, cb_frame.size.width - [CBRatio widthRatio:110], collectionViewHeight) collectionViewLayout:flowlayout];
        _zmCollectionView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        _zmCollectionView.delegate = self;
        _zmCollectionView.dataSource = self;
        _zmCollectionView.scrollEnabled = NO;
        [_zmCollectionView registerClass:[CBLetterCCell class] forCellWithReuseIdentifier:@"CBLetterCCell"];
    }
    return _zmCollectionView;
}

- (UIButton *)bigSmallBtn{
    if (!_bigSmallBtn){
        _bigSmallBtn = [[UIButton alloc]initWithFrame:CGRectMake(itemSizeSpacing, collectionViewSpacing*3+collectionViewHeight*2, (viewWidth - _zmCollectionView.frame.size.width - itemSizeSpacing*2)/2, collectionViewHeight)];
        _bigSmallBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [_bigSmallBtn setImage:[UIImage imageNamed:@"Resources.bundle/bigSmall.png"] forState:UIControlStateNormal];
        [_bigSmallBtn addTarget:self action:@selector(bigSmallBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _bigSmallBtn.layer.cornerRadius = 4;
        _bigSmallBtn.layer.masksToBounds = YES;
    }
    return _bigSmallBtn;
}
-(UIButton *)deleteBtn{
    if (!_deleteBtn){
        _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewWidth - [CBRatio widthRatio:55], collectionViewSpacing*3+collectionViewHeight*2, (viewWidth - _zmCollectionView.frame.size.width - itemSizeSpacing*2)/2, collectionViewHeight)];
        _deleteBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [_deleteBtn setImage:[UIImage imageNamed:@"Resources.bundle/keyDelete.png"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.layer.cornerRadius = 4;
        _deleteBtn.layer.masksToBounds = YES;
    }
    return _deleteBtn;
}
- (UIButton *)swithNumberBtn{
    if (!_swithNumberBtn){
        _swithNumberBtn = [[UIButton alloc]initWithFrame:CGRectMake(itemSizeSpacing, collectionViewSpacing*4+collectionViewHeight*3, (viewWidth - _zmCollectionView.frame.size.width - itemSizeSpacing*2)/2, collectionViewHeight)];
        _swithNumberBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [_swithNumberBtn setTitle:@"123" forState:UIControlStateNormal];
        [_swithNumberBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _swithNumberBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_swithNumberBtn addTarget:self action:@selector(swithNumberBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _swithNumberBtn.layer.cornerRadius = 4;
        _swithNumberBtn.layer.masksToBounds = YES;
    }
    return _swithNumberBtn;
}
- (UIButton *)characterBtn{
    if (!_characterBtn){
        _characterBtn = [[UIButton alloc]initWithFrame:CGRectMake(itemSizeSpacing*2+(viewWidth - _zmCollectionView.frame.size.width - itemSizeSpacing*2)/2, collectionViewSpacing*4+collectionViewHeight*3, (viewWidth - _zmCollectionView.frame.size.width - itemSizeSpacing*2)/2, collectionViewHeight)];
        _characterBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [_characterBtn setTitle:@"@#&" forState:UIControlStateNormal];
        [_characterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _characterBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_characterBtn addTarget:self action:@selector(characterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _characterBtn.layer.cornerRadius = 4;
        _characterBtn.layer.masksToBounds = YES;
    }
    return _characterBtn;
}
- (UIButton *)safeKeyboardTipBtn{
    if (!_safeKeyboardTipBtn){
        _safeKeyboardTipBtn = [[UIButton alloc]initWithFrame:CGRectMake(itemSizeSpacing*3+(cb_frame.size.width - _zmCollectionView.frame.size.width - itemSizeSpacing*2), collectionViewSpacing*4+collectionViewHeight*3, (viewWidth - (itemSizeSpacing*3+(viewWidth - _zmCollectionView.frame.size.width - itemSizeSpacing*2)) - [CBRatio widthRatio:97]), collectionViewHeight)];
        _safeKeyboardTipBtn.backgroundColor = [UIColor whiteColor];
        [_safeKeyboardTipBtn setTitle:@"安全键盘" forState:UIControlStateNormal];
        [_safeKeyboardTipBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _safeKeyboardTipBtn.titleLabel.font = [UIFont systemFontOfSize:[CBRatio heightRation:16]];
        _safeKeyboardTipBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _safeKeyboardTipBtn.layer.cornerRadius = 4;
        _safeKeyboardTipBtn.layer.masksToBounds = YES;
    }
    return _safeKeyboardTipBtn;
}
- (UIButton *)keyboardDown{
    if (!_keyboardDown){
        _keyboardDown = [[UIButton alloc]initWithFrame:CGRectMake(self.safeKeyboardTipBtn.frame.size.width + self.safeKeyboardTipBtn.frame.origin.x + itemSizeSpacing, collectionViewSpacing*4+collectionViewHeight*3, [CBRatio widthRatio:97] - itemSizeSpacing*2, collectionViewHeight)];
        _keyboardDown.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [_keyboardDown setImage:[UIImage imageNamed:@"Resources.bundle/keyboardDown.png"] forState:UIControlStateNormal];
        [_keyboardDown addTarget:self action:@selector(keyboardDownClick) forControlEvents:UIControlEventTouchUpInside];
        _keyboardDown.layer.cornerRadius = 4;
        _keyboardDown.layer.masksToBounds = YES;
    }
    return _keyboardDown;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        cb_frame = frame;
        self.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        [self InitializeProperty];
        [self initLetterKeyboardView];
    }
    return self;
}

- (void)InitializeProperty{

    viewWidth = cb_frame.size.width;
    viewHeight = cb_frame.size.height;
    collectionViewSpacing = [CBRatio heightRation:10];
    collectionViewHeight = [CBRatio heightRation:42];
    itemSizeSpacing = [CBRatio widthRatio:5];
    self.inputString = @"";
    qpArray = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p"];
    alArray = @[@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l"];
    zmArray = @[@"z",@"x",@"c",@"v",@"b",@"n",@"m"];
}

#pragma mark  初始化
- (void)initLetterKeyboardView{
    [self addSubview:self.qpCollectionView];
    [self addSubview:self.alCollectionView];
    [self addSubview:self.zmCollectionView];
    [self addSubview:self.bigSmallBtn];
    [self addSubview:self.deleteBtn];
    [self addSubview:self.swithNumberBtn];
    [self addSubview:self.characterBtn];
    [self addSubview:self.safeKeyboardTipBtn];
    [self addSubview:self.keyboardDown];
}

#pragma mark ---UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.qpCollectionView){
        return qpArray.count;
    }else if (collectionView == self.alCollectionView){
        return alArray.count;
    }else if (collectionView == self.zmCollectionView){
        return zmArray.count;
    }else {
        return symbolArray.count;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CBLetterCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CBLetterCCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.layer.cornerRadius = 4;
    cell.layer.masksToBounds = YES;
    if (collectionView == self.qpCollectionView){
        [cell initCell:indexPath.row wihtDataSource:qpArray];
    }else if (collectionView == self.alCollectionView){
        [cell initCell:indexPath.row wihtDataSource:alArray];
    }else{
        [cell initCell:indexPath.row wihtDataSource:zmArray];
    }
    return cell;
    
    
}

#pragma mark ---UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.qpCollectionView){
        self.inputString = qpArray[indexPath.row];
    }else if (collectionView == self.alCollectionView){
        self.inputString = alArray[indexPath.row];
    }else{
        self.inputString = zmArray[indexPath.row];
    }
    self.myBlock(OUTPUTSTRING,self.inputString);
}

#pragma mark ---UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemSizeSpacing;
}

#pragma mark ----btnClick
- (void)swithNumberBtnClick{
    self.myBlock(SWITHNUMORLETTER,nil);
}
- (void)bigSmallBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected){
        self.bigSmallBtn.backgroundColor = [UIColor whiteColor];
        qpArray = @[@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P"];
        alArray = @[@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L"];
        zmArray = @[@"Z",@"X",@"C",@"V",@"B",@"N",@"M"];
    }else {
        self.bigSmallBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];;
        qpArray = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p"];
        alArray = @[@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l"];
        zmArray = @[@"z",@"x",@"c",@"v",@"b",@"n",@"m"];
    }
    [self.qpCollectionView reloadData];
    [self.alCollectionView reloadData];
    [self.zmCollectionView reloadData];
}

#pragma mark --切换符号键盘
- (void)characterBtnClick:(UIButton *)sender{
    if (self.myBlock != nil){
        self.myBlock(SYMBOL,nil);
    }
    
}
- (void)keyboardDownClick{
    if (self.myBlock != nil){
        self.myBlock(KEYBOARDDOWN,nil);
    }
    
}
- (void)deleteBtnClick{
    if (self.myBlock != nil){
        self.myBlock(DELETE,nil);
    }
    
}

@end

#pragma mark 符号
@implementation CBCustomSymbolKeyboard
{
    CGRect cb_frame;
    CGFloat viewWidth;
    CGFloat viewHeight;
    CGFloat collectionViewSpacing;
    CGFloat collectionViewHeight;
    CGFloat itemSizeSpacing;
    
    NSArray <NSString*>*symbolOneArray;
    NSArray <NSString*>*symbolTwoArray;
    NSArray <NSString*>*symbolThreeArray;
    NSArray <NSString*>*symbolFourArray;
}

#pragma mark -lazy
- (UICollectionView *)symbolOneCollectionView{
    if(!_symbolOneCollectionView){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize = CGSizeMake((viewWidth - itemSizeSpacing*11)/10, collectionViewHeight);
        flowlayout.sectionInset = UIEdgeInsetsMake(0, [CBRatio widthRatio:5], 0, [CBRatio widthRatio:5]);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _symbolOneCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, collectionViewSpacing, cb_frame.size.width, collectionViewHeight) collectionViewLayout:flowlayout];
        _symbolOneCollectionView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        _symbolOneCollectionView.delegate = self;
        _symbolOneCollectionView.dataSource = self;
        _symbolOneCollectionView.scrollEnabled = NO;
        [_symbolOneCollectionView registerClass:[CBLetterCCell class] forCellWithReuseIdentifier:@"CBLetterCCell"];
        
    }
    return _symbolOneCollectionView;
}

- (UICollectionView *)symbolTwoCollectionView{
    if(!_symbolTwoCollectionView){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize = CGSizeMake((viewWidth - itemSizeSpacing*11)/10, collectionViewHeight);
        flowlayout.sectionInset = UIEdgeInsetsMake(0, [CBRatio widthRatio:21], 0, [CBRatio widthRatio:21]);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _symbolTwoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, collectionViewSpacing*2+collectionViewHeight, cb_frame.size.width, collectionViewHeight) collectionViewLayout:flowlayout];
        _symbolTwoCollectionView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        _symbolTwoCollectionView.delegate = self;
        _symbolTwoCollectionView.dataSource = self;
        _symbolTwoCollectionView.scrollEnabled = NO;
        [_symbolTwoCollectionView registerClass:[CBLetterCCell class] forCellWithReuseIdentifier:@"CBLetterCCell"];
    }
    return _symbolTwoCollectionView;
}

- (UICollectionView *)symbolThreeCollectionView{
    if(!_symbolThreeCollectionView){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize = CGSizeMake((viewWidth - itemSizeSpacing*11)/10, collectionViewHeight);
        flowlayout.sectionInset = UIEdgeInsetsMake(0, [CBRatio widthRatio:5], 0, [CBRatio widthRatio:5]);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _symbolThreeCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake([CBRatio widthRatio:55], collectionViewSpacing*3+collectionViewHeight*2, cb_frame.size.width - [CBRatio widthRatio:110], collectionViewHeight) collectionViewLayout:flowlayout];
        _symbolThreeCollectionView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        _symbolThreeCollectionView.delegate = self;
        _symbolThreeCollectionView.dataSource = self;
        _symbolThreeCollectionView.scrollEnabled = NO;
        [_symbolThreeCollectionView registerClass:[CBLetterCCell class] forCellWithReuseIdentifier:@"CBLetterCCell"];
    }
    return _symbolThreeCollectionView;
}

- (UICollectionView *)symbolFourCollectionView{
    if(!_symbolFourCollectionView){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize = CGSizeMake((viewWidth - itemSizeSpacing*11)/10, collectionViewHeight);
        flowlayout.sectionInset = UIEdgeInsetsMake(0, [CBRatio widthRatio:5], 0, [CBRatio widthRatio:5]);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _symbolFourCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake([CBRatio widthRatio:55], collectionViewSpacing*4+collectionViewHeight*3,viewWidth - [CBRatio widthRatio:92] - [CBRatio widthRatio:55], collectionViewHeight) collectionViewLayout:flowlayout];
        _symbolFourCollectionView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        _symbolFourCollectionView.delegate = self;
        _symbolFourCollectionView.dataSource = self;
        _symbolFourCollectionView.scrollEnabled = NO;
        [_symbolFourCollectionView registerClass:[CBLetterCCell class] forCellWithReuseIdentifier:@"CBLetterCCell"];
    }
    return _symbolFourCollectionView;
}

- (UIButton *)letterBtn{
    if (!_letterBtn){
        _letterBtn = [[UIButton alloc]initWithFrame:CGRectMake(itemSizeSpacing, collectionViewSpacing*3+collectionViewHeight*2, (viewWidth - self.symbolThreeCollectionView.frame.size.width - itemSizeSpacing*2)/2, collectionViewHeight)];
        _letterBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];;
        [_letterBtn setTitle:@"ABC" forState:UIControlStateNormal];
        [_letterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _letterBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_letterBtn addTarget:self action:@selector(letterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _letterBtn.layer.cornerRadius = 4;
        _letterBtn.layer.masksToBounds = YES;
    }
    return _letterBtn;
}
-(UIButton *)deleteBtn{
    if (!_deleteBtn){
        _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewWidth - [CBRatio widthRatio:55], collectionViewSpacing*3+collectionViewHeight*2, (viewWidth - self.symbolThreeCollectionView.frame.size.width - itemSizeSpacing*2)/2, collectionViewHeight)];
        _deleteBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [_deleteBtn setImage:[UIImage imageNamed:@"Resources.bundle/keyDelete.png"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.layer.cornerRadius = 4;
        _deleteBtn.layer.masksToBounds = YES;
    }
    return _deleteBtn;
}
- (UIButton *)swithNumberBtn{
    if (!_swithNumberBtn){
        _swithNumberBtn = [[UIButton alloc]initWithFrame:CGRectMake(itemSizeSpacing, collectionViewSpacing*4+collectionViewHeight*3, (viewWidth - self.symbolThreeCollectionView.frame.size.width - itemSizeSpacing*2)/2, collectionViewHeight)];
        _swithNumberBtn.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [_swithNumberBtn setTitle:@"123" forState:UIControlStateNormal];
        [_swithNumberBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _swithNumberBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_swithNumberBtn addTarget:self action:@selector(swithNumberBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _swithNumberBtn.layer.cornerRadius = 4;
        _swithNumberBtn.layer.masksToBounds = YES;
    }
    return _swithNumberBtn;
}


- (UIButton *)keyboardDown{
    if (!_keyboardDown){
        _keyboardDown = [[UIButton alloc]initWithFrame:CGRectMake(self.symbolFourCollectionView.frame.size.width + self.symbolFourCollectionView.frame.origin.x, collectionViewSpacing*4+collectionViewHeight*3, [CBRatio widthRatio:97] - itemSizeSpacing*2, collectionViewHeight)];
        _keyboardDown.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        [_keyboardDown setImage:[UIImage imageNamed:@"Resources.bundle/keyboardDown.png"] forState:UIControlStateNormal];
        [_keyboardDown addTarget:self action:@selector(keyboardDownClick) forControlEvents:UIControlEventTouchUpInside];
        _keyboardDown.layer.cornerRadius = 4;
        _keyboardDown.layer.masksToBounds = YES;
    }
    return _keyboardDown;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        cb_frame = frame;
        self.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        [self InitializeProperty];
        [self initLetterKeyboardView];
    }
    return self;
}
#pragma mark --初始化
- (void)InitializeProperty{
    
    viewWidth = cb_frame.size.width;
    viewHeight = cb_frame.size.height;
    collectionViewSpacing = [CBRatio heightRation:10];
    collectionViewHeight = [CBRatio heightRation:42];
    itemSizeSpacing = [CBRatio widthRatio:5];
    self.inputString = @"";
    symbolOneArray = @[@"[",@"]",@"{",@"}",@"#",@"%",@"^",@"*",@"+",@"="];
    symbolTwoArray = @[@"_",@"\\",@"|",@"~",@"<",@">",@"'",@"\"",@"`"];
    symbolThreeArray = @[@".",@",",@"?",@"!",@"-",@"/",@":"];
    symbolFourArray = @[@"&",@"(",@")",@"$",@";",@"@"];
}
- (void)initLetterKeyboardView{
    [self addSubview:self.symbolOneCollectionView];
    [self addSubview:self.symbolTwoCollectionView];
    [self addSubview:self.symbolThreeCollectionView];
    [self addSubview:self.symbolFourCollectionView];
    [self addSubview:self.letterBtn];
    [self addSubview:self.deleteBtn];
    [self addSubview:self.swithNumberBtn];
    [self addSubview:self.characterBtn];
    [self addSubview:self.keyboardDown];
}

#pragma mark ---UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.symbolOneCollectionView){
        return symbolOneArray.count;
    }else if (collectionView == self.symbolTwoCollectionView){
        return symbolTwoArray.count;
    }else if (collectionView == self.symbolThreeCollectionView){
        return symbolThreeArray.count;
    }else {
        return symbolFourArray.count;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CBLetterCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CBLetterCCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.layer.cornerRadius = 4;
    cell.layer.masksToBounds = YES;
    if (collectionView == self.symbolOneCollectionView){
        [cell initCell:indexPath.row wihtDataSource:symbolOneArray];
    }else if (collectionView == self.symbolTwoCollectionView){
        [cell initCell:indexPath.row wihtDataSource:symbolTwoArray];
    }else if (collectionView == self.symbolThreeCollectionView){
        [cell initCell:indexPath.row wihtDataSource:symbolThreeArray];
    }else {
        [cell initCell:indexPath.row wihtDataSource:symbolFourArray];
    }
    return cell;
    
    
}

#pragma mark ---UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.symbolOneCollectionView){
        self.inputString = symbolOneArray[indexPath.row];
    }else if (collectionView == self.symbolTwoCollectionView){
        self.inputString = symbolTwoArray[indexPath.row];
    }else if (collectionView == self.symbolThreeCollectionView){
        self.inputString = symbolThreeArray[indexPath.row];
    }else {
        self.inputString = symbolFourArray[indexPath.row];
    }
    self.myBlock(OUTPUTSTRING,self.inputString);
}

#pragma mark ---UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemSizeSpacing;
}

#pragma mark ----btnClick  切换数字键盘
- (void)swithNumberBtnClick{
    if (self.myBlock != nil){
        self.myBlock(SWITHNUMORLETTER,nil);
    }
    
}
#pragma mark ----btnClick  切换字母键盘
- (void)letterBtnClick:(UIButton *)sender{
    if (self.myBlock != nil){
        self.myBlock(LETTER,nil);
    }
    
}
- (void)keyboardDownClick{
    if (self.myBlock != nil){
        self.myBlock(KEYBOARDDOWN,nil);
    }
    
}
- (void)deleteBtnClick{
    if (self.myBlock != nil){
        self.myBlock(DELETE,nil);
    }
    
}

@end

#pragma mark 字母数字符号 cell
@implementation CBLetterCCell

-(UILabel *)lab{
    if (!_lab){
        _lab = [[UILabel alloc] init];
        _lab.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _lab.textColor = [UIColor blackColor];
        _lab.font = [UIFont systemFontOfSize:16];
        _lab.textAlignment = NSTextAlignmentCenter;
    }
    return _lab;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)initCell:(NSInteger)index wihtDataSource:(NSArray<NSString*>*)data{
    [self addSubview:self.lab];
    _lab.text = data[index];
    
}
@end



