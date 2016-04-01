//
//  Task+CoreDataProperties.h
//  
//
//  Created by Long Le on 3/31/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface Task (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *id_number;
@property (nullable, nonatomic, retain) NSNumber *category_id;
@property (nullable, nonatomic, retain) NSString *task_description;
@property (nullable, nonatomic, retain) NSDate *due_date;
@property (nonatomic) BOOL isCompleted;
@property (nullable, nonatomic, retain) List *list;

@end

NS_ASSUME_NONNULL_END
