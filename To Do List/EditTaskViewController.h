//
//  EditTaskViewController.h
//  To Do List
//
//  Created by Long Le on 4/1/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface EditTaskViewController : UIViewController 

@property (nonatomic, strong) Task *task;
@property NSString *name;
@property NSString *task_description;
@property NSMutableArray *tasksArray;
@property NSNumber *list_category_id_number;
@property BOOL isCompleted;
@property NSString *dueDateString;

@property (weak, nonatomic) IBOutlet UILabel *dueDate;
@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *doneButtonPressed;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *markCompleted;


@end
