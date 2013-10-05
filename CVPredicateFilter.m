//
//  CVPredicateFilter.m
//  Copyright (c) 2013 Kasper Timm Hansen. All rights reserved.
//

#import "CVPredicateFilter.h"

@interface CVPredicateFilter ()

///@brief The results of a filter are pushed onto this stack.
@property (atomic, strong) NSMutableArray *resultStack;

@property (atomic, strong) NSMutableArray *filterStack;

@property (atomic, getter = isFiltering) BOOL filtering;

@end

@implementation CVPredicateFilter

#pragma mark - NSObject

- (instancetype)init
{
    return [self initWithObjects:nil templatePredicate:nil];
}

#pragma mark -

- (instancetype)initWithObjects:(NSArray *)objects
{
    return [self initWithObjects:objects templatePredicate:nil];
}

- (instancetype)initWithObjects:(NSArray *)objects templatePredicate:(NSPredicate *)templatePredicate
{
    self = [super init];
    if (!self) return nil;
    
    self.resultStack = [NSMutableArray array];
    self.filterStack = [NSMutableArray array];
    self.filtering = NO;
    
    self.objects = objects;
    self.templatePredicate = templatePredicate;
    
    return self;
}

+ (instancetype)filterWithObjects:(NSArray *)objects
{
    return [self filterWithObjects:objects templatePredicate:nil];
}

+ (instancetype)filterWithObjects:(NSArray *)objects templatePredicate:(NSPredicate *)templatePredicate
{
    return [[self alloc] initWithObjects:objects templatePredicate:templatePredicate];
}

#pragma mark -

- (NSArray *)filteredObjects
{
    return [self.resultStack lastObject] ?: self.objects;
}

- (NSArray *)filters
{
    return [self.filterStack copy];
}

- (dispatch_queue_t)filterQueue
{
    if (!_filterQueue)
        _filterQueue = dispatch_queue_create("com.currency.predicate_filter.filter_queue", DISPATCH_QUEUE_SERIAL);
    
    return _filterQueue;
}

- (dispatch_group_t)filterGroup
{
    if (!_filterGroup)
        _filterGroup = dispatch_group_create();
    
    return _filterGroup;
}

#pragma mark -

- (void)popFilter
{
    [self popFilterWithCompletionHandler:nil];
}

- (void)popFilterWithCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler
{
    [self popToFilterAtIndex:[self previousFilterIndex] withCompletionHandler:completionHandler];
}

- (void)popFilters
{
    [self popFiltersWithCompletionHandler:nil];
}

- (void)popFiltersWithCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler
{
    [self popToFilterAtIndex:0 withCompletionHandler:completionHandler];
}

- (void)popToFilter:(NSPredicate *)filter
{
    [self popToFilter:filter withCompletionHandler:nil];
}

- (void)popToFilter:(NSPredicate *)filter withCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler
{
    [self popToFilterAtIndex:[self.filterStack indexOfObject:filter] withCompletionHandler:completionHandler];
}

- (void)popToFilterAtIndex:(NSUInteger)index
{
    [self popToFilterAtIndex:index withCompletionHandler:nil];
}

- (void)popToFilterAtIndex:(NSUInteger)index withCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler
{
    if (index == NSNotFound || [self.filterStack count] == 0 || index >= [self.filterStack count])
        return;
    
    NSRange removalRange = NSMakeRange(index, [self.filterStack count] - index);
    [self.filterStack removeObjectsInRange:removalRange];
    [self.resultStack removeObjectsInRange:removalRange];
    
    if (completionHandler)
        completionHandler(self.filteredObjects);
}

#pragma mark -

- (void)pushFilterWithSubstitutionValues:(NSDictionary *)values
{
    [self pushFilterWithSubstitutionValues:values completionHandler:nil];
}

- (void)pushFilterWithSubstitutionValues:(NSDictionary *)values completionHandler:(CVPredicateFilterCompletionHandler)completionHandler
{
    [self pushFilter:[self.templatePredicate predicateWithSubstitutionVariables:values] withCompletionHandler:completionHandler];
}

- (void)pushFilter:(NSPredicate *)filter
{
    [self pushFilter:filter withCompletionHandler:nil];
}

- (void)pushFilter:(NSPredicate *)filter withCompletionHandler:(CVPredicateFilterCompletionHandler)completionHandler
{
    if (self.isFiltering || !filter)
        return;
    
    dispatch_group_async(self.filterGroup, self.filterQueue, ^{
        self.filtering = YES;
        
        [self.filterStack addObject:filter];
        NSArray *results = [self.filteredObjects filteredArrayUsingPredicate:filter];
        [self.resultStack addObject:results];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler)
                completionHandler(results);
            self.filtering = NO;
        });
    });
}

#pragma mark - Private

- (NSUInteger)previousFilterIndex
{
    return [self.filterStack count] - 2;
}

@end
