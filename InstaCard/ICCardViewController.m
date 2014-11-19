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
#import "ICCardCell.h"
#import "ICUtils.h"

@interface ICCardViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ICCardViewController

static NSString *CellIdentifier = @"ICCardCell";
static NSString *kCardEntity = @"ICCard";
static NSString *kShowDetailSegueID = @"showDetail";

static NSString *kCardViewControllerStoryBoardID = @"cardViewController";
static NSString *kCardDetailViewControllerStoryBoardID = @"cardDetailViewController";
static NSString *kCardEditViewControllerStoryBoardID = @"cardEditViewController";

- (void)viewWillAppear:(BOOL)animated {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height - self.navigationController.navigationBar.frame.size.height;
    
    CGFloat itemWidth = (screenWidth)/3.0;
    CGFloat itemHeight = (screenHeight)/4.0;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    [self.fetchedResultsController performFetch:nil];
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        [self insertDefaultData];
        [self.fetchedResultsController performFetch:nil];
    }
    
    [self setViewTitle];
}

- (void)setViewType:(int16_t)type {
    _viewType = type;
}

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

- (void) addDefaultCard:(NSString*)name icon:(NSString*)iconName type:(ICCardType)type inContext:(NSManagedObjectContext*)context {
    ICCard *cardData = [NSEntityDescription insertNewObjectForEntityForName:kCardEntity inManagedObjectContext:context];
    cardData.cardName = name;
    cardData.type = type;
    cardData.iconName = iconName;
    cardData.createdAt = [[NSDate date] timeIntervalSince1970];
}

- (void)insertDefaultPersonalCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"PAN Card" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Passport" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Aaadhar Card" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Driver's License" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Insurance Card" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Ration Card" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Voter ID Card" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Membership Card" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Credit Cards" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Debit Cards" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Loyalty Cards" icon:@"bank-mini-white" type:ICPersonal inContext:context];
    [self addDefaultCard:@"Policies" icon:@"bank-mini-white" type:ICPersonal inContext:context];
}

- (void)insertDefaultLoyaltyCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"Apollo Pharmacy" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Body Shop" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Crossword" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Hypercity" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Jet Privilege" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Louis Phillippe" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Marks & Spencers" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Reliance" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Religare" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Shoppers Stop" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Van Heusen" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
    [self addDefaultCard:@"Westside" icon:@"bank-mini-white" type:ICLoyalty inContext:context];
}

- (void)insertDefaultPolicyCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"PPF" icon:@"bank-mini-white" type:ICPolicy inContext:context];
    [self addDefaultCard:@"Mutual Funds" icon:@"bank-mini-white" type:ICPolicy inContext:context];
    [self addDefaultCard:@"NSC" icon:@"bank-mini-white" type:ICPolicy inContext:context];
}

- (void)insertDefaultBankDebitCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"SBI" icon:@"bank-mini-white" type:ICBankDebit inContext:context];
    [self addDefaultCard:@"HDFC" icon:@"bank-mini-white" type:ICBankDebit inContext:context];
    [self addDefaultCard:@"ICICI" icon:@"bank-mini-white" type:ICBankDebit inContext:context];
}

- (void)insertDefaultBankCreditCards:(NSManagedObjectContext*)context {
    [self addDefaultCard:@"SBI" icon:@"bank-mini-white" type:ICBankCredit inContext:context];
    [self addDefaultCard:@"HDFC" icon:@"bank-mini-white" type:ICBankCredit inContext:context];
    [self addDefaultCard:@"ICICI" icon:@"bank-mini-white" type:ICBankCredit inContext:context];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

#pragma mark UICollectionViewDataSource
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
        ICCardDetailViewController* cardDetailController = [self.storyboard instantiateViewControllerWithIdentifier:kCardDetailViewControllerStoryBoardID];
        cardDetailController.card = card;
        [self.navigationController pushViewController:cardDetailController animated:YES];
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

- (IBAction)addCard:(id)sender {
    ICCardEditViewController* addCardController = [self.storyboard instantiateViewControllerWithIdentifier:kCardEditViewControllerStoryBoardID];
    addCardController.card = nil;
    [addCardController setCardType:_viewType];
    [self.navigationController pushViewController:addCardController animated:YES];
}
@end
