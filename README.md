# CBKeyboard

Use:

UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 200, 30)];
textFiled.backgroundColor = [UIColor redColor];
textFiled.inputView = self.numberKeyboard;
[self.view addSubview:textFiled];
self.numberKeyboard.mark = @"xxx安全键盘";
self.numberKeyboard.isPoint = NO;  //设置yes  是有小数点的（但不包括字母和符号了）
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


