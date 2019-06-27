//
//  UnitIDViewController.m
//  BannerAdTest
//
//  Created by Colin Caufield on 4/2/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import "UnitIDViewController.h"

@implementation UnitIDViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateAllCheckmarks];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return DataModel.allPossibleUnitIDs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Recycle or create a cell
    UITableViewCell *unitIDCell = [self.tableView dequeueReusableCellWithIdentifier:@"UnitIDCell"];
    if (!unitIDCell) {
        unitIDCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UnitIDCell"];
    }
    
    // Text
    NSString *unitID = DataModel.allPossibleUnitIDs[indexPath.item];
    unitIDCell.textLabel.text = unitID;
    
    // Checkmark
    BOOL checked = [unitID isEqual:DataModel.shared.unitID];
    unitIDCell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return unitIDCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Save the selected unit ID
    NSString *unitID = DataModel.allPossibleUnitIDs[indexPath.item];
    DataModel.shared.unitID = unitID;
    
    // Deselect the cell
    UITableViewCell *unitIDCell = [self.tableView cellForRowAtIndexPath:indexPath];
    unitIDCell.selected = NO;
    
    // Update all the checkmarks
    [self updateAllCheckmarks];
}

- (void)updateAllCheckmarks
{
    // Iterate over all the rows
    for (NSInteger index = 0; index < DataModel.allPossibleUnitIDs.count; index++) {
        // Get the cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        // Hide/show the checkmark
        NSString *unitID = DataModel.allPossibleUnitIDs[index];
        BOOL checked = [unitID isEqual:DataModel.shared.unitID];
        cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
}

@end
