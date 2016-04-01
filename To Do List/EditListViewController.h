//
//  EditItemViewController.h
//  To Do List
//
//  Created by Long Le on 3/31/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class List;

@interface EditListViewController : UIViewController

@property (nonatomic, strong) List *list;
@property NSString *name;
@property NSMutableArray *listsArray;

@property (weak, nonatomic) IBOutlet UITextField *listNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *doneButtonPressed;

@end
