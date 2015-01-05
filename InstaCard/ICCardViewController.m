//
//  ICCardViewController.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICCardViewController.h"
#import "ICCoreDataStack.h"
#import "ICCard.h"
#import "ICCardDetailViewController.h"
#import "ICCardEditViewController.h"
#import "ICExpiryReminderTableViewController.h"
#import "ICCardCell.h"
#import "ICUtils.h"
#import "ICNotificationView.h"

#import "ICConstants.h"
#import "KeychainWrapper.h"

#import <MessageUI/MessageUI.h>

@interface ICCardViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, readwrite, nonatomic) REMenu *menu;

- (BOOL)usePin;

@end

@implementation ICCardViewController

@synthesize viewType = _viewType;

#pragma mark Statics
static NSString *CellIdentifier = @"ICCardCell";
static NSString *kCardEntity = @"ICCard";
static NSString *kShowDetailSegueID = @"showDetail";

static NSString *kCardViewControllerStoryBoardID = @"cardViewController";
static NSString *kCardDetailViewControllerStoryBoardID = @"cardDetailViewController";
static NSString *kCardEditViewControllerStoryBoardID = @"cardEditViewController";

static NSString *setPinSetting = @"Set PIN";
static NSString *resetPinSetting = @"Reset PIN";
static NSString *changePinSetting = @"Change PIN";
static NSString *tellFriendSetting = @"Tell A Friend";
static NSString *feedbackSetting = @"Feedback";

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pinValidated = NO;

    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    _selectedCard = nil;
    _inputPIN = nil;
    
    [self.fetchedResultsController performFetch:nil];
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        [self insertDefaultData];
        [self.fetchedResultsController performFetch:nil];
    }
    
    [self setViewTitle];
    
    if(!self.navigationItem.leftBarButtonItem && [self.navigationController.viewControllers count] > 1) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [backButton setTitle:self.navigationItem.backBarButtonItem.title forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10.0f, 0, 0)];
        [backButton setAdjustsImageWhenHighlighted:NO];
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    } else {
        UIBarButtonItem* settingsButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenu)];
        self.navigationItem.leftBarButtonItem = settingsButtonItem;
    }
    
    [self createMenu];
}

- (void)createMenu {
    
    self.menu = [[REMenu alloc] init];
    
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    self.menu.separatorOffset = CGSizeMake(15.0, 0.0);
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    [self.menu setClosePreparationBlock:^{
    }];
    
    [self.menu setCloseCompletionHandler:^{
    }];
    
    [self setMenuItems];
}

