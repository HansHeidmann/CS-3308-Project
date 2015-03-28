#import "database.h"

@implementation Database
//generate get and set methods
@synthesize file = _file;
@synthesize results = _results;
@synthesize columns = _columns;
//destructor
- (void) dealloc {
  [_file release];
  [_results release];
  [_columns release];
  [super dealloc];
}
//constructor
- (instancetype) init_dbfile: (NSString*) filename {
  if ((self = [super init])) {
    //gonna have to add support for bundles, here
    self.file = filename;
  }
  return self;
}
//callback function called on each row of the results of a select query
- (int) callback: (void*) pass ColNum: (int) col ColText: (char**) names Results: (char**) res {
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
- (int) runner: (const char*) query isMut: (BOOL) mutable {
  NSLog(@"query: %s", query);
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
  NSLog(@"open database");
  sqlite3_stmt* stmt;
  CHECK(sqlite3_prepare_v2(db, query, -1, &stmt, NULL), res);
  NSLog(@"prepared statement");
  if (!mutable) { //select statements
    NSMutableArray* row; //hold each row's data as we need it
    //loop as long as we have rows left to check
    while (sqlite3_step(stmt) == SQLITE_ROW) {
      NSLog(@"step in statement");
      //(Re)Initialize row array
      row = [[NSMutableArray alloc] init];
      int col = sqlite3_column_count(stmt);
      NSLog(@"get column count");
      //loop through each column in the row
      for (int i = 0; i < col; i++) {
        char* data = (char*) sqlite3_column_text(stmt, i);
        NSLog(@"got data: %s", data);
        //make sure there is data in the field
        if (data != NULL) {
          //add the data to our row array as an NSString
          [row addObject:[NSString stringWithUTF8String: data]];
        }
        //add the current column name to our column array as long as we
        //haven't already got them all
        if (self.columns.count != col) {
          data = (char*) sqlite3_column_name(stmt, i);
          NSLog(@"got colunmn name: %s", data);
          [self.columns addObject:[NSString stringWithUTF8String: data]];
        }
      }
      //add the row of data to our results as long as there is data to add
      if (row.count > 0) {
        [self.results addObject: row];
      }
    }
  } else { //we're working with an INSERT, UPDATE, REMOVE, etc.
    //can just run the statement
    CHECK(sqlite3_step(stmt), res);
    NSLog(@"mutable step");
    //Error checking or verification feedback could go here
  }
  //free memory used by our compiled SQL query and close database
  CHECK(sqlite3_finalize(stmt), res);
  NSLog(@"statement finalized");
  //CHECK(sqlite3_exec(db, query, callback, NULL, NULL), res);
  CHECK(sqlite3_close(db), res);
  NSLog(@"closed databse");
  return 0; //we've made it this far without returning. All's good
}
- (int) select: (NSString*) query {
  return [self runner:[query UTF8String] isMut: NO];
}
- (int) mutate: (NSString*) query {
  return [self runner:[query UTF8String] isMut: YES];
}
@end

int main () {
  @autoreleasepool {
    Database* test = [[Database alloc] init_dbfile: @"database.db"];
    NSLog(@"insert res: %i", [test mutate: @"INSERT INTO \"Routes\" (\"ID\", \"Name\") VALUES (1, 'test');"]);
    NSLog(@"select res: %i", [test select: @"SELECT * FROM \"Routes\";"]);
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
