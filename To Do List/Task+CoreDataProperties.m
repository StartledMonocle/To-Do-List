//
//  Task+CoreDataProperties.m
//  
//
//  Created by Long Le on 3/31/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Task+CoreDataProperties.h"

@implementation Task (CoreDataProperties)

@dynamic name;
@dynamic id_number;
@dynamic category_id;
@dynamic task_description;
@dynamic due_date;
@dynamic isCompleted;
@dynamic list;

@end
