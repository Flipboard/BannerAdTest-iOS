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
    // Set unit ID label text.
    self.unitIDLabel.text = DataModel.shared.prettyUnitID;
    
    // Set the switch states.
    self.preloadSwitch.on = DataModel.shared.shouldPreload;
    self.preloadOffscreenSwitch.on = DataModel.shared.preloadOffscreen;
    self.preloadInDetechedParentViewSwitch.on = DataModel.shared.preloadInDetachedParentView;
    self.waitForPreloadingCompletionEventSwitch.on = DataModel.shared.waitForPreloadingCompletionEvent;
    self.hideAfterPreloadingSwitch.on = DataModel.shared.hideAfterPreloading;
    self.removeFromParentAfterPreloadingSwitch.on = DataModel.shared.removeFromParentAfterPreloading;
    self.injectVisibilityJavascriptSwitch.on = DataModel.shared.injectVisibilityJavascript;
    self.autoPresentSwitch.on = DataModel.shared.shouldAutoPresent;
    self.manualImpressionSwitch.on = DataModel.shared.manualImpressions;
    
    // If preloading is off then disable related cells.
    [self setPreloadingSubcellsEnabled:DataModel.shared.shouldPreload];
}

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
    DataModel.shared.shouldPreload = sender.on;
    [self updateUI];
}

- (IBAction)preloadOffscreenChanged:(UISwitch *)sender
{
    DataModel.shared.preloadOffscreen = sender.on;
    [self updateUI];
}

- (IBAction)preloadInDetachedParentViewChanged:(UISwitch *)sender
{
    DataModel.shared.preloadInDetachedParentView = sender.on;
    [self updateUI];
}

- (IBAction)waitForPreloadingCompletionEventChanged:(UISwitch *)sender
{
    DataModel.shared.waitForPreloadingCompletionEvent = sender.on;
    [self updateUI];
}

- (IBAction)hideAfterPreloadingChanged:(UISwitch *)sender
{
    DataModel.shared.hideAfterPreloading = sender.on;
    [self updateUI];
}

- (IBAction)removeFromParentAfterPreloadingChanged:(UISwitch *)sender
{
    DataModel.shared.removeFromParentAfterPreloading = sender.on;
    [self updateUI];
}

- (IBAction)injectVisibilityJavascriptSwitchChanged:(UISwitch *)sender
{
    DataModel.shared.injectVisibilityJavascript = sender.on;
    [self updateUI];
}

- (IBAction)autoPresentSwitchChanged:(UISwitch *)sender
{
    DataModel.shared.shouldAutoPresent = sender.on;
    [self updateUI];
}

- (IBAction)manualImpressionsSwitchChanged:(UISwitch *)sender
{
    DataModel.shared.manualImpressions = sender.on;
    [self updateUI];
}

@end
