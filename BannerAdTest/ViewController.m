//  Copyright (c) 2014 Google. All rights reserved.

@import GoogleMobileAds;

#import "ViewController.h"
#import "SettingsViewController.h"
#import "Settings.h"
#import <WebKit/WebKit.h>
#import "FLMRAIDWebContainerView.h"

@interface ViewController () <DFPBannerAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate, GADAppEventDelegate>

// Google Ads
@property (nonatomic, strong) GADAdLoader *loader;
@property (nonatomic, strong) GADNativeCustomTemplateAd *customTemplateAd;

// Ad views
@property (nonatomic, strong) UIView *currentAdView;
@property (nonatomic, strong) DFPBannerView *googleBannerView;
@property (nonatomic, strong) FLMRAIDWebContainerView *flipboardMRAIDView;

// Layout
@property (nonatomic, assign) BOOL adWantsFullscreen;
@property (nonatomic, strong) UIView *detachedParentView;

// Timing
@property (nonatomic, assign) BOOL adIsPreloading;
@property (nonatomic, assign) BOOL adIsFinishedPreloading;

// Debug UI
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UILabel *activityLabel;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *actionBarButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *resetBarButton;

@end

@implementation ViewController

#pragma mark - UI

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self reset];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Don't show the status bar.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)updateUI
{
    // Update spinner
    [self updateSpinner];
    
    // Update the toolbar
    [self updateToolbar];
}

- (void)updateSpinner
{
    // No Ad
    if ([self canFetchAd]) {
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
        self.activityLabel.text = @"No Ad";
    }
    // Fetching
    if ([self isFetchingAd]) {
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
        self.activityLabel.text = @"Fetching";
    }
    // Preloading
    else if ([self isPreloadingAd]) {
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
        self.activityLabel.text = @"Preloading";
    }
    // Ready
    else if ([self canPresentAd]) {
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
        self.activityLabel.text = @"Ready";
    }
}

- (void)updateToolbar
{
    // Reset button
    self.resetBarButton.enabled = [self canReset];
    
    // Fetch button
    if ([self canFetchAd]) {
        self.actionBarButton.title = @"Fetch";
        self.actionBarButton.enabled = YES;
    }
    // Present button
    else if ([self canPresentAd]) {
        self.actionBarButton.title = @"Present";
        self.actionBarButton.enabled = YES;
    }
    // None
    else {
        self.actionBarButton.enabled = NO;
    }
}

- (IBAction)resetTapped:(UIBarButtonItem *)sender
{
    [self reset];
}

- (IBAction)actionTapped:(UIBarButtonItem *)sender
{
    // Fetch
    if ([self canFetchAd]) {
        [self tryFetchAd];
    }
    // Present
    else if ([self canPresentAd]) {
        [self layoutAdView];
    }
    
    // Update the UI.
    [self updateUI];
}

#pragma mark - Flow

- (void)reset
{
    NSLog(@"$$$$$ Resetting");
    
    // Destroy the loader
    self.loader = nil;
    
    // Destroy the ad view
    [self destroyAdView];
    
    // Reset flags
    self.adWantsFullscreen = NO;
    self.adIsPreloading = NO;
    self.adIsFinishedPreloading = NO;
    
    // Update the UI
    [self updateUI];
    
    // Log an empty line for readability
    NSLog(@"$$$$$");
}

- (void)tryFetchAd
{
    if (![self canFetchAd]) {
        return;
    }
    
    NSLog(@"$$$$$ Fetching ad");
    
    // Unit ID
    NSString *unitID = Settings.shared.unitID;
    
    // Banner and native types (unified request)
    NSArray *adTypes = @[kGADAdLoaderAdTypeDFPBanner, kGADAdLoaderAdTypeUnifiedNative];
    
    // Create the request
    DFPRequest *request = [DFPRequest request];
    
    // Test mode
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[kGADSimulatorID];
    
    // Create the loader
    self.loader = [[GADAdLoader alloc] initWithAdUnitID:unitID rootViewController:self adTypes:adTypes options:nil];
    self.loader.delegate = self;
    
    // Load the request
    [self.loader loadRequest:request];
}

