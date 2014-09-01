/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 Modified by Peter Steinberger
 */

#import <UIKit/UIKit.h>

// Path utilities
NSString *NSDocumentsFolder(void);
NSString *NSLibraryFolder(void);
NSString *NSBundleFolder(void);

@interface NSFileManager (Path)
+ (NSString *)pathForItemNamed:(NSString *)fname inFolder:(NSString *)path;
+ (NSString *)pathForDocumentNamed:(NSString *)fname;
+ (NSString *)pathForBundleDocumentNamed:(NSString *)fname;

+ (NSArray *)pathsForItemsMatchingExtension:(NSString *)ext inFolder:(NSString *)path;
+ (NSArray *)pathsForDocumentsMatchingExtension:(NSString *)ext;
+ (NSArray *)pathsForBundleDocumentsMatchingExtension:(NSString *)ext;

+ (NSArray *)filesInFolder:(NSString *)path;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
@end

