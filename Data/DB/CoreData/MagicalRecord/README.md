# ![Awesome](https://github.com/magicalpanda/magicalpanda.github.com/blob/master/images/awesome_logo_small.png?raw=true) MagicalRecord

https://github.com/magicalpanda/MagicalRecord

In software engineering, the active record pattern is a design pattern found in software that stores its data in relational databases. It was named by Martin Fowler in his book Patterns of Enterprise Application Architecture. The interface to such an object would include functions such as Insert, Update, and Delete, plus properties that correspond more-or-less directly to the columns in the underlying database table.

>	Active record is an approach to accessing data in a database. A database table or view is wrapped into a class; thus an object instance is tied to a single row in the table. After creation of an object, a new row is added to the table upon save. Any object loaded gets its information from the database; when an object is updated, the corresponding row in the table is also updated. The	wrapper class implements accessor methods or properties for each column in the table or view.

>	*- [Wikipedia]("http://en.wikipedia.org/wiki/Active_record_pattern")*

MagicalRecord was inspired by the ease of Ruby on Rails' Active Record fetching. The goals of this code are:

* Clean up my Core Data related code
* Allow for clear, simple, one-line fetches
* Still allow the modification of the NSFetchRequest when request optimizations are needed


初始化

在AppDelegate中：

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Model.sqlite"];
    // ...
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [MagicalRecord cleanUp];
}
这样就搞定初始化啦！！

增

Person *person = [Person MR_createEntity];
person.firstname = @"Frank";
person.lastname = @"Zhang";
person.age = @26;
[[NSManagedObjectContext MR_defaultContext] MR_save];
查

//查找数据库中的所有Person。
NSArray *persons = [Person MR_findAll];

//查找所有的Person并按照first name排序。
NSArray *personsSorted = [Person MR_findAllSortedBy:@"firstname" ascending:YES];

//查找所有age属性为25的Person记录。
NSArray *personsAgeEuqals25   = [Person MR_findByAttribute:@"age" withValue:[NSNumber numberWithInt:25]];

//查找数据库中的第一条记录
Person *person = [Person MR_findFirst];
改

Person *person = ...;//此处略
person.lastname = object;        
[[NSManagedObjectContext MR_defaultContext] MR_save];
删

Person *person = ...;//此处略
[person MR_deleteEntity];
[[NSManagedObjectContext MR_defaultContext] MR_save];