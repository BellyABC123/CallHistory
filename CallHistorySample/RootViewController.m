//
//  RootViewController.m
//  CallHistorySample
//
//  Created by Toshinori Watanabe on 11/09/11.
//  Copyright 2011 FLCL.jp. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "RootViewController.h"
#import "CHCallHistory.h"
#import "CHHistory.h"
#import "ABContactsHelper.h"
#import "ABContact.h"


@interface RootViewController ()
@property (nonatomic, retain) NSArray *histories;
- (void)callHistoryChanged;
- (void)reloadCallHistory;
- (void)configureCell:(UITableViewCell *)cell history:(CHHistory *)history;
@end

@interface RootViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface RootViewController (UITableViewDelegate) <UITableViewDelegate>
@end



@implementation RootViewController

@synthesize histories;


#pragma mark - Instance

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callHistoryChanged) name:CHCallHistoryChangedNotification object:nil];

    self.title = @"Call Histories";

    self.histories = [NSArray array];
    
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self reloadCallHistory];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHCallHistoryChangedNotification object:nil];

    self.histories = nil;

    [super dealloc];
}


#pragma mark - Private methods

- (void)callHistoryChanged
{
    NSLog(@"Call history changed.");

    [self reloadCallHistory];
}

- (void)reloadCallHistory
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSArray *array = [CHCallHistory historiesWithError:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                self.histories = array;
                
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            }

            [self.tableView reloadData];

        });
    });
}

- (void)configureCell:(UITableViewCell *)cell history:(CHHistory *)history {
    NSString *text = nil;
    NSString *detailText = nil;
    
    if (history.recordID != kABRecordInvalidID) {
        ABContact *contact = [ABContact contactWithRecordID:history.recordID];
        text = contact.compositeName;
    }
    else {
        text = history.address;
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];  
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];  

    detailText = [dateFormatter stringFromDate:history.date];

    [dateFormatter release];
    
    // Set value to cell.
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detailText;
}

@end


#pragma mark -
@implementation RootViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return histories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    CHHistory *history = [histories objectAtIndex:indexPath.row];
    [self configureCell:cell history:history];
    
    return cell;
}

@end


#pragma mark -
@implementation RootViewController (UITableViewDelegate)

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSError *error = nil;
//        CHHistory *history = [histories objectAtIndex:indexPath.row];
//        if ([CHCallHistory removeHistory:history error:&error]) {
//            NSMutableArray *array = [NSMutableArray arrayWithArray:histories];
//            [array removeObjectAtIndex:indexPath.row];
//            self.histories = [NSArray arrayWithArray:array];
//
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        } else {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
//            [alertView release];
//
//        }
//    }
//}

@end

