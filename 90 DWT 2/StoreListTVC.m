//
//  StoreListTVC.m
//  90 DWT 1
//
//  Created by Grant, Jared on 5/10/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import "StoreListTVC.h"
#import "StoreListTVCCell.h"

// 1
#import "DWT2IAPHelper.h"
#import <StoreKit/StoreKit.h>

// 2
@interface StoreListTVC () {
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}
@end

@implementation StoreListTVC

// 3
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"shop_cart_selected"];
    
    UIImage *backgroundImage;
    UIColor *backgroundColor;
    UIImage *cellbackgroundImage;
    UIColor *cellbackgroundColor;
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundView:[[UIView alloc] init]];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]]; // this is for iPhone
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        // iPad
        backgroundImage = [UIImage imageNamed:@"background-iPad-darkgrey.png"];
        backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        
        cellbackgroundImage = [UIImage imageNamed:@"tableviewcell-iPad-darkgrey.png"];
        cellbackgroundColor = [UIColor colorWithPatternImage:cellbackgroundImage];
        
    }
    else {
        // iPhone
        backgroundImage = [UIImage imageNamed:@"background-iPhone-darkgrey.png"];
        backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        
        cellbackgroundImage = [UIImage imageNamed:@"tableviewcell-iPhone-darkgrey.png"];
        cellbackgroundColor = [UIColor colorWithPatternImage:cellbackgroundImage];
    }
    
    // TableView background color
    self.tableView.backgroundColor = backgroundColor;


    self.title = @"Store";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    // Add to end of viewDidLoad
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    // Add to end of viewDidLoad
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 4
- (void)reload {
    _products = nil;
    [self.tableView reloadData];
    [[DWT2IAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[DWT2IAPHelper sharedInstance] buyProduct:product];
}

- (void)restoreTapped:(id)sender {
    [[DWT2IAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// 5
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreListTVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    [_priceFormatter setLocale:product.priceLocale];
    
    cell.titleLabel.text = product.localizedTitle;
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.descriptionLabel.text = product.localizedDescription;
    cell.priceLabel.text = [_priceFormatter stringFromNumber:product.price];
    cell.buyButton.tag = indexPath.row;
    
    cell.priceLabel.textColor = [UIColor colorWithRed:48/255.0f green:137/255.0f blue:210/255.0f alpha:1];
    
    if ([[DWT2IAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.buyButton.hidden = YES;
        
    } else {
        
        [cell.buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // Configure tableview.
    NSArray *tableCell = @[cell];
    NSArray *accessoryIcon = @[@NO];
    [self configureTableView:tableCell :accessoryIcon];
     
    
    return cell;
     
}

@end
