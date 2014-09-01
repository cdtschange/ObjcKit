/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "NSArray+Extension.h"
#import <time.h>
#import <stdarg.h>

#pragma mark StringExtensions
@implementation NSArray (StringExtensions)
- (NSArray *) arrayBySortingStrings
{
	NSMutableArray *sort = [NSMutableArray arrayWithArray:self];
	for (id eachitem in self)
		if (![eachitem isKindOfClass:[NSString class]])	[sort removeObject:eachitem];
	return [sort sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSString *) stringValue
{
	return [self componentsJoinedByString:@" "];
}
@end

#pragma mark UtilityExtensions
@implementation NSArray (UtilityExtensions)

- (NSArray *) uniqueMembers
{
	NSMutableArray *copy = [self mutableCopy];
	for (id object in self)
	{
		[copy removeObjectIdenticalTo:object];
		[copy addObject:object];
	}
	return copy;
}

- (NSArray *) unionWithArray: (NSArray *) anArray
{
	if (!anArray) return self;
	return [[self arrayByAddingObjectsFromArray:anArray] uniqueMembers];
}

- (NSArray *)intersectionWithArray:(NSArray *)anArray {
	NSMutableArray *copy = [self mutableCopy];
	for (id object in self)
		if (![anArray containsObject:object])
			[copy removeObjectIdenticalTo:object];
	return [copy uniqueMembers];
}

- (NSArray *)intersectionWithSet:(NSSet *)anSet {
	NSMutableArray *copy = [self mutableCopy];
	for (id object in self)
		if (![anSet containsObject:object])
			[copy removeObjectIdenticalTo:object];
	return [copy uniqueMembers];
}

// http://en.wikipedia.org/wiki/Complement_(set_theory)
//差集
- (NSArray *)complementWithArray:(NSArray *)anArray {
	NSMutableArray *copy = [self mutableCopy];
	for (id object in self)
		if ([anArray containsObject:object])
			[copy removeObjectIdenticalTo:object];
	return [copy uniqueMembers];
}

- (NSArray *)complementWithSet:(NSSet *)anSet {
	NSMutableArray *copy = [self mutableCopy];
	for (id object in self)
		if ([anSet containsObject:object])
			[copy removeObjectIdenticalTo:object];
	return [copy uniqueMembers];
}

@end

#pragma mark Mutable UtilityExtensions
@implementation NSMutableArray (UtilityExtensions)

+ (NSMutableArray*) arrayWithSet:(NSSet*)set {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[set count]];
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [array addObject:obj];
    }];
    return array;
}

- (void) reverse
{
	for (int i=0; i<(floor([self count]/2.0)); i++)
		[self exchangeObjectAtIndex:i withObjectAtIndex:([self count]-(i+1))];
}

// Make sure to run srandom([[NSDate date] timeIntervalSince1970]); or similar somewhere in your program
- (void) shuffle
{
    // http://en.wikipedia.org/wiki/Knuth_shuffle
	
    for(NSUInteger i = [self count]; i > 1; i--) {
        NSUInteger j = random_below(i);
        [self exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}
NSUInteger random_below(NSUInteger n) {
    NSUInteger m = 1;
	
    do {
        m <<= 1;
    } while(m < n);
	
    NSUInteger ret;
	
    do {
        ret = arc4random() % m;
    } while(ret >= n);
	
    return ret;
}

- (void) removeFirstObject
{
    if (self.count>0) {
        [self removeObjectAtIndex:0];
    }
}
@end


#pragma mark StackAndQueueExtensions
@implementation NSMutableArray (StackAndQueueExtensions)

- (void) pushObjects:(id)object,...
{
	if (!object) return;
	id obj = object;
	va_list objects;
	va_start(objects, object);
	do
	{
		[self addObject:obj];
		obj = va_arg(objects, id);
	} while (obj);
	va_end(objects);
}

- (void)push:(id)object
{
    [self addObject:object];
}

- (id) pop
{
	if ([self count] == 0) return nil;
    
    id lastObject = [self lastObject];
    [self removeLastObject];
    return lastObject;
}

- (id) peek
{
	if ([self count] == 0) return nil;
    
    id lastObject = [self lastObject];
    return lastObject;
}

- (void) enqueueObjects:(id)object,...
{
	if (!object) return;
	id obj = object;
	va_list objects;
	va_start(objects, object);
	do
	{
        [self insertObject:obj atIndex:0];
		obj = va_arg(objects, id);
	} while (obj);
	va_end(objects);
}
- (void)enqueue:(id)object {
    
	[self insertObject:object atIndex:0];
}

- (id)dequeue {
	
	if ([self count] == 0) return nil;
	id lastObject = [self lastObject];
	[self removeLastObject];
	return lastObject;
}

- (id)firstObject {
    if ([self count] == 0)
        return nil;
    return [self objectAtIndex:0];
}
- (BOOL)isEmpty {
	return [self count] == 0 ? YES : NO;
}
@end

@implementation NSArray (PSLib)

- (id)objectUsingPredicate:(NSPredicate *)predicate {
    NSArray *filteredArray = [self filteredArrayUsingPredicate:predicate];
    if (filteredArray) {
        return [filteredArray firstObject];
    }
    return nil;
}


@end

@implementation NSArray (SafeMethod)

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return self[index];
    }
    return nil;
}

@end
