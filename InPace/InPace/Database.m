#import "database.h"

@implementation Database
//generate get and set methods
@synthesize file = _file;
@synthesize results = _results;
@synthesize columns = _columns;

//destructor
- (void) dealloc {
  //[_file release];
  //[_results release];
  //[_columns release];
  //[super dealloc];
}

//constructor
- (instancetype) init_dbfile: (NSString*) filename {
  if ((self = [super init])) {
    //gonna have to add support for bundles, here
    self.file = filename;
  }
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
      //NSLog(@"column name: %s", names[i]);
      [self.columns addObject: [NSString stringWithUTF8String: names[i]]];
    }
    [row addObject: [NSString stringWithUTF8String: res[i]]];
    //NSLog(@"result: %s", res[i]);
  }
  [self.results addObject: row];
  return 0;
}

//perform the sql statement on our database.
- (int) query: (NSString*) query {
  //NSLog(@"query: %@", query);
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
  sqlite3* db;
  //open the database
  //this might have to change once bundle support is added
  CHECK(sqlite3_open([self.file UTF8String], &db), res);
  //NSLog(@"open database");
  //execute our query and call call_dummy() on each row of results
  //self (the database object) gets passed as the first argument to the
  //callback
  CHECK(sqlite3_exec(db, [query UTF8String], &call_dummy, (__bridge  void*) self, NULL), res);
  //close our database connection
  CHECK(sqlite3_close(db), res);
  //NSLog(@"closed databse");
  return 0; //we've made it this far without returning. All's good
}
@end

/*
int main () {
  @autoreleasepool {
    Database* test = [[Database alloc] init_dbfile: @"database.db"];
    NSLog(@"insert res: %i", [test query: @"INSERT INTO \"Routes\" (\"ID\", \"Name\") VALUES (1, 'test');"]);
    NSLog(@"select res: %i", [test query: @"SELECT * FROM \"Routes\";"]);
    NSLog(@"test filename: %@", test.file);
    int rows = [test.results count];
    int col = [test.columns count];
    NSLog(@"result row count: %i", rows);
    NSLog(@"result column count: %i", col);
    for (int i = 0; i < rows; i++) {
      NSLog(@"row %i: ----------------------", i);
      for (int j = 0; j < col; j++) {
        NSLog(@"%s: %s", [[test.columns objectAtIndex: j] UTF8String],
              [[[test.results objectAtIndex: i] objectAtIndex: j] UTF8String]);
      }
    }
    [test dealloc];
  }
  return 0;
}
*/
