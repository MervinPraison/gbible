//
//  PKBibleListViewController.m
//  gbible
//
//  Created by Kerri Shotts on 1/29/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
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
#import "PKBibleListViewController.h"
#import "PKBible.h"
#import "PKConstants.h"
#import "PKSettings.h"
#import <Parse/Parse.h>
#import "PKBibleInfoViewController.h"
#import "UIImage+PKUtility.h"


@interface PKBibleListViewController ()

@end

@implementation PKBibleListViewController
{
  NSArray * /**__strong**/ _builtInBibleIDs;
  NSArray * /**__strong**/ _builtInBibleAbbreviations;
  NSArray * /**__strong**/ _builtInBibleTitles;

  NSArray * /**__strong**/ _installedBibleIDs;
  NSArray * /**__strong**/ _installedBibleAbbreviations;
  NSArray * /**__strong**/ _installedBibleTitles;

  NSArray * /**__strong**/ _availableBibleIDs;
  NSArray * /**__strong**/ _availableBibleAbbreviations;
  NSArray * /**__strong**/ _availableBibleTitles;
}

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
    [self.navigationItem setTitle: __T(@"Manage Bibles")];
  }
  return self;
}

- (void)loadBibles
{
  // we'll first load the bibles we know we have
  _builtInBibleIDs           = [PKBible builtInTextsWithColumn:PK_TBL_BIBLES_ID];
  _builtInBibleAbbreviations = [PKBible builtInTextsWithColumn:PK_TBL_BIBLES_ABBREVIATION];
  _builtInBibleTitles        = [PKBible builtInTextsWithColumn:PK_TBL_BIBLES_NAME];
  
  _installedBibleIDs           = [PKBible installedTextsWithColumn:PK_TBL_BIBLES_ID];
  _installedBibleAbbreviations = [PKBible installedTextsWithColumn:PK_TBL_BIBLES_ABBREVIATION];
  _installedBibleTitles        = [PKBible installedTextsWithColumn:PK_TBL_BIBLES_NAME];
  
  _availableBibleIDs = [[NSArray alloc] init];
  _availableBibleAbbreviations = [[NSArray alloc] init];
  _availableBibleTitles = [[NSArray alloc] init];
  
  [self.tableView reloadData];
  
  // send off a request to parse
  PFQuery *query = [PFQuery queryWithClassName:@"Bibles"];
  [query whereKey:@"ID" notContainedIn:_installedBibleIDs];
  [query whereKey:@"minVersion" lessThanOrEqualTo:[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
  [query whereKey:@"Available" equalTo:@(YES)];
  [query orderByAscending:@"Abbreviation"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      // objects has the available bibles; let's build the available Bibles array
      NSMutableArray *mAvailableBibleIDs = [[NSMutableArray alloc] initWithCapacity:10];
      NSMutableArray *mAvailableBibleAbbreviations = [[NSMutableArray alloc] initWithCapacity:10];
      NSMutableArray *mAvailableBibleTitles = [[NSMutableArray alloc] initWithCapacity:10];

      // http://stackoverflow.com/questions/3940615/find-current-country-from-iphone-device
      NSLocale *currentLocale = [NSLocale currentLocale];    // get the current locale.
      NSString *countryCode   = [currentLocale objectForKey: NSLocaleCountryCode];
      
      for (int i=0; i<objects.count; i++)
      {
        // make sure we don't add the KJV version if we're in the UK, or in the Euro-zone (since they
        // must respect the UK copyright)
        if ( !( ([@" GB "
//          if ( !( ([@" GB AT BE BG CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE "
                  rangeOfString: [NSString stringWithFormat: @" %@ ", countryCode]].location != NSNotFound)
                && [(objects[i])[@"Abbreviation"] isEqualToString: @"KJV"] ) )
        {
          [mAvailableBibleIDs addObject:(objects[i])[@"ID"]];
          [mAvailableBibleAbbreviations addObject:(objects[i])[@"Abbreviation"]];
          [mAvailableBibleTitles addObject:(objects[i])[@"Title"]];
        }
      }
   
   _availableBibleIDs = [mAvailableBibleIDs copy];
   _availableBibleAbbreviations = [mAvailableBibleAbbreviations copy];
   _availableBibleTitles = [mAvailableBibleTitles copy];
   
   [self.tableView reloadData];
   } else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
   }
   }];
  
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if (self.navigationItem)
  {
    UIBarButtonItem *closeButton =
    [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
     ];
    self.navigationItem.rightBarButtonItem = closeButton;

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsDefaultPrompt];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsCompact];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsCompactPrompt];


  }
    [self loadBibles];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

-(void) closeMe: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
  [[PKSettings instance] saveSettings];
}

-(void) installedBiblesChanged
{
  [self loadBibles];
  if (delegate)
  {
    [delegate installedBiblesChanged];
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  switch (section)
  {
    case 0:
      return _builtInBibleTitles.count;
      break;
    case 1:
      return _installedBibleTitles.count;
      break;
    case 2:
      return _availableBibleTitles.count;
      break;
  }
  
  return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    case 0:
      return __T(@"Built-In Bibles");
      break;
    case 1:
      return __T(@"Installed Bibles");
      break;
    case 2:
      return __T(@"Downloadable Bibles");
      break;
  }
  return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *settingsCellID = @"PKBibleCellID";
  UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier: settingsCellID];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleValue1
            reuseIdentifier: settingsCellID];
  }
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  NSString *theBibleTitle;
  NSString *theBibleAbbreviation;
  
  switch (indexPath.section)
  {
    case 0:
      theBibleTitle = _builtInBibleTitles[indexPath.row];
      theBibleAbbreviation = _builtInBibleAbbreviations[indexPath.row];
      break;
    case 1:
      theBibleTitle = _installedBibleTitles[indexPath.row];
      theBibleAbbreviation = _installedBibleAbbreviations[indexPath.row];
      break;
    case 2:
      theBibleTitle = _availableBibleTitles[indexPath.row];
      theBibleAbbreviation = _availableBibleAbbreviations[indexPath.row];
      break;
  }
  
  cell.textLabel.text = theBibleTitle;
  cell.detailTextLabel.text = theBibleAbbreviation;
  cell.textLabel.font      = [UIFont fontWithName:[PKSettings boldInterfaceFont] size:16];
  cell.detailTextLabel.font      = [UIFont fontWithName:[PKSettings interfaceFont] size:16];
  cell.backgroundColor     = [UIColor clearColor];

  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  int theBibleID;
  switch (indexPath.section)
  {
    case 0:
      theBibleID = [_builtInBibleIDs[indexPath.row] intValue];
      break;
    case 1:
      theBibleID = [_installedBibleIDs[indexPath.row] intValue];
      break;
    case 2:
      theBibleID = [_availableBibleIDs[indexPath.row] intValue];
      break;
    default:
      theBibleID = 0;
  }
  
  PKBibleInfoViewController *bivc = [[PKBibleInfoViewController alloc] initWithBibleID:theBibleID];
  bivc.delegate = self;
  [self.navigationController pushViewController:bivc animated:YES];
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];

}

@end
