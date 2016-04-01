//
//  EditItemViewController.m
//  To Do List
//
//  Created by Long Le on 3/31/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import "EditListViewController.h"
#import "List.h"
#import "Task.h"

@interface EditListViewController ()

@end

@implementation EditListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listsArray = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view.
    if (!self.name)
        self.listNameTextField.text = @"New List";
    else
        self.listNameTextField.text = self.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    
    //If you're adding a new list
    if (!self.list) {
        
        //Create new entity
        List *list = [List MR_createEntity];
        
        //Set its name to whats in the text box
        list.name = self.listNameTextField.text;
        //Set id_number to its current index in listsArray
        list.id_number = [NSNumber numberWithInt:[self.listsArray count]];
        
        //Save
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
        } completion:^(BOOL success, NSError *error){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    //If you're editing an existing list
    else {
        self.list.name = self.listNameTextField.text;

        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
        } completion:^(BOOL success, NSError *error){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
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
