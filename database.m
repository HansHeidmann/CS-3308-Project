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
- (void) runner: (const char*) query isMut: (BOOL) mutable {
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
  sqlite3_open([self.file UTF8String], &db);
  sqlite3_stmt* stmt;
  sqlite3_prepare_v2(db, query, -1, &stmt, NULL);
  if (!mutable) { //select statements
    NSMutableArray* row; //hold each row's data as we need it
    //loop as long as we have rows left to check
    while (sqlite3_step(stmt) == SQLITE_ROW) {
      //(Re)Initialize row array
      row = [[NSMutableArray alloc] init];
      int col = sqlite3_column_count(stmt);
      //loop through each column in the row
      for (int i = 0; i < col; i++) {
        char* data = (char*) sqlite3_column_text(stmt, i);
        //make sure there is data in the field
        if (data != NULL) {
          //add the data to our row array as an NSString
          [row addObject:[NSString stringWithUTF8String: data]];
        }
        //add the current column name to our column array as long as we
        //haven't already got them all
        if (self.columns.count != col) {
          data = (char*) sqlite3_column_name(stmt, i);
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
    sqlite3_step(stmt);
    //Error checking or verification feedback could go here
  }
  //free memory used by our compiled SQL query and close database
  sqlite3_finalize(stmt);
  sqlite3_close(db);
}
- (void) select: (NSString*) query {
  [self runner:[query UTF8String] isMut: NO];
}
- (void) mutate: (NSString*) query {
  [self runner:[query UTF8String] isMut: YES];
}
@end