- (void)setMenuItems {
    __typeof (self) __weak weakSelf = self;
    NSInteger tag = -1;
    NSMutableArray* itemArray = [[NSMutableArray alloc] init];
    
    if (![self usePin]) {
        REMenuItem *setPINItem = [[REMenuItem alloc] initWithTitle:@"Set PIN"
                                                             image:nil
                                                  highlightedImage:nil
                                                            action:^(REMenuItem *item) {
                                                                [weakSelf setPIN];
                                                            }];
        setPINItem.tag = ++tag;
        [itemArray addObject:setPINItem];
    } else {
        REMenuItem *resetPINItem = [[REMenuItem alloc] initWithTitle:@"Reset PIN"
                                                               image:nil
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  [weakSelf resetPIN];
                                                              }];
        resetPINItem.tag = ++tag;
        [itemArray addObject:resetPINItem];
        
        REMenuItem *changePINItem = [[REMenuItem alloc] initWithTitle:@"Change PIN"
                                                                image:nil
                                                     highlightedImage:nil
                                                               action:^(REMenuItem *item) {
                                                                   [weakSelf changePIN];
                                                               }];
        changePINItem.tag = ++tag;
        [itemArray addObject:changePINItem];
        
    }

    REMenuItem *expiredItem = [[REMenuItem alloc] initWithTitle:@"Expiry Reminders"
                                                            image:nil
                                                 highlightedImage:nil
                                                           action:^(REMenuItem *item) {
                                                               [weakSelf showExpiryReminders];
                                                           }];
    expiredItem.tag = ++tag;
    [itemArray addObject:expiredItem];

    
    REMenuItem *friendItem = [[REMenuItem alloc] initWithTitle:@"Tell a Friend"
                                                            image:nil
                                                 highlightedImage:nil
                                                           action:^(REMenuItem *item) {
                                                               [weakSelf tellAFriend];
                                                           }];
    friendItem.tag = ++tag;
    [itemArray addObject:friendItem];
    
    
    REMenuItem *feedbackItem = [[REMenuItem alloc] initWithTitle:@"Feedback"
                                                              image:nil
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 [weakSelf provideFeedback];
                                                             }];
    feedbackItem.tag = ++tag;
    [itemArray addObject:feedbackItem];
    
    if (self.menu) {
        [self.menu setItems:itemArray];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _selectedCard = nil;
    _pinValidated = NO;
    _inputPIN = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissSelf:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toggleMenu {
    if (self.menu.isOpen) return [self.menu close];
    else [self setMenuItems];
    
    [self.menu showFromNavigationController:self.navigationController];
}

#pragma mark Utilities
- (void)setViewTitle {
    NSString* title = nil;
    switch (_viewType) {
        case ICBankCredit:
            title = @"Credit Cards";
            break;
        case ICBankDebit:
            title = @"Debit Cards";
            break;
        case ICPolicy:
            title = @"Policies";
            break;
        case ICLoyalty:
            title = @"Loyalty Cards";
            break;
        default:
            title = @"InstaCard";
            break;
    }
    
    self.title = title;
}

- (void)showNotification:(NSString*)text {
    ICNotificationView *nView = [[ICNotificationView alloc] initWithText: text];
    [self.view addSubview: nView];
    [nView show];
}

#pragma Default Cards
- (void) addDefaultCard:(NSString*)name icon:(NSString*)iconName type:(ICCardType)type inContext:(NSManagedObjectContext*)context {
    ICCard *cardData = [NSEntityDescription insertNewObjectForEntityForName:kCardEntity inManagedObjectContext:context];
    cardData.cardName = name;
    cardData.type = type;
    cardData.iconName = iconName;
    cardData.createdAt = [[NSDate date] timeIntervalSince1970];
}

- (void)insertDefaultPersonalCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"PAN Card" icon:@"pan" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Passport" icon:@"passport" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Aaadhar Card" icon:@"aadhar" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Driver's License" icon:@"driving" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Insurance Card" icon:@"insurance" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Ration Card" icon:@"ration" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Voter ID Card" icon:@"voter" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Membership Card" icon:@"membership" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Credit Cards" icon:@"credit" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Debit Cards" icon:@"debit" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Loyalty Cards" icon:@"loyalty" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Policies" icon:@"policies" type:ICPersonal inContext:context];
}

- (void)insertDefaultLoyaltyCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"Apollo Pharmacy" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Body Shop" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Crossword" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Hypercity" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Jet Privilege" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Louis Phillippe" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Pantaloons" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Reliance" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Religare" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Shoppers Stop" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Van Heusen" icon:@"loyalty" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Westside" icon:@"loyalty" type:ICLoyalty inContext:context];
}
- (void)insertDefaultPolicyCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"PPF" icon:@"policies" type:ICPolicy inContext:context];
    [self addDefaultCard:@"Mutual Funds" icon:@"policies" type:ICPolicy inContext:context];
    [self addDefaultCard:@"NSC" icon:@"policies" type:ICPolicy inContext:context];
}

- (void)insertDefaultBankDebitCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"SBI" icon:@"debit" type:ICBankDebit inContext:context];
    [self addDefaultCard:@"HDFC" icon:@"debit" type:ICBankDebit inContext:context];
    [self addDefaultCard:@"ICICI" icon:@"debit" type:ICBankDebit inContext:context];
}

- (void)insertDefaultBankCreditCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"SBI" icon:@"credit" type:ICBankCredit inContext:context];
    [self addDefaultCard:@"HDFC" icon:@"credit" type:ICBankCredit inContext:context];
    [self addDefaultCard:@"ICICI" icon:@"credit" type:ICBankCredit inContext:context];
}