- (void)loadingAndPreloadingDidFinish
{
    NSLog(@"$$$$$ Loading/preloading finished");
    
    // Update state
    self.adIsPreloading = NO;
    self.adIsFinishedPreloading = YES;
    
    // Hide after preloading?
    if (Settings.shared.hideAfterPreloading) {
        NSLog(@"$$$$$ Hiding ad view");
        self.currentAdView.hidden = YES;
    }
    
    // Remove from hierarchy after preloading?
    if (Settings.shared.removeFromParentAfterPreloading) {
        NSLog(@"$$$$$ Removing ad view from parent");
        [self.currentAdView removeFromSuperview];
    }
    
    // Auto-present?
    if (Settings.shared.autoPresent) {
        // Layout
        [self layoutAdView];
    }
    
    // Update the UI
    [self updateUI];
}

#pragma mark - Google Delegate Methods

- (NSArray<NSValue *> *)validBannerSizesForAdLoader:(GADAdLoader *)adLoader
{
    NSLog(@"$$$$$ validBannerSizesForAdLoader:");
    
    return @[
        NSValueFromGADAdSize(GADAdSizeFromCGSize(CGSizeMake(300, 600))),
        NSValueFromGADAdSize(GADAdSizeFromCGSize(CGSizeMake(300, 250))),
        NSValueFromGADAdSize(GADAdSizeFromCGSize(CGSizeMake(1, 1))) // Fullscreen
    ];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveDFPBannerView:(DFPBannerView *)bannerView
{
    NSLog(@"$$$$$ adLoader:didReceiveDFPBannerView:");
    
    // Abandon the ad if the fetch has been cancelled
    if (!self.loader) {
        return;
    }
    
    // Grab the banner
    self.googleBannerView = bannerView;
    self.currentAdView = bannerView;
    
    // If the banner is 1x1 it's fullscreen
    // This is a convention suggested by Google
    self.adWantsFullscreen = CGSizeEqualToSize(self.googleBannerView.frame.size, CGSizeMake(1.0, 1.0));
    
    // Register as the banner's event delegate
    self.googleBannerView.appEventDelegate = self;
    
    // Register for manual impressions if desired
    if (Settings.shared.manualImpressions) {
        self.googleBannerView.enableManualImpressions = YES;
    }
    
    // Update the UI
    [self updateUI];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd
{
    NSLog(@"$$$$$ adLoader:didReceiveUnifiedNativeAd:");
    
    // Do nothing because we don't support native ads in this test app yet
    
    // Update the UI
    [self updateUI];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error
{
    // Log the error
    NSLog(@"$$$$$ adLoader:didFailToReceiveAdWithError: %@", error);
    
    // Update the UI
    [self updateUI];
}

- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader
{
    NSLog(@"$$$$$ adLoaderDidFinishLoading:");
    
    // Abort if the fetch was cancelled or no ad view arrived
    if (!self.loader || !self.currentAdView) {
        [self reset];
        return;
    }
    
    // Get rid of the loader
    self.loader = nil;
    
    // Resize
    // IMPORTANT: Do this as early as possible.  Ad views won't load properly when they're 1x1.
    [self resizeAdView];
    
    // PRELOADING HACK
    // Web views won't preload unless they're attached to a window
    if (Settings.shared.preload) {
        // Logging
        NSLog(@"$$$$$ Using preloading hack");
        NSLog(@"$$$$$ Adding ad view to main window");
        
        // Two possible parent views for the preloading ad view:
        // 1. A view that isn't part of the hierarchy (suggested by Google)
        // 2. The app's main window
        if (Settings.shared.preloadInDetachedParentView) {
            // Add the ad view to the detached view so it can preload
            [self.detachedParentView addSubview:self.currentAdView];
        } else {
            // Add the ad view to the main window so it can preload
            [self.mainWindow insertSubview:self.currentAdView atIndex:0];
        }
        
        // Optionally move the ad view outside of the screen frame
        if (Settings.shared.preloadOffscreen) {
            NSLog(@"$$$$$ Moving ad view outside of screen bounds");
            CGRect offscreenAdViewFrame = self.currentAdView.frame;
            offscreenAdViewFrame.origin.x += UIScreen.mainScreen.bounds.size.width;
            self.currentAdView.frame = offscreenAdViewFrame;
        }
        
        // Track the state
        self.adIsPreloading = YES;
        
        // Preload for a constant amount of time if we're not waiting for a completion event
        if (Settings.shared.preload && !Settings.shared.waitForPreloadingCompletionEvent) {
            // Wait a specified amount of time for preloading to complete
            NSTimeInterval kPreloadingTime = 5.0;
            [self performSelector:@selector(loadingAndPreloadingDidFinish) withObject:nil afterDelay:kPreloadingTime];
        }
    }
    // NO PRELOADING HACK
    // Show ad view immediately after it's received
    else {
        // Logging
        NSLog(@"$$$$$ Not using preloading hack");
        
        // Skip preloading
        [self loadingAndPreloadingDidFinish];
    }
    
    // Update the UI
    [self updateUI];
}

- (void)adView:(GADBannerView *)banner didReceiveAppEvent:(NSString *)name withInfo:(nullable NSString *)info
{
    NSLog(@"$$$$$ adView:didReceiveAppEvent:%@ withInfo:%@", name, info);
    
    static NSString *kCeltraLoadedEventName = @"celtraLoaded";
    if ([name isEqual:kCeltraLoadedEventName]) {
        if (Settings.shared.preload && Settings.shared.waitForPreloadingCompletionEvent) {
            [self loadingAndPreloadingDidFinish];
        }
    }
}

#pragma mark - Layout

- (UIWindow *)mainWindow
{
    return [[[UIApplication sharedApplication] delegate] window];
}

- (UIView *)detachedParentView
{
    if (!_detachedParentView) {
        _detachedParentView = [[UIView alloc] init];
        _detachedParentView.frame = UIScreen.mainScreen.bounds;
        
        // Intentionally don't add to the view hierarchy
    }
    return _detachedParentView;
}

- (CGRect)fullscreenFrame
{
    // Fullscreen frame
    CGRect fullscreenFrame = self.view.bounds;
    
    // Safe area insets
    if (@available(iOS 11.0, *)) {
        fullscreenFrame = UIEdgeInsetsInsetRect(fullscreenFrame, self.mainWindow.safeAreaInsets);
    }
    
    // Bottom toolbar
    if (self.toolbar) {
        const CGFloat kBottomToolbarHeight = 44.0;
        fullscreenFrame.size.height -= kBottomToolbarHeight;
    }
    
    return fullscreenFrame;
}

- (void)resizeAdView
{
    NSLog(@"$$$$$ resizeAdView");
    
    // Fullscreen size if the ad wants it
    if (self.adWantsFullscreen) {
        // Google banner views must call the resize method before setting the frame
        if (self.googleBannerView) {
            NSLog(@"$$$$$ DFPBannerView resize method for fullscreen");
            [self.googleBannerView resize:GADAdSizeFromCGSize(self.fullscreenFrame.size)];
        }
        
        // Set the ad view's frame
        NSLog(@"$$$$$ Setting ad view frame to fullscreen");
        self.currentAdView.frame = self.fullscreenFrame;
    }
}

- (void)layoutAdView
{
    NSLog(@"$$$$$ layoutAdView");
    
    // Add the ad view as a subview if necessary
    if (![self hasAdSubview]) {
        NSLog(@"$$$$$ Adding ad view as subview");
        [self.view addSubview:self.currentAdView];
    }
    
    // Fullscreen ads take up most of the screen
    if (self.adWantsFullscreen) {
        NSLog(@"$$$$$ Expanding ad view to fullscreen frame");
        self.currentAdView.frame = self.fullscreenFrame;
    }
    // Non-fullscreen ads are centered, but not resized
    else {
        NSLog(@"$$$$$ Centering ad view");
        self.currentAdView.center = self.view.center;
    }
    
    // Show the ad view in case it was hidden
    self.currentAdView.hidden = NO;
    
    // The GMA SDK seems to think ads are visibile when they're not.
    // To work around this, inject javascript to tell the ad view that it's *actually* visible.
    // Wait until the next runloop to avoid timing issues.
    if (Settings.shared.injectVisibilityJavascript) {
        NSLog(@"$$$$$ Injecting banner visibility javascript");
        [self performSelector:@selector(setAdViewVisibilityJavascriptFlagToYes) withObject:nil afterDelay:0.0];
    }
    
    // Manual impressions if desired
    if (Settings.shared.manualImpressions) {
        NSLog(@"$$$$$ Firing manual impression");
        [self.googleBannerView recordImpression]; // Google banner
        [self.customTemplateAd recordImpression]; // Flipboard MRAID
    }
    
    // Update the UI.
    [self updateUI];
}

- (void)destroyAdView
{
    // Google banner
    if (self.googleBannerView) {
        NSLog(@"$$$$$ Destroying google banner view");
        [self.googleBannerView removeFromSuperview];
        self.googleBannerView = nil;
    }
    
    // Flipboard MRAID
    if (self.flipboardMRAIDView) {
        NSLog(@"$$$$$ Destroying flipboard mraid view");
        [self.flipboardMRAIDView removeFromSuperview];
        self.flipboardMRAIDView = nil;
    }
    
    // Clear current ad view
    self.currentAdView = nil;
}

- (BOOL)hasAdSubview
{
    return [self.view.subviews containsObject:self.currentAdView];
}

#pragma mark - Javascript Injection

- (void)setAdViewVisibilityJavascriptFlagToYes
{
    [self setAdViewVisibilityJavascriptFlag:YES];
}

 - (void)setAdViewVisibilityJavascriptFlag:(BOOL)visible
{
    NSString *javascriptString = [self adViewVisibilityJavascriptString:visible];
    
    UIView *webView = [self firstWebViewInView:self.currentAdView];
    [(WKWebView *)webView evaluateJavaScript:javascriptString completionHandler:nil];
}

- (UIView *)firstWebViewInView:(UIView *)rootView
{
    // Be safe.
    if (rootView == nil) {
        return nil;
    }
    
    // This is a breadth first search so maintain a queue of views to check.
    NSArray<UIView *> *views = @[rootView];
    
    // Subviews to check on the next iteration.
    NSMutableArray<UIView *> *subviews = [NSMutableArray array];
    
    // While there are still views to check.
    while (views.count > 0) {
        // Iterate over them.
        for (UIView *view in views) {
            // If the view is a WKWebView, return it.
            if ([view isKindOfClass:[WKWebView class]]) {
                return view;
            }
            // Otherwise, enqueue the view's subviews.
            else {
                [subviews addObjectsFromArray:view.subviews];
            }
        }
        
        // Set up the next iteration.
        views = subviews;
        subviews = [NSMutableArray array];
    }
    
    // Nothing found.
    return nil;
}

- (NSString *)adViewVisibilityJavascriptString:(BOOL)visible
{
    NSString *param = visible ? @"true" : @"false";
    NSString *javascriptString = [NSString stringWithFormat:@"if (typeof setFlipboardAdIsVisible === 'function') { setFlipboardAdIsVisible(%@); }", param];
    return javascriptString;
}

#pragma mark - State

- (BOOL)canReset
{
    return self.loader != nil || self.currentAdView != nil;
}

- (BOOL)canFetchAd
{
    return self.loader == nil && self.currentAdView == nil;
}

- (BOOL)isFetchingAd
{
    return self.loader != nil && self.currentAdView == nil;
}

- (BOOL)isPreloadingAd
{
    return self.adIsPreloading;
}

- (BOOL)canPresentAd
{
    return self.currentAdView != nil && ![self hasAdSubview] && ![self isPreloadingAd] && !Settings.shared.autoPresent;
}

@end
