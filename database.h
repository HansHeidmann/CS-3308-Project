//DATABASE MANAGER CLASS
//based heavily on code found here:
//www.appcoda.com/sqlite-database-ios-app-tutorial

#import <Foundation/Foundation.h>
#import <sqlite3.h>

//error check macro to bail on the sql if stuff goes wrong
#define CHECK(exp, var) var = exp;             \
  if (var != SQLITE_OK && var != SQLITE_DONE) {\
    NSLog(@"Error: %s", sqlite3_errmsg(db));   \
    return var; }

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
- (int) query: (NSString*) query;
@end

//extension to hold "private" helper methods
@interface Database () 
- (int) callback: (int) col ColText: (char**) names Results: (char**) res;
int call_dummy(void* db, int col, char** names, char** res);
@end
