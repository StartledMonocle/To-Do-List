//
//  List+CoreDataProperties.h
//  
//
//  Created by Long Le on 3/31/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "List.h"

NS_ASSUME_NONNULL_BEGIN

@interface List (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *id_number;
@property (nullable, nonatomic, retain) Task *task;

@end

NS_ASSUME_NONNULL_END
