//
//  CVCompoundPredicateFilter.m
//  Copyright (c) 2013 Kasper Timm Hansen. All rights reserved.
//

#import "CVCompoundPredicateFilter.h"

@interface CVCompoundPredicateFilter ()

@property (nonatomic, strong) NSMutableArray *predicateFilterStack;

@end

@implementation CVCompoundPredicateFilter

- (NSArray *)predicateFilters
{
    return [self.predicateFilterStack copy];
}

- (NSArray *)filters
{
    if (![self.predicateFilterStack count])
        return nil;
    
    return [self.predicateFilterStack[0] filters];
}

#pragma mark - CVPredicateFilter

- (NSArray *)filteredObjects
{
    NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[self.predicateFilterStack count]];
    for (CVPredicateFilter *predicateFilter in self.predicateFilterStack)
        [filteredObjects addObject:predicateFilter.filteredObjects];
    return filteredObjects;
}

- (void)setTemplatePredicate:(NSPredicate *)templatePredicate
{
    [super setTemplatePredicate:templatePredicate];
    for (CVPredicateFilter *predicateFilter in self.predicateFilterStack)
        predicateFilter.templatePredicate = templatePredicate;
}

#pragma mark - CVCompoundFilter

- (instancetype)initWithSegmentedObjects:(NSArray *)segmentedObjects templatePredicate:(NSPredicate *)templatePredicate
{
    self = [super init];
    if (!self) return nil;
    
    self.predicateFilterStack = [NSMutableArray arrayWithCapacity:[segmentedObjects count]];
    for (NSArray *objects in segmentedObjects)
        [self addPredicateFilter:[CVPredicateFilter filterWithObjects:objects]];
    
    self.templatePredicate = templatePredicate;
    
    return self;
}

+ (instancetype)compoundFilterWithSegmentedObjects:(NSArray *)segmentedObjects templatePredicate:(NSPredicate *)templatePredicate
{
    return [[self alloc] initWithSegmentedObjects:segmentedObjects templatePredicate:templatePredicate];
}

#pragma mark -

- (void)removePredicateFilter:(CVPredicateFilter *)filter
{
    [self.predicateFilterStack removeObject:filter];
}

- (void)addPredicateFilter:(CVPredicateFilter *)filter
{
    [self.predicateFilterStack addObject:filter];
    filter.filterGroup = self.filterGroup;
    filter.filterQueue = self.filterQueue;
}

- (void)pushFilter:(NSPredicate *)filter withCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler
{
    NSMutableArray *combinedFilteredResults = [NSMutableArray arrayWithCapacity:[self.predicateFilterStack count]];
    for (CVPredicateFilter *predicateFilter in self.predicateFilterStack) {
        [predicateFilter pushFilter:filter withCompletionHandler:^(NSArray *filteredResults) {
            [combinedFilteredResults addObject:filteredResults];
        }];
    }
    
    dispatch_group_notify(self.filterGroup, dispatch_get_main_queue(), ^{
        if (completionHandler)
            completionHandler(combinedFilteredResults);
    });
}

- (void)popToFilterAtIndex:(NSUInteger)index withCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler
{
    for (CVPredicateFilter *predicateFilter in self.predicateFilterStack)
        [predicateFilter popToFilterAtIndex:index];
    
    if (completionHandler)
        completionHandler(self.filteredObjects);
}

@end
