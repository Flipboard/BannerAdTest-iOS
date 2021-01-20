//
//  FLMRAIDWebContainerView.m
//  Flipboard
//
//  Created by Troy Brant on 2/24/18.
//  Copyright © 2018 Flipboard. All rights reserved.
//

#import "FLMRAIDWebContainerView.h"
#import <WebKit/WebKit.h>

NSString *const kFLMRAIDScriptInclude = @"mraid.js";
NSString *const kFLMRAIDAdPageDidLoad = @"FLMRAIDAdDidLoadPage";

@interface FLMRAIDWebContainerView () <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign, readwrite) FLMRAIDState state;
@property (nonatomic, strong) NSMutableArray *webViewScriptMessageQueue;
@property (nonatomic, assign) BOOL didSetPageReady;
@property (nonatomic, assign) BOOL viewable;
@property (nonatomic, assign) BOOL useCustomCloseButtonForExpandedState;

@end

@implementation FLMRAIDWebContainerView

- (void)setState:(FLMRAIDState)state
{
    if (_state != state) {
        _state = state;
        [self trySetPageReady];
    }
}

- (void)setViewable:(BOOL)viewable
{
    if (_viewable != viewable) {
        _viewable = viewable;
        [self fireViewableChangeEventInWebview:[self isViewable]];
    }
}

- (void)setViewableOverride:(BOOL)viewableOverride
{
    if (_viewableOverride != viewableOverride) {
        _viewableOverride = viewableOverride;
        [self fireViewableChangeEventInWebview:_viewableOverride];
    }
}

- (void)dealloc
{
    // Stop script messaging to prevent webview leak
    [self removeWebViewScriptHandler];
}

#pragma mark Preloading

- (BOOL)isPreloading
{
    // FLMRAIDCache attaches preloading views as a direct child of UIAppMainWindow.
    UIWindow *mainWindow = UIApplication.sharedApplication.delegate.window;
    BOOL isPreloading = (self.superview == mainWindow);
    return isPreloading;
}

- (void)tryPreload
{
    // Not if it's already loading
    BOOL shouldPreload = self.webView == nil;
    
    // Only if there's valid HTML
    if (shouldPreload) {
        shouldPreload = self.adHTMLString.length > 0;
    }
    
    if (shouldPreload) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        config.userContentController = userContentController;
        config.allowsInlineMediaPlayback = YES;
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        
        self.webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.allowsLinkPreview = NO;
        self.webView.opaque = YES;
        self.webView.backgroundColor = [self loadingBackgroundColor];
        [self addWebViewScriptHandler];
        [self addSubview:self.webView];
        
        // Hide webview until page load so we can fade it in.
        self.webView.alpha = 0.0;
        
        // Start loading MRAID HTML
        NSString *html = [self htmlToLoad];
        NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
        [self.webView loadHTMLString:html baseURL:baseURL];
    }
}

- (NSString *)cssToLoad
{
    // Inject some reset styles with our loading background color, and ad size.
    static NSString *const kFLMRAIDWrapperCSSFormat = @"<style>html, body { margin: 0; padding: 0; background: #%@; width: %fpx; height: %fpx; }</style>";
    NSString *backgroundColorHex = @"000000";
    NSString *css = [NSString stringWithFormat:kFLMRAIDWrapperCSSFormat, backgroundColorHex, self.adPreferredSize.width, self.adPreferredSize.height];
    return css;
}

- (NSString *)scriptTagToLoad
{
    // Not all ads include mraid.js, even though they use the mraid APIs.
    // Avoid double-including mraid.js by checking for its existence in the ad.
    NSString *scriptTag = @"";
    BOOL shouldIncludeMRAID = [self.adHTMLString rangeOfString:kFLMRAIDScriptInclude].location == NSNotFound;
    if (shouldIncludeMRAID) {
        scriptTag = [NSString stringWithFormat:@"<script src='%@'></script>", kFLMRAIDScriptInclude];
    }
    return scriptTag;
}

