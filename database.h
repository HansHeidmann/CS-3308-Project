//DATABASE MANAGER CLASS
//based heavily on code found here:
//www.appcoda.com/sqlite-database-ios-app-tutorial

#import <Foundation/Foundation.h>
#import <sqlite3.h>

//error check macro to bail on the sql if stuff goes wrong
#define CHECK(exp, var) var = exp;             \
  if (var != SQLITE_OK && var != SQLITE_DONE) {\
    NSLog(@"Error: %s", sqlite3_errmsg(database));   \
    return var; }

/** \brief Database manager class

This class maintains an SQLITE database to hold the various Routes, Coordinates, and Times.
*/
@interface Database: NSObject {
  //declare our ivars for used with @property and @synthesize
  NSString* _file;
  NSMutableArray* _results;
  NSMutableArray* _columns;
  long long int _last_rowid;
  sqlite3* database;
}
@property(retain) NSString* file; /**<Name of database file*/
@property(retain) NSMutableArray* results; /**<Array to hold query results*/
@property(retain) NSMutableArray* columns; /**<Array to hold names of columns in result*/
@property(assign) long long int last_rowid; /**<RowID of the last thing inserted into the database*/
/** Initialization function for the Database object. The Database will use the file given by filename to store and load its data.
\param filename The name of the file to use as the database file
\return A pointer to the newly created Database object is returned
*/
- (instancetype) init_dbfile: (NSString*) filename;
/** The main function of the database. This function takes an SQL statement given by query and executes it on the database. If the satement executed was a SELECT statement, then the results will be stored in the arrays results and columns. Any other statement will simply results in these two arrays being empty. query() returns a status code from the SQLITE3 library to indicate the the success of the statement.
\param query The desired SQLITE statement to be executed
\return An SQLITE3 result code indicating the status of the statement
*/
- (int) query: (NSString*) query;
@end

//extension to hold "private" helper methods
@interface Database () 
- (int) callback: (int) col Results: (char**) res ColText: (char**) names;
int call_dummy(void* db, int col, char** res, char** names);
@end
