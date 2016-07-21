//
//  NSComboBox+RACSignalSupport.m
//  AppResearchRAC
//
//  Created by Jason Liang on 7/19/16.
//  Copyright © 2016 _company_ All rights reserved.
//

#import <ReactiveCocoa/NSObject+RACDeallocating.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Result/Result.h>
#import <objc/runtime.h>
#import "NSComboBox+RACSignalSupport.h"

@implementation NSComboBox (RACSignalSupport)

static void RACUseDelegateProxy(NSComboBox *self) {
  if (self.delegate == self.rac_delegateProxy) return;

  self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
  self.delegate = (id)self.rac_delegateProxy;
}

- (RACDelegateProxy *)rac_delegateProxy {
  RACDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
  if (proxy == nil) {
    proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(NSComboBoxDelegate)];
    objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  return proxy;
}

- (RACSignal *)rac_selectionChangeSignal {
  RACSignal *signal = [[[self.rac_delegateProxy signalForSelector:@selector(comboBoxWillDismiss:)]
      reduceEach:^(NSNotification *notification) {
        return [NSNumber numberWithInteger:[self indexOfSelectedItem]];
        //            return notification;
      }] takeUntil:self.rac_willDeallocSignal];
  // setNameWithFormat:@"%@ -rac_buttonClickedSignal", RACDescription(self)];

  RACUseDelegateProxy(self);

  return signal;
}

//- (RACSignal *)rac_willDismissSignal {
//  RACSignal *signal =
//      [[[self.rac_delegateProxy
//      signalForSelector:@selector(alertView:willDismissWithButtonIndex:)]
//          reduceEach:^(UIAlertView *alertView, NSNumber *buttonIndex) {
//            return buttonIndex;
//          }] takeUntil:self.rac_willDeallocSignal];
////          setNameWithFormat:@"%@ -rac_willDismissSignal", RACDescription(self)];
//
//  RACUseDelegateProxy(self);
//
//  return signal;
//}

@end
