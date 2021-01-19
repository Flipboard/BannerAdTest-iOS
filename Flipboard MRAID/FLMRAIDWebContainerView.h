//
//  FLMRAIDWebContainerView.h
//  Flipboard
//
//  Created by Troy Brant on 2/24/18.
//  Copyright © 2018 Flipboard. All rights reserved.
//

typedef NS_ENUM(NSUInteger, FLMRAIDState) {
    FLMRAIDStateLoading,
    FLMRAIDStateFailedToLoad,
    FLMRAIDStateDefault,
    FLMRAIDStateExpanded
};

@class FLMRAIDItem;
@protocol FLMRAIDWebContainerViewDelegate;

@interface FLMRAIDWebContainerView : FLView

@property (nonatomic, strong) FLMRAIDItem *item;
@property (nonatomic, assign, readonly) FLMRAIDState state;
@property (nonatomic, weak) NSObject<FLMRAIDWebContainerViewDelegate> *delegate;

// Manual control of viewability changes in a scrolling context
@property (nonatomic, assign, getter=isViewableOverride) BOOL viewableOverride;

// Disable web scrollview gesture correction (defaults to YES)
@property (nonatomic, assign) BOOL disableWebGestureCorrection;

// Expanded state support
@property (nonatomic, copy) FLVoidBlock onExpand;
@property (nonatomic, copy) FLVoidBlock onCloseExpandedState;
- (BOOL)shouldShowExpandedStateCustomCloseButton;
- (void)closeExpandedState;
- (void)tryUpdateOMSDKSessionViewability;

// Preload support
@property (nonatomic, readonly) BOOL isLoaded;
- (void)tryPreload;

@end

@protocol FLMRAIDWebContainerViewDelegate
@optional
- (void)mraidContainerView:(FLMRAIDWebContainerView *)containerView didOpenURL:(NSURL *)url;
@end
