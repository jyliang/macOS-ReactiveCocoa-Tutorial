//
//  NSComboBox+RACSignalSupport.h
//  AppResearchRAC
//
//  Created by Jason Liang on 7/19/16.
//  Copyright © 2016 _company_ All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RACDelegateProxy;
@class RACSignal;

@interface NSComboBox (RACSignalSupport)

@property(nonatomic, strong, readonly) RACDelegateProxy *rac_delegateProxy;

- (RACSignal *)rac_selectionChangeSignal;

@end
