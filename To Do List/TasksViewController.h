//
//  TasksViewController.h
//  To Do List
//
//  Created by Long Le on 4/1/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditTaskViewController.h"
#import "Task.h"


@interface TasksViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>


@property (nonatomic, strong) Task *task;
@property NSMutableArray *tasksArray;
@property NSNumber *list_category_id_number;
@property NSString *listTitle;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTask;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButtonPushed;

@end
