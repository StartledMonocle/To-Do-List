//
//  TasksViewControllerTableViewController.m
//  To Do List
//
//  Created by Long Le on 3/31/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import "ListsViewController.h"
#import "AFNetworking.h"
#import "ListCell.h"
#import "TasksViewController.h"

@interface ListsViewController ()

@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.listsArray = [[NSMutableArray alloc] init];
    
    [self makeJSONRequests];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self fetchAllLists];
    [self.tableView reloadData];
}

- (void)fetchAllLists {

    NSArray *tempListArray = [List MR_findAll];
    [self.listsArray removeAllObjects];
    [self.listsArray addObjectsFromArray:tempListArray];
    [self.tableView reloadData];
    
    [self.listsArray sortUsingDescriptors:
     @[
       [NSSortDescriptor sortDescriptorWithKey:@"id_number" ascending:YES]]];
}

- (void)deleteTask: (int)id_number {
    
    [self deleteTask:id_number];
}

- (void) updateTask: (int)id_number name:(NSString*)nameArg category_id:(int)category_id dueDate:(NSDate*)dueDateArg isComplete: (int) isCompleteArg {

    TasksViewController *taskView = [[TasksViewController alloc] init];
    for (Task *task in taskView.tasksArray) {
        if ([task.id_number integerValue] == id_number && [task.category_id integerValue] == category_id) {
            task.id_number = [NSNumber numberWithInt:id_number];
            task.name = nameArg;
            task.category_id = [NSNumber numberWithInt:category_id];
            task.due_date = dueDateArg;
            task.isCompleted = isCompleteArg;
        }
    }
}


- (void)createTask: (int)id_number name:(NSString*)nameArg category_id:(int)category_id dueDate:(NSDate*)dueDateArg isComplete: (int) isCompleteArg {
    
    BOOL taskAlreadyExists = NO;
    
    NSArray *tempTasksArray = [Task MR_findAll];
    NSMutableArray *tasksArray = [[NSMutableArray alloc] init];
    [tasksArray addObjectsFromArray:tempTasksArray];
    
    //Make sure a task of the same name does not yet exist
    for (Task *task in tasksArray) {
        if ([task.name isEqualToString:nameArg] && (int)[task.category_id integerValue] == category_id) {
            taskAlreadyExists = YES;
            NSLog (@"task already exists!");
        }
    }
    
    if (taskAlreadyExists == NO) {
    
        //Create new entity
        Task *task = [Task MR_createEntity];
        
        //Set its name to whats in the text box
        task.name = nameArg;
        //Set id_number to its current index in tasksArray. Subtract 1 since JSON objects seem to start at 1 ... n. This way the task id_numbers correspond with our categories
        task.id_number = [NSNumber numberWithInt: id_number - 1];
        //Set category_id (list id_number for which this task belongs)
        task.category_id = [NSNumber numberWithInt: category_id];
        //Set task due_date
        task.due_date = dueDateArg;
        //Set Completion status
        task.isCompleted = isCompleteArg;
        
        //Save
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
        } completion:^(BOOL success, NSError *error) {
            [self fetchAllLists];
        }];
    }
}

- (void)createCategory: (int)id_number name:(NSString*)nameArg {
    
    BOOL categoryAlreadyExists = NO;
    
    NSArray *tempListsArray = [List MR_findAll];
    NSMutableArray *listsArray = [[NSMutableArray alloc] init];
    [listsArray addObjectsFromArray:tempListsArray];
    
    //Make sure a category of the same name does not yet exist
    for (List *list in listsArray) {
        if ([list.name isEqualToString:nameArg]) {
            categoryAlreadyExists = YES;
            NSLog (@"category already exists!");
        }
    }
    
    if (categoryAlreadyExists == NO)
    {
        //Create new entity
        List *list = [List MR_createEntity];
        
        //Set its name to whats in the text box
        list.name = nameArg;
        //Set id_number to its current index in listsArray
        list.id_number = [NSNumber numberWithInt: id_number];
        
        //Save
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
        } completion:^(BOOL success, NSError *error){
            [self fetchAllLists];
        }];
    }
}

