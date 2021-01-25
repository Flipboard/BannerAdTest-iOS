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

// All the bundled unit IDs for testing (name / unit ID pairs)
+ (NSDictionary<NSString *, NSString *> *)allPossibleUnitIDs;

// Unit ID
@property (nonatomic, copy) NSString *unitID;

// Name of the unit ID.
@property (nonatomic, readonly) NSString *unitIDName;

// Last component of the unit ID only.
@property (nonatomic, readonly) NSString *simplifiedUnitID;

// Should the preloading hack be used.
@property (nonatomic, assign) BOOL shouldPreload;

// Place preloading views outside of the screen's bounds.
@property (nonatomic, assign) BOOL shouldPreloadOffscreen;

// Place preloading views in a parent view detached from the view hierarchy.
@property (nonatomic, assign) BOOL shouldPreloadInDetachedParentView;

// Preload until the creative signals that it's done preloding.
// If false, creatives are given a constant amount of time to preload (currently 5s).
@property (nonatomic, assign) BOOL shouldWaitForPreloadingCompletionEvent;

// Hide banners after they've finished preloading.
@property (nonatomic, assign) BOOL shouldHideAfterPreloading;

// Remove banners from parent views after preloading.
@property (nonatomic, assign) BOOL shouldRemoveFromParentAfterPreloading;

// Inject javascript to let the banner know when it's *actually* visible.
@property (nonatomic, assign) BOOL shouldInjectVisibilityJavascript;

// Should the ad automatically be presented once it's done downloading (and preloading).
@property (nonatomic, assign) BOOL shouldAutoPresent;

// Manually report impressions rather than letting the SDK do it automatically.
@property (nonatomic, assign) BOOL shouldFireManualImpressions;

@end
