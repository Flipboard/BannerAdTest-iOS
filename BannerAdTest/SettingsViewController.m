//
//  SettingsViewController.m
//  BannerAdTest
//
//  Created by Colin Caufield on 4/2/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import "SettingsViewController.h"
#import "UnitIDViewController.h"

@interface SettingsViewController ()

//@property (nonatomic, weak) IBOutlet UISegmentedControl *containerSegmentedControl;
@property (nonatomic, weak) IBOutlet UILabel *unitIDLabel;
@property (nonatomic, weak) IBOutlet UISwitch *preloadSwitch;
@property (nonatomic, weak) IBOutlet UITableViewCell *preloadOffscreenCell;
@property (nonatomic, weak) IBOutlet UISwitch *preloadOffscreenSwitch;
@property (nonatomic, weak) IBOutlet UITableViewCell *preloadInDetechedParentViewCell;
@property (nonatomic, weak) IBOutlet UISwitch *preloadInDetechedParentViewSwitch;
@property (nonatomic, weak) IBOutlet UITableViewCell *waitForPreloadingCompletionEventCell;
@property (nonatomic, weak) IBOutlet UISwitch *waitForPreloadingCompletionEventSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *hideAfterPreloadingSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *removeFromParentAfterPreloadingSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *injectVisibilityJavascriptSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *autoPresentSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *manualImpressionSwitch;

@end

@implementation SettingsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Show the status bar with a nice animation.
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Refresh the UI.
    [self updateUI];
}

- (void)updateUI
{
    // Container type
    //self.containerSegmentedControl.selectedSegmentIndex = Settings.shared.containerType;
    
    // Set unit ID label text.
    self.unitIDLabel.text = Settings.shared.unitIDName;
    
    // Set the switch states.
    self.preloadSwitch.on = Settings.shared.shouldPreload;
    self.preloadOffscreenSwitch.on = Settings.shared.shouldPreloadOffscreen;
    self.preloadInDetechedParentViewSwitch.on = Settings.shared.shouldPreloadInDetachedParentView;
    self.waitForPreloadingCompletionEventSwitch.on = Settings.shared.shouldWaitForPreloadingCompletionEvent;
    self.hideAfterPreloadingSwitch.on = Settings.shared.shouldHideAfterPreloading;
    self.removeFromParentAfterPreloadingSwitch.on = Settings.shared.shouldRemoveFromParentAfterPreloading;
    self.injectVisibilityJavascriptSwitch.on = Settings.shared.shouldInjectVisibilityJavascript;
    self.autoPresentSwitch.on = Settings.shared.shouldAutoPresent;
    self.manualImpressionSwitch.on = Settings.shared.shouldFireManualImpressions;
    
    // If preloading is off then disable related cells.
    [self setPreloadingSubcellsEnabled:Settings.shared.shouldPreload];
}

//- (IBAction)containerSegmentedControlChanged:(UISegmentedControl *)sender
//{
//    Settings.shared.containerType = sender.selectedSegmentIndex;
//    [self updateUI];
//}

- (NSArray *)preloadingSubcells
{
    return @[self.waitForPreloadingCompletionEventCell,
             self.preloadOffscreenCell,
             self.preloadInDetechedParentViewCell];
}

- (void)setPreloadingSubcellsEnabled:(BOOL)enabled
{
    for (UITableViewCell *cell in self.preloadingSubcells) {
        cell.userInteractionEnabled = enabled;
        cell.contentView.alpha = enabled ? 1.0 : 0.5;
    }
}

- (IBAction)preloadSwitchChanged:(UISwitch *)sender
{
    Settings.shared.shouldPreload = sender.on;
    [self updateUI];
}

- (IBAction)preloadOffscreenChanged:(UISwitch *)sender
{
    Settings.shared.shouldPreloadOffscreen = sender.on;
    [self updateUI];
}

- (IBAction)preloadInDetachedParentViewChanged:(UISwitch *)sender
{
    Settings.shared.shouldPreloadInDetachedParentView = sender.on;
    [self updateUI];
}

- (IBAction)waitForPreloadingCompletionEventChanged:(UISwitch *)sender
{
    Settings.shared.shouldWaitForPreloadingCompletionEvent = sender.on;
    [self updateUI];
}

- (IBAction)hideAfterPreloadingChanged:(UISwitch *)sender
{
    Settings.shared.shouldHideAfterPreloading = sender.on;
    [self updateUI];
}

- (IBAction)removeFromParentAfterPreloadingChanged:(UISwitch *)sender
{
    Settings.shared.shouldRemoveFromParentAfterPreloading = sender.on;
    [self updateUI];
}

- (IBAction)injectVisibilityJavascriptSwitchChanged:(UISwitch *)sender
{
    Settings.shared.shouldInjectVisibilityJavascript = sender.on;
    [self updateUI];
}

- (IBAction)autoPresentSwitchChanged:(UISwitch *)sender
{
    Settings.shared.shouldAutoPresent = sender.on;
    [self updateUI];
}

- (IBAction)manualImpressionsSwitchChanged:(UISwitch *)sender
{
    Settings.shared.shouldFireManualImpressions = sender.on;
    [self updateUI];
}

@end
