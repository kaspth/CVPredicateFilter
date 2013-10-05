//
//  CVCompoundPredicateFilter.h
//  Copyright (c) 2013 Kasper Timm Hansen. All rights reserved.
//

#import "CVPredicateFilter.h"

///@brief CVCompoundPredicateFilter makes several CVPredicateFilters appear as one.
@interface CVCompoundPredicateFilter : CVPredicateFilter

///@brief The predicate filters which can filter separate objects
@property (nonatomic, readonly) NSArray *predicateFilters;

///@brief Creates a CVPredicateFilter for every array in segmentedObjects.
///@param segmentedObjects An array of arrays.
- (instancetype)initWithSegmentedObjects:(NSArray *)segmentedObjects templatePredicate:(NSPredicate *)templatePredicate;
+ (instancetype)compoundFilterWithSegmentedObjects:(NSArray *)segmentedObjects templatePredicate:(NSPredicate *)templatePredicate;

- (void)removePredicateFilter:(CVPredicateFilter *)filter;
- (void)addPredicateFilter:(CVPredicateFilter *)filter;

@end
