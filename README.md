CVPredicateFilter
=================

Flexible filtering of arrays on a background thread with NSPredicate.

## Usage

Add the dependency to your `Podfile`:

```ruby
platform :ios # or :osx
pod 'CVPredicateFilter'
...
```

Run pod install to install the dependencies.

### CVPredicateFilter

```objc
#import "CVPredicateFilter.h"
```

Instantiate `CVPredicateFilter` with the array to filter:

```objc
NSArray *objects = @[@"a cat", @"a hat", @"and", @"a band"];
CVPredicateFilter *predicateFilter = [CVPredicateFilter filterWithObjects:objects];

NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH 'an'"];

[predicateFilter pushFilter:filter withCompletionHandler:^(NSArray *filteredObjects) {
    NSLog(@"Found matches: %@", filteredObjects); // returns @[@"and"]
}];
```
A `templatePredicate` can also be used to save parsing the predicate format string every time a filter is pushed. Use a substitution variable (the one with $ in front of it):

```objc
NSArray *objects = @[@"a cat", @"a hat", @"and", @"a band"];
CVPredicateFilter *predicateFilter = [CVPredicateFilter filterWithObjects:objects templatePredicate:[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] $searchTerm"];

// The key must be the name of the substitution variable.
[predicateFilter pushFilterWithSubstitutionValues:@{ @"searchTerm": @"an"}];
```

When a filter is pushed, the results are kept, so pushing another filter only searches through the already filtered objects.

If you've have pushed yourself too far, you can always pop a filter:
```objc
[predicateFilter popFilter];
```

There are many more ways to push and pop filters in `CVPredicateFilter.h`.

### CVCompoundPredicateFilter

```objc
#import "CVCompoundPredicateFilter.h"
```

Segmented arrays can also be filtered. Perfect for those sectioned table views with searching.

`CVCompoundPredicateFilter` encapsulates several predicate filters and makes them appear as one regular `CVPredicateFilter`.

Like this:

```objc
NSArray *arrayOfArrays = @[@[@"one", @"two"], @[@"one", @"two"]];
NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH $searchTerm"];

CVCompoundPredicateFilter *compoundFilter = [CVCompoundPredicateFilter compoundFilterWithSegmentedObjects:arrayOfArrays templatePredicate:predicate];

[compoundFilter pushFilterWithSubstitutionValues:@{ @"searchTerm": @"o" }];

NSLog(@"Filtered: %@", compoundFilter.filteredObjects); // Filtered: @[@[@"one"], @[@"one"]];
```

Note here that you would write the predicate exactly as you would for a single `CVPredicateFilter`.

## Credits

Distributed with an MIT License.

Contributions more than welcome.

Made by Kasper Timm Hansen.
GitHub: [@kaspth](https://github.com/kaspth).
Twitter: [@kaspth](https://twitter.com/kaspth).