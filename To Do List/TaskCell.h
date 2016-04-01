//
//  TaskCell.h
//  To Do List
//
//  Created by Long Le on 4/1/16.
//  Copyright © 2016 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *taskName;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;
@property (weak, nonatomic) IBOutlet UILabel *completionStatus;



@end