- (NSString *)htmlToLoad
{
    // Wrap so we can both inject mraid.js and set meta viewport values to ensure ad sized correctly.
    static NSString *const kFLMRAIDWrapperHTMLFormat = @"<!DOCTYPE html><html><head><meta name='viewport' content='width=device-width, user-scalable=0' />%@%@</head><body><div id='root'>%@</div></body></html>";
    NSString *css = [self cssToLoad];
    NSString *scriptTag = [self scriptTagToLoad];
    NSString *html = [NSString stringWithFormat:kFLMRAIDWrapperHTMLFormat, css, scriptTag, self.adHTMLString];
    
    return html;
}

#pragma mark - UIView

- (UIColor *)loadingBackgroundColor
{
    return [UIColor blackColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Loading background color
    self.backgroundColor = [self loadingBackgroundColor];
    
    // Web view
    self.webView.frame = self.bounds;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window) {
        // Load webview once we are visible.
        [self tryPreload];
    }
    
    // Fire page ready if ready to show
    [self trySetPageReady];
    
    // Update viewability
    self.viewable = [self isViewable];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    // Update viewability
    self.viewable = [self isViewable];
}

static NSString *const kFLMScriptHandlerName = @"FlipboardMRAIDBridge";

- (void)addWebViewScriptHandler
{
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:kFLMScriptHandlerName];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:kFLMScriptHandlerName];
}

- (void)removeWebViewScriptHandler
{
    // Important! If we don't call this, we leak web views.
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:kFLMScriptHandlerName];
}

- (void)hideGraySelectionOverlay
{
    // FIXME: (TB) Figure out why this doesn't work

    // Disable gray overlay on touch down
    // Pulled from https://stackoverflow.com/questions/44026550/how-can-i-disable-the-automatic-gray-selection-in-wkwebview?rq=1
    static NSString *const kFLDisableGraySelectionScript = @"\
    function addStyleString(str) { \
        var node = document.createElement('style'); \
        node.innerHTML = str; \
        document.body.appendChild(node); \
    } \
    addStyleString('* {-webkit-tap-highlight-color: rgba(0,0,0,0);}'); \
    ";
    [self evaluateJavaScript:kFLDisableGraySelectionScript completionHandler:nil];
}

- (BOOL)shouldShowExpandedStateCustomCloseButton
{
    // Only if clients want it shown
    BOOL showCustomClose = self.useCustomCloseButtonForExpandedState;
    
    // Only in expanded state
    if (showCustomClose) {
        showCustomClose = self.state == FLMRAIDStateExpanded;
    }
    return showCustomClose;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    self.state = FLMRAIDStateFailedToLoad;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    self.state = FLMRAIDStateFailedToLoad;
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    self.state = FLMRAIDStateFailedToLoad;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // Update webview ad state
    self.state = FLMRAIDStateDefault;
    
    // Flush any pending web scripts
    [self tryFlushWebViewScriptMessages];

    // Fade in webview on page load
    static const NSTimeInterval kFLMRAIDWebViewFadeDuration = 0.4;
    [UIView animateWithDuration:kFLMRAIDWebViewFadeDuration animations:^{
        self.webView.alpha = 1.0;
    }];
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    // Handle target=_blank links, open in external browser
    if (!navigationAction.targetFrame.isMainFrame) {
        [self openURL:navigationAction.request.URL];
    }
    return nil;
}

#pragma mark - Webview Bridge

- (void)enqueueWebViewScriptMessage:(NSString *)script
{
    // Initialize queue if doesn't exist
    if (!self.webViewScriptMessageQueue) {
        self.webViewScriptMessageQueue = [NSMutableArray array];
    }
    
    // Queue it up
    if (script) {
        [self.webViewScriptMessageQueue addObject:script];
    }
}

