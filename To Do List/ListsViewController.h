//
//  TasksViewControllerTableViewController.h
//  To Do List
//
//  Created by Long Le on 3/31/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditListViewController.h"
#import "List.h"


@interface ListsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) List *list;
@property NSMutableArray *listsArray;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editTableView;


@end
