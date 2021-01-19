//
//  Settings.m
//  BannerAdTest
//
//  Created by Colin Caufield on 4/2/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import "Settings.h"

static NSString *kFLContainerType = @"FLContainerType";
static NSString *kFLUnitID = @"FLUnitID";
static NSString *kFLPreload = @"FLPreload";
static NSString *kFLPreloadOffscreen = @"FLPreloadOffscreen";
static NSString *kFLPreloadInDetachedParentView = @"FLPreloadInDetachedParentView";
static NSString *kFLWaitForPreloadingCompletionEvent = @"FLWaitForPreloadingCompletionEvent";
static NSString *kFLHideAfterPreloading = @"FLHideAfterPreloading";
static NSString *kFLRemoveFromParentAfterPreloading = @"FLRemoveFromParentAfterPreloading";
static NSString *kFLInjectVisibilityJavascript = @"FLInjectVisibilityJavascript";
static NSString *kFLAutoPresent = @"FLAutoPresent";
static NSString *kFLManualImpressions = @"FLManualImpressions";

@implementation Settings

+ (instancetype)shared
{
    static Settings *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[Settings alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Container type
        self.containerType = [self defaultIntegerForKey:kFLContainerType fallback:MRAIDContainerTypeDFPBannerView];
        
        // Unit ID
        self.unitID = [self defaultStringForKey:kFLUnitID fallback:@"/21709104563/testing/celtra/celtra18"];
        
        // Preload
        self.preload = [self defaultBoolForKey:kFLPreload fallback:YES];
        
        // Preload offscreen
        // Doesn't seem to work, so leaving off by default.
        self.preloadOffscreen = [self defaultBoolForKey:kFLPreloadOffscreen fallback:NO];
        
        // Preload in detached parent view.
        self.preloadInDetachedParentView = [self defaultBoolForKey:kFLPreloadInDetachedParentView fallback:NO];
        
        // Wait for preloading completion event.
        self.waitForPreloadingCompletionEvent = [self defaultBoolForKey:kFLWaitForPreloadingCompletionEvent fallback:YES];
        
        // Hide after preloading
        self.hideAfterPreloading = [self defaultBoolForKey:kFLHideAfterPreloading fallback:NO];
        
        // Remove from hierarchy after preloading
        self.removeFromParentAfterPreloading = [self defaultBoolForKey:kFLRemoveFromParentAfterPreloading fallback:NO];
        
        // Inject visibility javascript
        self.injectVisibilityJavascript = [self defaultBoolForKey:kFLInjectVisibilityJavascript fallback:NO];
        
        // Auto-present
        self.autoPresent = [self defaultBoolForKey:kFLAutoPresent fallback:YES];
        
        // Manual impressions
        self.manualImpressions = [self defaultBoolForKey:kFLManualImpressions fallback:NO];
    }
    return self;
}

- (NSString *)defaultStringForKey:(NSString *)key fallback:(NSString *)fallback
{
    NSString *defaultString = [self.defaults objectForKey:key];
    NSString *result = defaultString.length > 0 ? defaultString : fallback;
    return result;
}

- (BOOL)defaultBoolForKey:(NSString *)key fallback:(BOOL)fallback
{
    id object = [self.defaults objectForKey:key];
    BOOL result = object ? [self.defaults boolForKey:key] : fallback;
    return result;
}

- (BOOL)defaultIntegerForKey:(NSString *)key fallback:(NSInteger)fallback
{
    id object = [self.defaults objectForKey:key];
    NSInteger result = object ? [self.defaults integerForKey:key] : fallback;
    return result;
}

+ (NSArray<NSString *> *)allPossibleUnitIDs
{
    return @[
         // 300x250 banner
         @"/21709104563/testing/display_300_250",
         
         // 300x600 banner
         @"/21709104563/testing/display_300_600",
         
         // Simple fullscreen Celtra banner ad
         @"/21709104563/testing/static_fsa",
         
         // Fullscreen landscape Celtra video loop with tap to full video.
         @"/21709104563/testing/cinemaloop_horizontal",
         
         // Fullscreen portrait Celtra video loop with tap to full video.
         @"/21709104563/testing/cinemaloop_vertical",
         
         // Internal tests
         @"/21709104563/testing/celtra/celtra1",
         @"/21709104563/testing/celtra/celtra2",
         @"/21709104563/testing/celtra/celtra3",
         @"/21709104563/testing/celtra/celtra4",
         @"/21709104563/testing/celtra/celtra5",
         @"/21709104563/testing/celtra/celtra6",
         
         // PBS DDT Auto Play
         @"/21709104563/testing/celtra/celtra12",
         
         // PBS Monday Auto Play
         @"/21709104563/testing/celtra/celtra13",
         
         // PBS Tonight Autoplay
         @"/21709104563/testing/celtra/celtra15",
         
         // Ad council
         @"/21709104563/testing/celtra/celtra18",
         
         // Video ad *with* javascript hack
         @"/21709104563/testing/celtra/celtra20"
    ];
}

- (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}

- (void)setContainerType:(MRAIDContainerType)containerType
{
    _containerType = containerType;
    [self.defaults setObject:@(containerType) forKey:kFLContainerType];
}

- (NSString *)prettyUnitID
{
    return [self.unitID lastPathComponent];
}

- (void)setUnitID:(NSString *)unitID
{
    _unitID = unitID;
    [self.defaults setObject:unitID forKey:kFLUnitID];
}

- (void)setPreload:(BOOL)preload
{
    _preload = preload;
    [self.defaults setBool:preload forKey:kFLPreload];
}

- (void)setPreloadOffscreen:(BOOL)preloadOffscreen
{
    _preloadOffscreen = preloadOffscreen;
    [self.defaults setBool:preloadOffscreen forKey:kFLPreloadOffscreen];
}

- (void)setPreloadInDetachedParentView:(BOOL)detached
{
    _preloadInDetachedParentView = detached;
    [self.defaults setBool:detached forKey:kFLPreloadInDetachedParentView];
}

- (void)setWaitForPreloadingCompletionEvent:(BOOL)wait
{
    _waitForPreloadingCompletionEvent = wait;
    [self.defaults setBool:wait forKey:kFLWaitForPreloadingCompletionEvent];
}

- (void)setHideAfterPreloading:(BOOL)hide
{
    _hideAfterPreloading = hide;
    [self.defaults setBool:hide forKey:kFLHideAfterPreloading];
}

- (void)setRemoveFromParentAfterPreloading:(BOOL)remove
{
    _removeFromParentAfterPreloading = remove;
    [self.defaults setBool:remove forKey:kFLRemoveFromParentAfterPreloading];
}

- (void)setInjectVisibilityJavascript:(BOOL)inject
{
    _injectVisibilityJavascript = inject;
    [self.defaults setBool:inject forKey:kFLInjectVisibilityJavascript];
}

- (void)setAutoPresent:(BOOL)autoPresent
{
    _autoPresent = autoPresent;
    [self.defaults setBool:autoPresent forKey:kFLAutoPresent];
}

- (void)setManualImpressions:(BOOL)manualImpressions
{
    _manualImpressions = manualImpressions;
    [self.defaults setBool:manualImpressions forKey:kFLManualImpressions];
}

@end