- (void)makeJSONRequests {
    
    NSLog (@"makeJSONRequests");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //web services are sending text/html instead of json as stated in the iOS test directions, so adding this line to accept the the web service payload as a text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:@"https://api.fusionofideas.com/todo/getCategories.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Web Service 6: %@", responseObject);
        
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        NSArray *status = [jsonDict objectForKey:@"status"];
        
        if ([status isEqual: @"OK"]) {
            NSLog (@"Yay stuff to parse through");
            
            NSArray *products = [jsonDict objectForKey:@"content"];
            
            //Parse through products array
            for (NSDictionary *content in products) {
                NSInteger id_number = [content[@"id"] integerValue];
                NSString *name = content[@"name"];
                
                //Subtracting 1 here since the categories start at 1 which is an issue for our tableView. We want them to start at 0
                [self createCategory:id_number -1 name:name];
            }
        }
        else {
            NSLog (@"no pay load");
        }
        
        NSArray *tempListsArray = [List MR_findAll];
        NSMutableArray *listsArray = [[NSMutableArray alloc] init];
        [listsArray addObjectsFromArray:tempListsArray];
        
        //GetCategories finished, run addCategory next
        [manager GET:@"https://api.fusionofideas.com/todo/addCategory.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Web Service 5: %@", responseObject);
            
            NSDictionary *jsonDict = (NSDictionary *) responseObject;
            NSArray *status = [jsonDict objectForKey:@"status"];
            
            if ([status isEqual: @"OK"]) {
                NSLog (@"Yay stuff to parse through");
                
                NSArray *products = [jsonDict objectForKey:@"content"];
                
                //Parse through products array
                for (NSDictionary *content in products) {
                    NSInteger id_number = [content[@"id"] integerValue];
                    NSString *name = content[@"name"];
                    
                    [self createCategory:id_number name:name];
                }
            }
            else {
                NSLog (@"no pay load");
            }
            
            //addCategory finished, run getItems
            [manager GET:@"https://api.fusionofideas.com/todo/getItems.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Web Service 2: %@", responseObject);
                
                NSDictionary *jsonDict = (NSDictionary *) responseObject;
                NSArray *status = [jsonDict objectForKey:@"status"];
                
                if ([status isEqual: @"OK"]) {
                    NSLog (@"Yay stuff to parse through");
                    
                    NSArray *products = [jsonDict objectForKey:@"content"];
                    
                    //Parse through products array
                    for (NSDictionary *content in products) {
                        NSInteger id_number = [content[@"id"] integerValue];
                        NSString *name = content[@"name"];
                        NSInteger category_id = [content[@"category_id"] integerValue];
                        int isComplete = [content[@"completed"] integerValue];
                        
                        //Convert NSString to NSDate
                        NSString *dueDateString = content[@"due"];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSDate *dueDate = [dateFormatter dateFromString:dueDateString];
                        
                        [self createTask:id_number name:name category_id:category_id dueDate:dueDate isComplete:isComplete];
                    }
                }
                else {
                    NSLog (@"no pay load");
                }
                
                
                //GetItems finished, run addItem
                [manager GET:@"https://api.fusionofideas.com/todo/addItem.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"Web Service 1: %@", responseObject);
                    
                    NSDictionary *jsonDict = (NSDictionary *) responseObject;
                    NSArray *status = [jsonDict objectForKey:@"status"];
                    
                    if ([status isEqual: @"OK"]) {
                        NSLog (@"Yay stuff to parse through");
                        
                        NSArray *products = [jsonDict objectForKey:@"content"];
                        
                        //Parse through products array
                        for (NSDictionary *content in products) {
                            NSInteger id_number = [content[@"id"] integerValue];
                            NSString *name = content[@"name"];
                            NSInteger category_id = [content[@"category_id"] integerValue];
                            
                            //Convert NSString to NSDate
                            NSString *dueDateString = content[@"due"];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            NSDate *dueDate = [dateFormatter dateFromString:dueDateString];
                            
                            [self createTask:id_number name:name category_id:category_id dueDate:dueDate isComplete:nil];
                        }
                    }
                    else {
                        NSLog (@"no pay load");
                    }
                    
                    //GetItems finished, run updateItem
                    [manager GET:@"https://api.fusionofideas.com/todo/updateItem.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"Web Service 4: %@", responseObject);
                        
                        NSDictionary *jsonDict = (NSDictionary *) responseObject;
                        NSArray *status = [jsonDict objectForKey:@"status"];
                        
                        if ([status isEqual: @"OK"]) {
                            NSLog (@"Yay stuff to parse through");
                            
                            NSArray *products = [jsonDict objectForKey:@"content"];
                            
                            //Parse through products array
                            for (NSDictionary *content in products) {
                                NSInteger id_number = [content[@"id"] integerValue];
                                NSString *name = content[@"name"];
                                NSInteger category_id = [content[@"category_id"] integerValue];
                                
                                //Convert NSString to NSDate
                                NSString *dueDateString = content[@"due"];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                NSDate *dueDate = [dateFormatter dateFromString:dueDateString];
                                
                                [self createTask:id_number name:name category_id:category_id dueDate:dueDate isComplete:nil];
                            }
                        }
                        else {
                            NSLog (@"no pay load");
                        }
                        
                        //Update item finished, run deleteItem
                        [manager GET:@"https://api.fusionofideas.com/todo/deleteItem.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"Web Service 3: %@", responseObject);
                            
                            NSDictionary *jsonDict = (NSDictionary *) responseObject;
                            NSArray *status = [jsonDict objectForKey:@"status"];
                            
                            if ([status isEqual: @"OK"]) {
                                NSLog (@"Yay stuff to parse through");
                                
                                NSArray *products = [jsonDict objectForKey:@"content"];
                                
                                //Parse through products array
                                for (NSDictionary *content in products) {
                                    NSInteger id_number = [content[@"id"] integerValue];

                                    [self deleteTask:id_number];
                                }
                            }
                            else {
                                NSLog (@"no pay load");
                            }
                            
                            
                            //Update item finished, run deleteItem
                            [manager GET:@"https://api.fusionofideas.com/todo/deleteItem.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"Web Service 3: %@", responseObject);
                                
                                NSDictionary *jsonDict = (NSDictionary *) responseObject;
                                NSArray *status = [jsonDict objectForKey:@"status"];
                                
                                if ([status isEqual: @"OK"]) {
                                    NSLog (@"Yay stuff to parse through");
                                    
                                    NSArray *products = [jsonDict objectForKey:@"content"];
                                    
                                    //Parse through products array
                                    for (NSDictionary *content in products) {
                                        NSInteger id_number = [content[@"id"] integerValue];
                                        NSString *name = content[@"name"];
                                        NSInteger category_id = [content[@"category_id"] integerValue];
                                        
                                        //Convert NSString to NSDate
                                        NSString *dueDateString = content[@"due"];
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                        NSDate *dueDate = [dateFormatter dateFromString:dueDateString];
                                        int isComplete = [content[@"completed"] integerValue];
                                        
                                        [self updateTask:id_number name:name category_id:category_id dueDate:dueDate isComplete:isComplete];
                                    }
                                }
                                else {
                                    NSLog (@"no pay load");
                                }
                                
                                
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"Error: %@", error);
                            }];
                            
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error: %@", error);
                        }];
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listsArray count];
}

