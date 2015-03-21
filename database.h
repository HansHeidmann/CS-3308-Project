//DATABASE MANAGER CLASS
//based heavily on code found here:
//www.appcoda.com/sqlite-database-ios-app-tutorial

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database: NSObject {
  //declare our ivars for used with @property and @synthesize
  NSString* _file;
  NSMutableArray* _results;
  NSMutableArray* _columns;
}
@property(retain) NSString* file; //name of database file
@property(retain) NSMutableArray* results; //array to hold query results
@property(retain) NSMutableArray* columns; //array to hold names of columns in result
- (instancetype) init_dbfile: (NSString*) filename;
- (void) select: (NSString*) query;
- (void) mutate: (NSString*) query;
@end

//extension to hold a "private" helper method
@interface Database () 
- (void) runner: (const char*) query isMut: (BOOL) mutable;
@end
