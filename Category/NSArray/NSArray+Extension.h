/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

@interface NSArray (StringExtensions)
- (NSArray *) arrayBySortingStrings;
@property (readonly, getter=arrayBySortingStrings) NSArray *sortedStrings;
@property (readonly) NSString *stringValue;
@end

@interface NSArray (UtilityExtensions)
- (NSArray *)uniqueMembers;
- (NSArray *)unionWithArray:(NSArray *)array;
- (NSArray *)intersectionWithArray:(NSArray *)array;
- (NSArray *)intersectionWithSet:(NSSet *)set;
- (NSArray *)complementWithArray:(NSArray *)anArray;
- (NSArray *)complementWithSet:(NSSet *)anSet;
@end

@interface NSMutableArray (UtilityExtensions)

// Converts a set into an array; actually returns a
// mutable array, if that's relevant to you.
+ (NSMutableArray*) arrayWithSet:(NSSet*)set;

- (void) removeFirstObject;
- (void) reverse;
- (void) shuffle;
@end

@interface NSMutableArray (StackAndQueueExtensions)
//Stack
- (void)pushObjects:(id)object,...;
- (void)push:(id)object;
- (id) pop;
- (id) peek;
//Queue
- (void)enqueueObjects:(id)object,...;
- (void)enqueue:(id)object;
- (id)dequeue;

//Other
- (id)firstObject;
/*
 * Checks to see if the array is empty
 */
@property(nonatomic,readonly,getter=isEmpty) BOOL empty;
@end

@interface NSArray (PSLib)
- (id)objectUsingPredicate:(NSPredicate *)predicate;


@end


@interface NSArray (SafeMethod)
- (id)safeObjectAtIndex:(NSUInteger)index;
@end