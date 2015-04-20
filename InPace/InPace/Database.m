#import "Database.h"

@implementation Database
//generate get and set methods
@synthesize file = _file;
@synthesize results = _results;
@synthesize columns = _columns;
@synthesize last_rowid = _last_rowid;

//destructor
- (void) dealloc {
  //close the database
  sqlite3_close(database);
#ifndef __arm__
  [_file release];
  [_results release];
  [_columns release];
  [super dealloc];
#endif
}

//constructor
- (instancetype) init_dbfile: (NSString*) filename {
  if ((self = [super init])) {
    //gonna have to add support for bundles, here
    self.file = filename;
  }
  int res = sqlite3_open([self.file UTF8String], &database);
  if (res != SQLITE_OK) {
    database = NULL;
  }
  //make sure our foreign key support is set for this connection
  [self query: @"PRAGMA foreign_keys=ON;"];
  return self;
}

//C callback function called by sqlite3_exec() on each row. Calls the
//callback method on the database object supplied as a void*
//Objective-C doesn't like callbacks, hence the workaround
int call_dummy(void* db, int col, char** res, char** names) {
  return [(__bridge id) db callback: col Results: res ColText: names];
}

//callback function called on each row of the results of a select query
//adds column names and data to our own internal arrays
- (int) callback: (int) col Results: (char**) res ColText: (char**) names {
  NSMutableArray* row;
  row = [[NSMutableArray alloc] init];
  for (int i = 0; i < col; i++) {
    if ([self.columns count] != col) {
      [self.columns addObject: [NSString stringWithUTF8String: names[i]]];
    }
    [row addObject: [NSString stringWithUTF8String: res[i]]];
  }
  [self.results addObject: row];
  return 0;
}

//perform the sql statement on our database.
- (int) query: (NSString*) query {
  int res = 0; //holds sql status result for error check
  //(Re)Initialize results array
  if (self.results != nil) {
    [self.results removeAllObjects];
    self.results = nil;
  }
  self.results = [[NSMutableArray alloc] init];
  //(Re)Initialize columns array
  if (self.columns != nil) {
    [self.columns removeAllObjects];
    self.columns = nil;
  }
  self.columns = [[NSMutableArray alloc] init];
  //execute our query and call call_dummy() on each row of results
  //self (the database object) gets passed as the first argument to the
  //callback
  CHECK(sqlite3_exec(database, [query UTF8String], &call_dummy, (__bridge void*) self, NULL), res);
  self.last_rowid = sqlite3_last_insert_rowid(database);
  return 0; //we've made it this far without returning. All's good
}
@end
