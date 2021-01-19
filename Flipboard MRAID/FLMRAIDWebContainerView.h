//
//  FLMRAIDWebContainerView.h
//  Flipboard
//
//  Created by Troy Brant on 2/24/18.
//  Copyright © 2018 Flipboard. All rights reserved.
//

@import UIKit;

typedef void (^FLVoidBlock)(void);

typedef NS_ENUM(NSUInteger, FLMRAIDState) {
    FLMRAIDStateLoading,
    FLMRAIDStateFailedToLoad,
    FLMRAIDStateDefault,
    FLMRAIDStateExpanded
};

extern NSString *const kFLMRAIDAdPageDidLoad;

@protocol FLMRAIDWebContainerViewDelegate;

@interface FLMRAIDWebContainerView : UIView

@property (nonatomic, strong) NSString *adHTMLString;
@property (nonatomic, assign, readonly) FLMRAIDState state;

// Manual control of viewability changes in a scrolling context
@property (nonatomic, assign, getter=isViewableOverride) BOOL viewableOverride;

// Expanded state support
@property (nonatomic, copy) FLVoidBlock onExpand;
@property (nonatomic, copy) FLVoidBlock onCloseExpandedState;
- (BOOL)shouldShowExpandedStateCustomCloseButton;
- (void)closeExpandedState;

// Preload support
@property (nonatomic, readonly) BOOL isLoaded;
- (void)tryPreload;

@end

@protocol FLMRAIDWebContainerViewDelegate
@optional
- (void)mraidContainerView:(FLMRAIDWebContainerView *)containerView didOpenURL:(NSURL *)url;
@end
