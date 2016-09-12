//
//  PKHistoryViewController.m
//  gbible
//
//  Created by Kerri Shotts on 4/2/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

// ============================ LICENSE ============================
//
// The code that is not otherwise licensed or is owned by photoKandy
// Studios LLC is hereby licensed under a CC BY-NC-SA 3.0 license.
// That is, you may copy the code and use it for non-commercial uses
// under the same license. For the entire license, see
// http://creativecommons.org/licenses/by-nc-sa/3.0/.
//
// Furthermore, you may use the code in this app for your own
// personal or educational use. However you may NOT release a
// competing app on the App Store without prior authorization and
// significant code changes. If authorization is granted, attribution
// must be kept, but you must also add in your own attribution. You
// must also use your own API keys (TestFlight, Parse, etc.) and you
// must provide your own support. As the code is released for non-
// commercial purposes, any directly competing app based on this code
// must not require payment of any form (including ads).
//
// Attribution must be visual and be of the form:
//
//   Portions of this code from Greek Interlinear Bible,
//   (C) photokandy Studios LLC and Kerri Shotts, released
//   under a CC BY-NC-SA 3.0 license.
//
// NOTE: The graphical assets are not covered under the above license.
// They are copyright their respective owners. Any third party code
// (such as that under the Third Party section) are licensed under
// their respective licenses.
//
#import "PKHistoryViewController.h"
#import "PKHistory.h"
#import "PKBible.h"
#import "ZUUIRevealController.h"
//#import "PKRootViewController.h"
#import "PKBibleViewController.h"
#import "PKSearchViewController.h"
#import "PKStrongsController.h"
#import "PKSettings.h"
#import "PKAppDelegate.h"
#import "PKReference.h"

@interface PKHistoryViewController ()



@end

@implementation PKHistoryViewController
{
  NSArray */**__strong**/ _history;
  UILabel */**__strong**/ _noResults;
}

-(void)reloadHistory
{
  _history = [[PKHistory instance] mostRecentHistory];
  [self.tableView reloadData];
  
  if ([_history count] == 0)
  {
    _noResults.text = __Tv(@"no-history", @"You've no history.");
  }
  else
  {
    _noResults.text = @"";
  }
}

-(id)initWithStyle: (UITableViewStyle) style
{
  self = [super initWithStyle: style];
  
  if (self)
  {
    // Custom initialization
  }
  return self;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKSidebarPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  CGRect theRect = CGRectMake(0, 88, 260, 60);
  _noResults                  = [[UILabel alloc] initWithFrame: theRect];
  _noResults.textColor        = [PKSettings PKTextColor];
  _noResults.font             = [UIFont fontWithName: [PKSettings interfaceFont] size: 16];
  _noResults.textAlignment    = NSTextAlignmentCenter;
  _noResults.backgroundColor  = [UIColor clearColor];
  _noResults.shadowColor      = [UIColor clearColor];
  _noResults.numberOfLines    = 0;
  [self.view addSubview: _noResults];

  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
  CGFloat topOffset = self.navigationController.navigationBar.frame.size.height;
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) { topOffset = 0; }
  self.tableView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0);
//  if (SYSTEM_VERSION_LESS_THAN(@"7.0") && !_delegate)
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-topOffset, 0, 0, 0);
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  _history   = nil;
  _noResults = nil;
}

-(void) updateAppearanceForTheme
{
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKSidebarPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

  self.tableView.rowHeight = 36;
  [self.tableView reloadData];
}

-(void)viewDidAppear: (BOOL) animated
{
  [super viewDidAppear:animated];

  if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
  {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    CGFloat topOffset = self.navigationController.navigationBar.frame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0);
  }



  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
  [self reloadHistory];
  [self updateAppearanceForTheme];
  [self calculateShadows];
}

-(void)didAnimateFirstHalfOfRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
}

-(void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView: (UITableView *) tableView
{
  // Return the number of sections.
  return 1;
}

-(NSInteger)tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
  // Return the number of rows in the section.
  return [_history count];
}

-(UITableViewCell *)tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *historyCellID = @"PKHistoryCellID";
  UITableViewCell *cell          = [tableView dequeueReusableCellWithIdentifier: historyCellID];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleDefault
            reuseIdentifier: historyCellID];
  }
  
  NSUInteger row           = [indexPath row];
  cell.textLabel.textColor = [PKSettings PKSidebarTextColor];
  cell.textLabel.font      = [UIFont fontWithName:[PKSettings boldInterfaceFont] size:16];
  cell.backgroundColor     = [UIColor clearColor];
  
  NSString *theHistoryItem = _history[row];
  
  if ([theHistoryItem characterAtIndex: 0] == 'P')
  {
    // passage
    PKReference *theReference       = [PKReference referenceWithString:[theHistoryItem substringFromIndex: 1]];
    NSString *thePrettyReference = [theReference prettyReference];
    
    cell.textLabel.text = thePrettyReference;
  }
  else
    if ([theHistoryItem characterAtIndex: 0] == 'B')
    {
      // Bible search
      NSString *theSearchTerm = [theHistoryItem substringFromIndex: 1];
      cell.textLabel.text = [NSString stringWithFormat: @"%@: %@", __T(@"Bible"), theSearchTerm];
    }
    else
      if ([theHistoryItem characterAtIndex: 0] == 'S')
      {
        // Strongs search
        NSString *theStrongsTerm = [theHistoryItem substringFromIndex: 1];
        cell.textLabel.text = [NSString stringWithFormat: @"%@: %@", __T(@"Strong's"), theStrongsTerm];
      }
  
  return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row               = [indexPath row];
  NSString *theHistoryItem     = _history[row];
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
  
  [[PKAppDelegate sharedInstance].rootViewController revealToggle: self];
  
  if ([theHistoryItem characterAtIndex: 0] == 'P')
  {
    // passage
    PKReference *theReference       = [PKReference referenceWithString:[theHistoryItem substringFromIndex: 1]];
    NSUInteger theBook                = theReference.book;
    NSUInteger theChapter             = theReference.chapter;
    NSUInteger theVerse               = theReference.verse;
    [[PKAppDelegate sharedInstance].bibleViewController displayBook: theBook andChapter: theChapter andVerse: theVerse];
  }
  else
    if ([theHistoryItem characterAtIndex: 0] == 'B')
    {
      PKSearchViewController *sbvc = [[PKSearchViewController alloc] initWithStyle:UITableViewStylePlain];
      // Bible search
      NSString *theSearchTerm = [theHistoryItem substringFromIndex: 1];
      [sbvc doSearchForTerm: theSearchTerm];
      [[PKAppDelegate sharedInstance].bibleViewController.navigationController pushViewController:sbvc animated:YES];
    }
    else
      if ([theHistoryItem characterAtIndex: 0] == 'S')
      {
        PKStrongsController *ssvc    = [[PKStrongsController alloc] initWithStyle:UITableViewStylePlain];
        // Strongs search
        NSString *theStrongsTerm = [theHistoryItem substringFromIndex: 1];
        [ssvc doSearchForTerm: theStrongsTerm];
      [[PKAppDelegate sharedInstance].bibleViewController.navigationController pushViewController:ssvc animated:YES];
      }
}

@end
