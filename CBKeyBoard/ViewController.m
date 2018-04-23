//
//  ViewController.m
//  CBKeyBoard
//
//  Created by 炳神 on 2018/4/23.
//  Copyright © 2018年 CBcc. All rights reserved.
//

#import "ViewController.h"
#import "CBCustomKeyboard.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ViewController ()
@property (nonatomic,strong)CBCustomKeyboard *numberKeyboard;
@end

@implementation ViewController
- (CBCustomKeyboard *)numberKeyboard{
    if (!_numberKeyboard){
        _numberKeyboard = [[CBCustomKeyboard alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SCREEN_HEIGHT / 667 * 216, SCREEN_WIDTH, SCREEN_HEIGHT / 667 * 216)];
    }
    return _numberKeyboard;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 200, 30)];
    textFiled.backgroundColor = [UIColor redColor];
    textFiled.inputView = self.numberKeyboard;
    [self.view addSubview:textFiled];
    
    self.numberKeyboard.myBlock = ^(KEYBOARDCLICKSTATUS status,NSString *text) {
        switch (status) {
            case KEYBOARDDOWN: //键盘收起
                [textFiled resignFirstResponder];
                break;
            case OUTPUTSTRING: //输出
                textFiled.text = text;
                break;
            default:
                break;
        }
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
