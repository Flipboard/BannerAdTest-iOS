//
//  Settings.h
//  BannerAdTest
//
//  Created by Colin Caufield on 4/2/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

// Singleton
+ (instancetype)shared;

// All the bundled unit IDs for testing.
+ (NSArray<NSString *> *)allPossibleUnitIDs;

// Last componenet of the Unit ID only.
@property (nonatomic, readonly) NSString *prettyUnitID;

// Unit ID
@property (nonatomic, copy) NSString *unitID;

// Should the preloading hack be used.
@property (nonatomic, assign) BOOL preload;

// Place preloading views outside of the screen's bounds.
@property (nonatomic, assign) BOOL preloadOffscreen;

// Place preloading views in a parent view detached from the view hierarchy.
@property (nonatomic, assign) BOOL preloadInDetachedParentView;

// Preload until the creative signals that it's done preloding.
// If false, creatives are given a constant amount of time to preload (currently 5s).
@property (nonatomic, assign) BOOL waitForPreloadingCompletionEvent;

// Hide banners after they've finished preloading.
@property (nonatomic, assign) BOOL hideAfterPreloading;

// Remove banners from parent views after preloading.
@property (nonatomic, assign) BOOL removeFromParentAfterPreloading;

// Inject javascript to let the banner know when it's *actually* visible.
@property (nonatomic, assign) BOOL injectVisibilityJavascript;

// Should the ad automatically be presented once it's done downloading (and preloading).
@property (nonatomic, assign) BOOL autoPresent;

// Manually report impressions rather than letting the SDK do it automatically.
@property (nonatomic, assign) BOOL manualImpressions;

@end
