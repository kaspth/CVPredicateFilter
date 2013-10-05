//
//  CVPredicateFilter.h
//  Copyright (c) 2013 Kasper Timm Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>;

typedef void(^CVPredicateFilterCompletionHandler)(NSArray *filteredObjects);

@interface CVPredicateFilter : NSObject

///@brief Provide a template predicate to filter from.
///@discussion Use a predicate with substitution values and call -pushFilterWithSubstitutionValues:
@property (nonatomic, strong) NSPredicate *templatePredicate;

///@brief The objects to filter.
@property (nonatomic, strong) NSArray *objects;

///@brief An array of NSPredicates used to filter the objects.
@property (nonatomic, readonly) NSArray *filters;

///@brief An array of the results from the current most filter.
///@discussion Returns the objects if no filters have been run.
@property (nonatomic, readonly) NSArray *filteredObjects;

///@brief The queue to run filters on. Default is a serial queue with default priority.
@property (nonatomic, strong) dispatch_queue_t filterQueue;

///@brief A dispatch group useful for batching filters. Default is a
@property (nonatomic, strong) dispatch_group_t filterGroup;

- (instancetype)initWithObjects:(NSArray *)objects;
- (instancetype)initWithObjects:(NSArray *)objects templatePredicate:(NSPredicate *)templatePredicate;

+ (instancetype)filterWithObjects:(NSArray *)objects;
+ (instancetype)filterWithObjects:(NSArray *)objects templatePredicate:(NSPredicate *)templatePredicate;

- (void)popFilter;
- (void)popFilterWithCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler;

///@brief Pop all filters. filteredObjects will be the same as objects.
- (void)popFilters;
- (void)popFiltersWithCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler;

///@brief Pop to a specific filter.
///@discussion filteredObjects will contain the results from filter.
- (void)popToFilter:(NSPredicate *)filter;
- (void)popToFilter:(NSPredicate *)filter withCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler;

///@discussion filteredObjects will contain the results at index. This is the base popFilter method. All other variants call this.
- (void)popToFilterAtIndex:(NSUInteger)index;

///@discussion The completionHandler will pass in the latest filteredObjects left.
- (void)popToFilterAtIndex:(NSUInteger)index withCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler;

///@brief This uses the templatePredicate and calls -predicateWithSubstitutionValues:
- (void)pushFilterWithSubstitutionValues:(NSDictionary *)values;
- (void)pushFilterWithSubstitutionValues:(NSDictionary *)values completionHandler:(CVPredicateFilterCompletionHandler)completionHandler;

///@brief Pushes a new filter, sidestepping templatePredicate.
///@discussion Base -pushFilter method. All other variants call this. The previous filteredObjects will be filtered further. The filtering happens in the background on the filterQueue and filterGroup.
- (void)pushFilter:(NSPredicate *)filter;
- (void)pushFilter:(NSPredicate *)filter withCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler;


@end
