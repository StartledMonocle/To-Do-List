//
//  EditTaskViewController.m
//  To Do List
//
//  Created by Long Le on 4/1/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import "EditTaskViewController.h"
#import "List.h"
#import "Task.h"

@interface EditTaskViewController ()

@end

@implementation EditTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tasksArray = [[NSMutableArray alloc] init];
    
    //Set 'Mark Complete' button text
    if (self.isCompleted == NO) {
        [self.markCompleted setTitle:@"Mark Complete" forState:UIControlStateNormal];
    }
    else if (self.isCompleted == YES) {
        [self.markCompleted setTitle:@"Mark Incomplete" forState:UIControlStateNormal];
    }
    
    if (!self.name)
        self.taskNameTextField.text = @"New Task";
    else
        self.taskNameTextField.text = self.name;
    
    //Set due date label
    if (self.dueDateString)
        self.dueDate.text = self.dueDateString;
    else
        [self datePickerChanged:_datePicker];
    
    [self.datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)datePickerChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:datePicker.date];
    self.dueDate.text = dateString;
    
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    //set entity's due_date property
    self.task.due_date = dateFromString;
}
- (IBAction)markCompleted:(id)sender {
    
    if (self.isCompleted == NO) {
        [self.markCompleted setTitle:@"Mark Incompleted" forState:UIControlStateNormal];
        self.isCompleted = YES;
    }
    else if (self.isCompleted == YES) {
        [self.markCompleted setTitle:@"Mark Completed" forState:UIControlStateNormal];
        self.isCompleted = NO;
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    
    //If you're adding a new task
    if (!self.task) {
        
        //Create new entity
        Task *task = [Task MR_createEntity];
        
        //Set its name to whats in the text box
        task.name = self.taskNameTextField.text;
        //Set id_number to its current index in tasksArray
        task.id_number = [NSNumber numberWithInt:[self.tasksArray count]];
        //Set category_id (list id_number for which this task belongs)
        task.category_id = self.list_category_id_number;
        //Set task due_date
        task.due_date = _datePicker.date;
        //Set Completion status
        task.isCompleted = self.isCompleted;
        
        //Save
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
        } completion:^(BOOL success, NSError *error){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    //If you're editing an existing list
    else {
        //Set its name to whats in the text box
        self.task.name = self.taskNameTextField.text;
        //Set task due_date
        self.task.due_date = _datePicker.date;
        //Set Completion status
        self.task.isCompleted = self.isCompleted;
        
        //Save
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
        } completion:^(BOOL success, NSError *error){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