- (IBAction)addList:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditListViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"EditListViewController"];
    [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)editButtonPushed:(id)sender {
    if (![self.tableView isEditing])
        [self.tableView setEditing:YES animated:YES];
    else
        [self.tableView setEditing:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        List *listToRemove = self.listsArray[indexPath.row];

        // Deleting an Entity with MagicalRecord
        [listToRemove MR_deleteEntity];
        
        [self fetchAllLists];
        
        //Save
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
        } completion:^(BOOL success, NSError *error){
            
            [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];

    }   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ListCell *cell = (ListCell*)[tableView dequeueReusableCellWithIdentifier:@"ListCell"];
    
    List *list = (self.listsArray)[indexPath.row];
    cell.listName.text = list.name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //If in editing mode, open edit list view
    if ([self.tableView isEditing]) {
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EditListViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"EditListViewController"];
        [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
        
        //Pass the 'name' corresponding with the entity at the current indexPath to viewController
        List *list = (self.listsArray)[indexPath.row];
        viewController.name = list.name;
        viewController.listsArray = self.listsArray;
        viewController.list = list;
        
        [self presentViewController:viewController animated:YES completion:nil];
    }
    //Else open corresponding task view
    else {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TasksViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"TasksViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
        
        List *list = (self.listsArray)[indexPath.row];
        //Pass the name the list name to be used in the task view's title
        viewController.listTitle = list.name;
        //Pass in the current index number to set the task view's category_id_number
        viewController.list_category_id_number = [NSNumber numberWithInt: [list.id_number integerValue]];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