- (void)insertDefaultData {
    NSManagedObjectContext* context = [[ICCoreDataStack defaultStack] managedObjectContext];

    [self insertDefaultPersonalCards:context];
    [self insertDefaultLoyaltyCards:context];
    [self insertDefaultPolicyCards:context];
    [self insertDefaultBankDebitCards:context];
    [self insertDefaultBankCreditCards:context];

    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ICCardCell *cell = (ICCardCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    ICCard *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSUInteger index = indexPath.section * 3 + indexPath.row;
    [cell configureCellForCard:card forIndex:index];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat screenHeight = screenRect.size.height - navigationBarHeight - statusBarHeight;
    
    CGFloat itemWidth = (screenWidth)/3.0;
    CGFloat itemHeight = (screenHeight)/4.0;
    return CGSizeMake(itemWidth, itemHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ICCard *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([card.cardName isEqualToString:@"Credit Cards"]) {
        ICCardViewController* cardViewController = [self.storyboard instantiateViewControllerWithIdentifier:kCardViewControllerStoryBoardID];
        [cardViewController setViewType:ICBankCredit];
        [self.navigationController pushViewController:cardViewController animated:YES];
    } else if ([card.cardName isEqualToString:@"Debit Cards"]) {
        ICCardViewController* cardViewController = [self.storyboard instantiateViewControllerWithIdentifier:kCardViewControllerStoryBoardID];
        [cardViewController setViewType:ICBankDebit];
        [self.navigationController pushViewController:cardViewController animated:YES];
    } else if ([card.cardName isEqualToString:@"Policies"]) {
        ICCardViewController* cardViewController = [self.storyboard instantiateViewControllerWithIdentifier:kCardViewControllerStoryBoardID];
        [cardViewController setViewType:ICPolicy];
        [self.navigationController pushViewController:cardViewController animated:YES];
    } else if ([card.cardName isEqualToString:@"Loyalty Cards"]) {
        ICCardViewController* cardViewController = [self.storyboard instantiateViewControllerWithIdentifier:kCardViewControllerStoryBoardID];
        [cardViewController setViewType:ICLoyalty];
        [self.navigationController pushViewController:cardViewController animated:YES];
    } else {
        _selectedCard = card;
        if ([self usePin]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter PIN"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Done", nil];
            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput]; // Gives us the pin field
            alert.tag = kAlertTypePIN;

            UITextField *pinField = [alert textFieldAtIndex:0];
            pinField.delegate = self;
            pinField.placeholder = @"Pin";
            pinField.tag = kTextFieldPIN;
            [alert show];
        }
        else {
            ICCardDetailViewController* cardDetailController = [self.storyboard instantiateViewControllerWithIdentifier:kCardDetailViewControllerStoryBoardID];
            cardDetailController.card = card;
            [self.navigationController pushViewController:cardDetailController animated:YES];
        }
    }
}

#pragma mark NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription* entity = [NSEntityDescription entityForName:kCardEntity inManagedObjectContext:[[ICCoreDataStack defaultStack] managedObjectContext]];
        
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d", _viewType];
        [fetchRequest setPredicate:predicate];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[ICCoreDataStack defaultStack] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
    
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

#pragma Responders, Events
- (IBAction)addCard:(id)sender {
    ICCardEditViewController* addCardController = [self.storyboard instantiateViewControllerWithIdentifier:kCardEditViewControllerStoryBoardID];
    addCardController.card = nil;
    [addCardController setCardType:_viewType];
    [self.navigationController pushViewController:addCardController animated:YES];
}

#pragma mark Settings