- (void)tryFlushWebViewScriptMessages
{
    if (self.webViewScriptMessageQueue.count > 0) {
        // Eval in the original order they were enqueued
        __weak FLMRAIDWebContainerView *weakSelf = self;
        NSString *message = [self.webViewScriptMessageQueue firstObject];
        [self evaluateJavaScript:message completionHandler:^(id result, NSError * _Nullable error) {
            // Shift the front of the queue, and flush next or stop
            if (weakSelf.webViewScriptMessageQueue.count > 0) {
                [weakSelf.webViewScriptMessageQueue removeObjectAtIndex:0];
            }
            if (weakSelf.webViewScriptMessageQueue.count > 0) {
                [weakSelf tryFlushWebViewScriptMessages];
            } else {
                weakSelf.webViewScriptMessageQueue = nil;
            }
        }];
    }
}

- (void)evaluateJavaScript:(NSString *)script completionHandler:(void (^)(id, NSError *error))completionHandler
{
    // Make sure the webview is ready to eval script
    if ([self isLoaded]) {
        [self.webView evaluateJavaScript:script completionHandler:completionHandler];
    } else {
        // Enqueue script to be eval'ed on page load
        [self enqueueWebViewScriptMessage:script];
    }
}

- (void)setLogLevelInWebview
{
    NSString *logLevel = @"DEBUG";
    NSString *script = [NSString stringWithFormat:@"mraid.logLevel = mraid.LogLevelEnum.%@", logLevel];
    [self evaluateJavaScript:script completionHandler:nil];
}

- (void)setScreenSizeInWebview
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NSString *script = [NSString stringWithFormat:@"mraid.setScreenSize(%@, %@)", @(frame.size.width), @(frame.size.height)];
    [self evaluateJavaScript:script completionHandler:nil];
}

