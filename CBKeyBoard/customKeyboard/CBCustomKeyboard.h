//
//  CBCustomKeyboard.h
//  莱付
//
//  Created by 炳神 on 2018/4/20.
//  Copyright © 2018年 clearning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SWITHNUMORLETTER, //切换数字 字母
    DELETE, //删除
    SYMBOL, //符号
    LETTER, //字母
    OUTPUTSTRING, //输出
    KEYBOARDDOWN, //键盘消失
} KEYBOARDCLICKSTATUS;



@class CBCustomLetterKeyboard;
@class CBCustomSymbolKeyboard;
typedef void(^KeyBoardBlock)(KEYBOARDCLICKSTATUS status,NSString *text);
@interface CBCustomKeyboard : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView *numberCollection; //数字CollectionView
@property (nonatomic,strong)UIButton *deleteBtn; //删除按钮
@property (nonatomic,strong)UIButton *keyboardDown; //键盘隐藏按钮
@property (nonatomic,strong)NSString *inputString; //输出的字符串
@property (nonatomic,strong)CBCustomLetterKeyboard *LetterKeyboard;
@property (nonatomic,strong)CBCustomSymbolKeyboard *SymbolKeyboard;
@property(copy,nonatomic)KeyBoardBlock myBlock;

@property (nonatomic,strong)NSString *mark; //标示
@property (nonatomic,assign)BOOL isPoint; //是否有小数点（有小数点 默认隐藏字母和符号）
-(instancetype)initWithFrame:(CGRect)frame;
@end



@interface CBCustomLetterKeyboard : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *qpCollectionView;//1-p
@property (nonatomic,strong) UICollectionView *alCollectionView;//a-l
@property (nonatomic,strong) UICollectionView *zmCollectionView;//z-m
//@property (nonatomic,strong) UICollectionView *symbolCollectionView;//&-@
@property (nonatomic,strong) UIButton *bigSmallBtn; //大小写按钮
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIButton *swithNumberBtn;
@property (nonatomic,strong) UIButton *keyboardDown;
@property (nonatomic,strong) UIButton *characterBtn; //字符按钮
@property (nonatomic,strong) UIButton *safeKeyboardTipBtn; //安全键盘按钮
@property (nonatomic,copy) NSString *inputString;
@property(copy,nonatomic)KeyBoardBlock myBlock;
- (instancetype)initWithFrame:(CGRect)frame;
@end


@interface CBCustomSymbolKeyboard : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *symbolOneCollectionView;//[  =
@property (nonatomic,strong) UICollectionView *symbolTwoCollectionView;//_  `
@property (nonatomic,strong) UICollectionView *symbolThreeCollectionView;//.  :
@property (nonatomic,strong) UICollectionView *symbolFourCollectionView;//&  @
@property (nonatomic,strong) UIButton *letterBtn; //字母按钮
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIButton *swithNumberBtn;
@property (nonatomic,strong) UIButton *keyboardDown;
@property (nonatomic,strong) UIButton *characterBtn;
@property (nonatomic,copy) NSString *inputString;
@property(copy,nonatomic)KeyBoardBlock myBlock;
- (instancetype)initWithFrame:(CGRect)frame;
@end


@interface CBLetterCCell : UICollectionViewCell
@property(nonatomic,strong)UILabel *lab;
- (void) initCell:(NSInteger)index wihtDataSource:(NSArray<NSString*>*)data;
@end




@interface CBRatio:NSObject
+ (CGFloat)widthRatio:(CGFloat)width;
+ (CGFloat)heightRation:(CGFloat)height;
@end





