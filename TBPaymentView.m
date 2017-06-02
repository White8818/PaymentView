//
//  TBPaymentView.m
//  TongBao
//
//  Created by apple on 16/5/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "TBPaymentView.h"
#import "IQKeyboardManager.h"

#define PWD_COUNT 6
#define DefaultBottom (JFHeight - (JFWidth - 60) / 1.2) / 2

@interface TBPaymentView ()<UITextFieldDelegate>
{
    NSMutableArray *pwdIndicatorArr;//存储当前黑点label的显示个数
}
/**
 *  金额数label
 */
@property (weak, nonatomic) IBOutlet UILabel *moneyLab;
/**
 *  密码框背景图
 */
@property (weak, nonatomic) IBOutlet UIView *passwordView;
/**
 *  密码输入框
 */
@property (strong, nonatomic) UITextField *pwdTextField;

@property (nonatomic, strong) UIView *paymentView;

@end

@implementation TBPaymentView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpSubViews];
    }
    return self;
}
- (void)setUpSubViews {
    //设置背景色
    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.797];
    pwdIndicatorArr = [NSMutableArray array];
    //初始化密码框
    self.paymentView = [[NSBundle mainBundle] loadNibNamed:@"TBPaymentView" owner:self options:nil].firstObject;
    [self addSubview:_paymentView];
    [_paymentView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-DefaultBottom);
        make.left.offset(30);
        make.right.offset(-30);
        make.height.equalTo(_paymentView.width).multipliedBy(0.83);
    }];
    //设置密码框上的输入框的外观
    self.passwordView.layer.borderColor = [UIColor colorWithWhite:0.780 alpha:1.000].CGColor;
    self.passwordView.layer.borderWidth = 1;
    //创建textField
    self.pwdTextField = [[UITextField alloc] init];
    [self.passwordView addSubview:_pwdTextField];
    [_pwdTextField makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_passwordView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    _pwdTextField.hidden = YES;
    _pwdTextField.keyboardType = UIKeyboardTypeNumberPad;
    _pwdTextField.delegate = self;
    //创建黑点
    UILabel *lastLab = nil;
    for (int i = 0; i < PWD_COUNT; i++) {
        UILabel *dot = [UILabel new];
        [self.passwordView addSubview:dot];
        [dot makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.passwordView);
            make.width.equalTo(self.passwordView.height);
            if (lastLab) {
                make.left.equalTo(lastLab.right).offset(0);
            } else {
                make.left.offset(0);
            }
        }];
        lastLab = dot;
        dot.font = [UIFont systemFontOfSize:18 * TBScale];
        dot.textAlignment = NSTextAlignmentCenter;
        dot.text = @"●";
        //默认隐藏
        dot.hidden = YES;
        [pwdIndicatorArr addObject:dot];
        //画中间的分割线
        if (i == PWD_COUNT-1) {
            continue;
        }
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.];
        [self.passwordView addSubview:line];
        [line makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.passwordView);
            make.width.offset(.5);
            make.left.equalTo(dot.right).offset(0);;
        }];
    }
}
//设置金额数
- (void)setAmount:(float )amount {
    _amount = amount;
    self.moneyLab.text = [NSString stringWithFormat:@"¥%.2f", amount];
}
//展示
- (void)show {
    [IQKeyboardManager sharedManager].enable = NO;
    //监听键盘弹出和收起
    [kNotificationCenter addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    //注册键盘消失的通知
    [kNotificationCenter addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.frame = CGRectMake(0, 0, JFWidth, JFHeight);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    _paymentView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _paymentView.alpha = 0;
    
    [_pwdTextField becomeFirstResponder];
    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _paymentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _paymentView.alpha = 1.0;
    } completion:nil];
}
//点击取消按钮
- (IBAction)dismiss {
    [IQKeyboardManager sharedManager].enable = YES;
    [kNotificationCenter removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [kNotificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [kNotificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [_pwdTextField resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        _paymentView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
        _paymentView.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
//根据数组长度显示黑点
- (void)setDotWithCount:(NSInteger)count {
    for (UILabel *dot in pwdIndicatorArr) {
        dot.hidden = YES;
    }
    
    for (int i = 0; i< count; i++) {
        ((UILabel*)[pwdIndicatorArr objectAtIndex:i]).hidden = NO;
    }
}
- (void)completeHandle:(completeHandle)block {
    self.block = block;
}
- (IBAction)tapTextFieldAction:(UITapGestureRecognizer *)sender {
    [_pwdTextField becomeFirstResponder];
}
#pragma mark 键盘弹起和收缩
- (void)keyboardWasShown:(NSNotification*)aNotification {
    //键盘高度
    CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [_paymentView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-keyBoardFrame.size.height - 5);
    }];
}

-(void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [_paymentView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-DefaultBottom);
    }];
}
#pragma mark -- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.text.length >= PWD_COUNT && string.length) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        return NO;
    }
    if (string.length <= 0 && textField.text.length == 0) {
        //防止三方输入法, 在没有内容的情况下, 点按回退键, 造成crash
        return NO;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }
    NSString *totalString;
    if (string.length <= 0) {
        totalString = [textField.text substringToIndex:textField.text.length-1];
    }
    else {
        totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    [self setDotWithCount:totalString.length];
    
    if (totalString.length == 6) {
        if (self.block) {
            self.block(totalString);
        }
        [self dismiss];
        NSLog(@"complete----pwd---%@", totalString);
    }
    
    return YES;
}
@end