- (void)setCurrentPositionInWebview
{
    CGRect frame = [self frameInWindowCoords];
    NSString *script = [NSString stringWithFormat:@"mraid.setCurrentPosition(%@, %@, %@, %@)", @(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
    [self evaluateJavaScript:script completionHandler:nil];
}

- (void)setDefaultPositionInWebview
{
    CGRect frame = [self frameInWindowCoords];
    NSString *script = [NSString stringWithFormat:@"mraid.setDefaultPosition(%@, %@, %@, %@)", @(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
    [self evaluateJavaScript:script completionHandler:nil];
}

- (void)setPlacementTypeInWebview
{
    // We don't support interstitial yet, so set to inline for now.
    NSString *script = [NSString stringWithFormat:@"mraid.setPlacementType('inline')"];
    [self evaluateJavaScript:script completionHandler:nil];
}

- (void)setNativeSupportedFeaturesInWebview
{
    // None for now
    // Android currently supports SMS and Phone #s, we'll have parity eventually
}

- (void)fireReadyEventInWebview
{
    NSString *script = [NSString stringWithFormat:@"mraid.fireReadyEvent()"];
    [self evaluateJavaScript:script completionHandler:nil];
}

- (void)fireStateChangeEventInWebview
{
    NSString *state = [self mraidStateForWebview];
    NSString *script = [NSString stringWithFormat:@"mraid.fireStateChangeEvent('%@')", state];
    [self evaluateJavaScript:script completionHandler:nil];
}

- (void)fireViewableChangeEventInWebview:(BOOL)isViewable
{
    NSString *isViewableString = isViewable ? @"true" : @"false";
    NSString *script = [NSString stringWithFormat:@"mraid.fireViewableChangeEvent(%@)", isViewableString];
    [self evaluateJavaScript:script completionHandler:nil];
}

#pragma mark - Helpers

- (CGRect)frameInWindowCoords
{
    CGRect frame = self.bounds;
    if (self.window) {
        frame = [self convertRect:self.bounds toView:self.window];
    }
    return frame;
}

- (NSString *)mraidStateForWebview
{
    NSString *state = @"default";
    if (self.state == FLMRAIDStateLoading) {
        state = @"loading";
    } else if (self.state == FLMRAIDStateExpanded) {
        state = @"expanded";
    }
    return state;
}

- (BOOL)isLoaded
{
    return self.state == FLMRAIDStateDefault || self.state == FLMRAIDStateExpanded;
}

- (BOOL)isViewable
{
    // Not when preloading
    // Preloading happens on the main app window, under the main UI (needed to get the WKWebView to render its contents)
    BOOL isPreloading = [self isPreloading];
    BOOL isViewable = !isPreloading;
    
    // Only when part of the view hierarchy
    if (isViewable) {
        isViewable = self.window != nil;
    }
    return isViewable;
}

- (void)trySetPageReady
{
    // Only once
    BOOL shouldSet = !self.didSetPageReady;
    
    // Only if MRAID ad has loaded
    if (shouldSet) {
        shouldSet = self.state == FLMRAIDStateDefault;
    }
    
    // Only if we've been laid out (so frames can be set)
    if (shouldSet) {
        shouldSet = self.frame.size.width > 0.0;
    }
    
    if (shouldSet) {
        // Initialize MRAID values
        [self setLogLevelInWebview];
        [self setPlacementTypeInWebview];
        [self setNativeSupportedFeaturesInWebview];
        [self fireStateChangeEventInWebview];
        [self fireReadyEventInWebview];
        [self setScreenSizeInWebview];
        [self setCurrentPositionInWebview];
        [self setDefaultPositionInWebview];
        [self hideGraySelectionOverlay];
        
        self.didSetPageReady = YES;
        self.viewable = YES;
    }
}

- (void)openURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)expand
{
    // Update state
    self.state = FLMRAIDStateExpanded;
    
    // Expand
    if (self.onExpand) {
        self.onExpand();
    }
    
    // Tell webview
    [self setCurrentPositionInWebview];
    [self fireStateChangeEventInWebview];
}

- (void)closeExpandedState
{
    // Update state
    self.state = FLMRAIDStateDefault;
    
    // Close
    if (self.onCloseExpandedState) {
        self.onCloseExpandedState();
    }
    
    // Tell webview
    [self setCurrentPositionInWebview];
    [self fireStateChangeEventInWebview];
}

#pragma mark - WKScriptMessageHandler

// Note: all actions below correspond to messages broadcast from bundled mraid.js
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSString *messageText = [message.body isKindOfClass:[NSString class]] ? message.body : nil;
    NSArray<NSString *> *messageComponents = [messageText componentsSeparatedByString:@" "];
    NSString *action = messageComponents.count > 0 ? messageComponents[0] : nil;
    NSString *parameter = messageComponents.count > 1 ? messageComponents[1] : nil;
    
    // Ready to show
    if ([action isEqual:@"pageDidLoad"]) {
        // Ready to show
        self.state = FLMRAIDStateDefault;
        
        // Fire content ready notification so ad can be presented
        [[NSNotificationCenter defaultCenter] postNotificationName:kFLMRAIDAdPageDidLoad object:self userInfo:nil];
    }
    // Open events
    else if ([action hasPrefix:@"open"]) {
        NSURL *url = [NSURL URLWithString:parameter];
        [self openURL:url];
    }
    // Play video
    else if ([action hasPrefix:@"playVideo"]) {
        // TODO: Play natively
        NSURL *url = [NSURL URLWithString:parameter];
        [self openURL:url];
    }
    // Expand
    else if ([action hasPrefix:@"expand"]) {
        [self expand];
    }
    // Close
    else if ([action hasPrefix:@"close"]) {
        [self closeExpandedState];
    }
    // Custom close button for expanded views
    else if ([action hasPrefix:@"useCustomClose"]) {
        self.useCustomCloseButtonForExpandedState = [parameter isEqual:@"true"];
    }
    // Log events
    else if ([action hasPrefix:@"log"]) {
        NSLog(@"mraid %@", messageText);
    }
}

@end
