//
//  Settings.m
//  BannerAdTest
//
//  Created by Colin Caufield on 4/2/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import "Settings.h"

static NSString *kFLUnitIDKey = @"FLUnitID";
static NSString *kFLPreloadKey = @"FLPreload";
static NSString *kFLPreloadOffscreenKey = @"FLPreloadOffscreen";
static NSString *kFLPreloadInDetachedParentViewKey = @"FLPreloadInDetachedParentView";
static NSString *kFLWaitForPreloadingCompletionEventKey = @"FLWaitForPreloadingCompletionEvent";
static NSString *kFLHideAfterPreloadingKey = @"FLHideAfterPreloading";
static NSString *kFLRemoveFromParentAfterPreloadingKey = @"FLRemoveFromParentAfterPreloading";
static NSString *kFLInjectVisibilityJavascriptKey = @"FLInjectVisibilityJavascript";
static NSString *kFLAutoPresentKey = @"FLAutoPresent";
static NSString *kFLManualImpressionsKey = @"FLManualImpressions";

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
        // Unit ID
        self.unitID = [self defaultStringForKey:kFLUnitIDKey fallback:@"/21709104563/testing/celtra/celtra25"];
        
        // Preload
        self.shouldPreload = [self defaultBoolForKey:kFLPreloadKey fallback:NO];
        
        // Preload offscreen
        // Doesn't seem to work, so leaving off by default.
        self.shouldPreloadOffscreen = [self defaultBoolForKey:kFLPreloadOffscreenKey fallback:NO];
        
        // Preload in detached parent view.
        self.shouldPreloadInDetachedParentView = [self defaultBoolForKey:kFLPreloadInDetachedParentViewKey fallback:NO];
        
        // Wait for preloading completion event.
        self.shouldWaitForPreloadingCompletionEvent = [self defaultBoolForKey:kFLWaitForPreloadingCompletionEventKey fallback:YES];
        
        // Hide after preloading
        self.shouldHideAfterPreloading = [self defaultBoolForKey:kFLHideAfterPreloadingKey fallback:NO];
        
        // Remove from hierarchy after preloading
        self.shouldRemoveFromParentAfterPreloading = [self defaultBoolForKey:kFLRemoveFromParentAfterPreloadingKey fallback:NO];
        
        // Inject visibility javascript
        self.shouldInjectVisibilityJavascript = [self defaultBoolForKey:kFLInjectVisibilityJavascriptKey fallback:NO];
        
        // Auto-present
        self.shouldAutoPresent = [self defaultBoolForKey:kFLAutoPresentKey fallback:YES];
        
        // Manual impressions
        self.shouldFireManualImpressions = [self defaultBoolForKey:kFLManualImpressionsKey fallback:NO];
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

+ (NSDictionary<NSString *, NSString *> *)allPossibleUnitIDs
{
    return @{
         // 300x250 banner
         @"300x250 Banner" : @"/21709104563/testing/display_300_250",
         
         // 300x600 banner
         @"300x600 Banner" : @"/21709104563/testing/display_300_600",
         
         // Simple fullscreen Celtra banner ad
         @"Test FSA" : @"/21709104563/testing/static_fsa",
         
         // Fullscreen landscape Celtra video loop with tap to full video.
         @"CinemaLoop Horizontal" : @"/21709104563/testing/cinemaloop_horizontal",
         
         // Fullscreen portrait Celtra video loop with tap to full video.
         @"CinemaLoop Vertical" : @"/21709104563/testing/cinemaloop_vertical",
         
         // Autoplay video in DFPBannerView
         @"Autoplay Video Banner" : @"/21709104563/testing/celtra/celtra24",
         
         // Autoplay video in custom template
         @"Autoplay Video Custom Template" : @"/21709104563/testing/celtra/celtra25"
    };
}

- (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}


- (NSString *)unitIDName
{
    return [[[[self class] allPossibleUnitIDs] allKeysForObject:self.unitID] firstObject];
}

- (NSString *)simplifiedUnitID
{
    return [self.unitID lastPathComponent];
}

- (void)setUnitID:(NSString *)unitID
{
    _unitID = unitID;
    [self.defaults setObject:unitID forKey:kFLUnitIDKey];
}

- (void)setShouldPreload:(BOOL)preload
{
    _shouldPreload = preload;
    [self.defaults setBool:preload forKey:kFLPreloadKey];
}

- (void)setShouldPreloadOffscreen:(BOOL)preloadOffscreen
{
    _shouldPreloadOffscreen = preloadOffscreen;
    [self.defaults setBool:preloadOffscreen forKey:kFLPreloadOffscreenKey];
}

- (void)setShouldPreloadInDetachedParentView:(BOOL)detached
{
    _shouldPreloadInDetachedParentView = detached;
    [self.defaults setBool:detached forKey:kFLPreloadInDetachedParentViewKey];
}

- (void)setShouldWaitForPreloadingCompletionEvent:(BOOL)wait
{
    _shouldWaitForPreloadingCompletionEvent = wait;
    [self.defaults setBool:wait forKey:kFLWaitForPreloadingCompletionEventKey];
}

- (void)setShouldHideAfterPreloading:(BOOL)hide
{
    _shouldHideAfterPreloading = hide;
    [self.defaults setBool:hide forKey:kFLHideAfterPreloadingKey];
}

- (void)setShouldRemoveFromParentAfterPreloading:(BOOL)remove
{
    _shouldRemoveFromParentAfterPreloading = remove;
    [self.defaults setBool:remove forKey:kFLRemoveFromParentAfterPreloadingKey];
}

- (void)setShouldInjectVisibilityJavascript:(BOOL)inject
{
    _shouldInjectVisibilityJavascript = inject;
    [self.defaults setBool:inject forKey:kFLInjectVisibilityJavascriptKey];
}

- (void)setShouldAutoPresent:(BOOL)autoPresent
{
    _shouldAutoPresent = autoPresent;
    [self.defaults setBool:autoPresent forKey:kFLAutoPresentKey];
}

- (void)setShouldFireManualImpressions:(BOOL)manualImpressions
{
    _shouldFireManualImpressions = manualImpressions;
    [self.defaults setBool:manualImpressions forKey:kFLManualImpressionsKey];
}

@end
