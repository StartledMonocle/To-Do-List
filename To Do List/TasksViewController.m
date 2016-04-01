//
//  TasksViewController.m
//  To Do List
//
//  Created by Long Le on 4/1/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import "TasksViewController.h"
#import "TaskCell.h"

@interface TasksViewController ()

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tasksArray = [[NSMutableArray alloc] init];
    
    [self setTitle: self.listTitle];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
        
    [self fetchAllLists];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonPushed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)fetchAllLists {
    
    //Fetch all tasks with the category_id_number equal to list_category_id_number (presenting view controller's list cell's id_number)
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"category_id == %li", [self.list_category_id_number integerValue]];
    
    NSArray *tempTasksArray = [Task MR_findAllWithPredicate:predicate];

    [self.tasksArray removeAllObjects];
    [self.tasksArray addObjectsFromArray:tempTasksArray];
    
    
    //Sort tasksArray by category_id
    [self.tasksArray sortUsingDescriptors:
     @[
       [NSSortDescriptor sortDescriptorWithKey:@"id_number" ascending:YES],
       ]];
    
    //Sort tasksArray by isCompleted
    [self.tasksArray sortUsingDescriptors:
     @[
       [NSSortDescriptor sortDescriptorWithKey:@"isCompleted" ascending:YES],
       ]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tasksArray count];
}

- (IBAction)addList:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditTaskViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"EditTaskViewController"];
    [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
    
    //Set category_id for new task to current list's id_number
    viewController.list_category_id_number = [NSNumber numberWithInt: [self.list_category_id_number integerValue]];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)editButtonPushed:(id)sender {
    if (![self.tableView isEditing])
        [self.tableView setEditing:YES animated:YES];
    else
        [self.tableView setEditing:NO animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog (@"sourceIndexPath.row = %lu", sourceIndexPath.row);
    NSLog (@"destinationIndexPath.row = %lu", destinationIndexPath.row);
    
    //Remove task from array
    Task *taskToRemove = [self.tasksArray objectAtIndex:sourceIndexPath.row];
    [self.tasksArray removeObject:taskToRemove];
    [self.tasksArray insertObject:taskToRemove atIndex:destinationIndexPath.row];
    
    
    for (Task *task in self.tasksArray) {
        NSLog (@"before list.id_number = %@", task.id_number);
    }
    
    //Delete all task entities
    [Task MR_truncateAll];
    
    //Recreate all task entities based on whats in self.tasksArray
    for (int i = 0; i < self.tasksArray.count; i++) {
        
        Task *taskFromArray = [self.tasksArray objectAtIndex:i];
        Task *newTask = [Task MR_createEntity];
        newTask.name = taskFromArray.name;
        newTask.due_date = taskFromArray.due_date;
        newTask.id_number = [NSNumber numberWithInt:i];
        newTask.isCompleted = taskFromArray.isCompleted;
    }
    
    //Save it
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
    } completion:^(BOOL success, NSError *error){
        [self fetchAllLists];
        for (Task *task in self.tasksArray) {
            NSLog (@"after list.id_number = %@", task.id_number);
        }
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Task *taskToRemove = self.tasksArray[indexPath.row];
        
        // Deleting an Entity with MagicalRecord
        [taskToRemove MR_deleteEntity];
        
        [self fetchAllLists];
        
        //Save
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
        } completion:^(BOOL success, NSError *error){
            
            [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        
    }   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TaskCell *cell = (TaskCell*)[tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    
    Task *task = (self.tasksArray)[indexPath.row];
    
    task.id_number = [NSNumber numberWithInt:indexPath.row];
    cell.taskName.text = task.name;
    //Set due date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:task.due_date];
    
    if (task.isCompleted == NO) {
        cell.completionStatus.text = @"Incompleted";
        cell.completionStatus.textColor = [UIColor redColor];
        
        if (dateString)
            cell.dueDate.text = [NSString stringWithFormat:@"Due: %@", dateString];
        else
            cell.dueDate.text = @"No Due Date";
    }
    else if (task.isCompleted == YES)
    {
        cell.completionStatus.text = @"Completed";
        cell.completionStatus.textColor = [UIColor greenColor];
        cell.dueDate.text = [NSString stringWithFormat:@"Completed: %@", dateString];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //If in editing mode, open edit task view
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditTaskViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"EditTaskViewController"];
    [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
    
    //Pass the 'name' corresponding with the entity at the current indexPath to viewController
    Task *task = (self.tasksArray)[indexPath.row];
    viewController.name = task.name;
    viewController.tasksArray = self.tasksArray;
    viewController.task = task;
    viewController.isCompleted = task.isCompleted;
    
    //Set due date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:task.due_date];
    NSLog (@"dateString = %@", dateString);
    viewController.dueDateString = dateString;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