- (void)tellAFriend {
    if([MFMailComposeViewController canSendMail] == NO)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"No mail account configured!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [errorAlert show];
        return;
    }
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject: [NSString stringWithFormat: @"%s", APP_NAME]];
    
    // Fill out the email body text
    NSString *deviceType = [UIDevice currentDevice].model;
    NSString *emailBody = [NSString stringWithFormat: @"%s on %@", VERSION_STR, deviceType];
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)provideFeedback {
    if([MFMailComposeViewController canSendMail] == NO)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"No mail account configured!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [errorAlert show];
        return;
    }
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject: [NSString stringWithFormat: @"%s", APP_NAME]];
    
    [picker setToRecipients:@[[NSString stringWithFormat: @"%s", APP_EMAIL]]];
    
    // Fill out the email body text
    NSString *deviceType = [UIDevice currentDevice].model;
    NSString *emailBody = [NSString stringWithFormat: @"%s on %@", VERSION_STR, deviceType];
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showExpiryReminders {
    ICExpiryReminderTableViewController* vc = [[ICExpiryReminderTableViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self becomeFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Text Field + Alert View Methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldPIN:
            NSLog(@"User entered PIN to validate");
            if ([textField.text length] > 0) {
                _inputPIN = textField.text;
            }
            break;
        case kTextFieldSetup:
            NSLog(@"User entered PIN");
            if ([textField.text length] > 0) {
                _inputPIN = textField.text;
            }
            break;
        case kTextFieldReset:
        case kTextFieldChange:
            NSLog(@"User is attempting to change pin");
            if ([textField.text length] > 0) {
                _inputPIN = textField.text;
            }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertTypePIN) {
        if (buttonIndex == 1) {
            [self setPinValidity];
            if (_pinValidated) {
                ICCardDetailViewController* cardDetailController = [self.storyboard instantiateViewControllerWithIdentifier:kCardDetailViewControllerStoryBoardID];
                cardDetailController.card = _selectedCard;
                [self.navigationController pushViewController:cardDetailController animated:YES];
            }
            else {
                [self showNotification:@"Wrong Pin"];
            }
        }
    } else if (alertView.tag == kAlertTypeSetup) {
        if (buttonIndex == 1) {
            [self storePin];
            [self showNotification:@"PIN saved successfully"];
        }
    } else if (alertView.tag == kAlertTypeReset) {
        if (buttonIndex == 1) {
            [self setPinValidity];
            if (_pinValidated) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PIN_SAVED];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSLog(@"** Key reset successfully!!");
                [self showNotification:@"PIN reset successfully"];
            }
            else {
                [self showNotification:@"Wrong Pin"];
            }
        }
    } else if (alertView.tag == kAlertTypeChange) {
        if (buttonIndex == 1) {
            [self setPinValidity];
            if (_pinValidated) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New PIN"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Done", nil];
                [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput]; // Gives us the pin field
                alert.tag = kAlertTypeSetup;
                
                UITextField *pinField = [alert textFieldAtIndex:0];
                pinField.delegate = self;
                pinField.placeholder = @"Pin";
                pinField.tag = kTextFieldSetup;
                [alert show];
            }
            else {
                [self showNotification:@"Wrong Pin"];
            }
        }
    }
    _pinValidated = NO;
    _selectedCard = nil;
    _inputPIN = nil;
    
}

- (BOOL)usePin {
    BOOL pin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    if (pin) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setPinValidity {
    if (_inputPIN) {
        NSUInteger fieldHash = [_inputPIN hash]; // Get the hash of the entered PIN, minimize contact with the real password
        if ([KeychainWrapper compareKeychainValueForMatchingPIN:fieldHash]) { // Compare them
            NSLog(@"** User Authenticated!!");
            _pinValidated = YES;
        } else {
            NSLog(@"** Wrong Password :(");
            _pinValidated = NO;
        }
    }
}

- (void)storePin {
    if (_inputPIN) {
        NSUInteger fieldHash = [_inputPIN hash];
        NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
        NSLog(@"** Password Hash - %@", fieldString);
        // Save PIN hash to the keychain (NEVER store the direct PIN)
        if ([KeychainWrapper createKeychainValue:fieldString forIdentifier:PIN_SAVED]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_SAVED];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"** Key saved successfully to Keychain!!");
        }
    }
}

- (void)setPIN {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setup PIN"
                                                    message:@"Secure your cards"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput]; // Gives us the pin field
    alert.tag = kAlertTypeSetup;
    
    UITextField *pinField = [alert textFieldAtIndex:0];
    pinField.delegate = self;
    pinField.placeholder = @"Pin";
    pinField.tag = kTextFieldSetup;
    [alert show];
}

- (void)resetPIN {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter old PIN"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput]; // Gives us the pin field
    alert.tag = kAlertTypeReset;
    
    UITextField *pinField = [alert textFieldAtIndex:0];
    pinField.delegate = self;
    pinField.placeholder = @"Pin";
    pinField.tag = kTextFieldReset;
    [alert show];
}

- (void)changePIN {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter old PIN"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput]; // Gives us the pin field
    alert.tag = kAlertTypeChange;
    
    UITextField *pinField = [alert textFieldAtIndex:0];
    pinField.delegate = self;
    pinField.placeholder = @"Pin";
    pinField.tag = kTextFieldChange;
    [alert show];
}




@end
