//
//  TBPaymentView.h
//  TongBao
//
//  Created by apple on 16/5/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completeHandle)(NSString *inputPwd);

@interface TBPaymentView : UIView
/**
 *  金额
 */
@property (nonatomic, assign) float amount;

/**
 *  输入密码完成回调
 */
@property (nonatomic, copy) completeHandle block;
- (void)completeHandle:(completeHandle)block;
/**
 *  显示支付密码弹窗
 */
- (void)show;

@end
