#import "database.m"
#import "UTFramework.h"
#import <sqlite3.h>

using namespace Thilenius;

SUITE_BEGIN("Database Test")

TEST_BEGIN("New Table Creation") {
@autoreleasepool{
  Database* test = [[Database alloc] init_dbfile: @"test/test1.db"];
  int res = [test query: @"CREATE TABLE \"Person\" (\"ID\" INTEGER PRIMARY KEY, \"Name\" char);"];
  IsTrue("create table query", res == SQLITE_OK, "table should be created successfully");
  res = [test query: @"SELECT * FROM \"Person\";"];
  IsTrue("select from new table", res == SQLITE_OK, "select statement should execture successfully");
  IsTrue("results array should be empty for empty table select query", [test.results count] == 0, "there are things in the results array");
  IsTrue("columns array should be empty for empty table select query", [test.columns count] == 0, "there are things in the columns array");
  [test dealloc];
}
} TEST_END

TEST_BEGIN("Insert/Select 1 row") {
@autoreleasepool{
  Database* test = [[Database alloc] init_dbfile: @"test/test2.db"];
  int res = [test query: @"CREATE TABLE \"Person\" (\"ID\" INTEGER PRIMARY KEY, \"Name\" char);"];
  IsTrue("create table query", res == SQLITE_OK, "table should be created successfully");
  res = [test query: @"INSERT INTO \"Person\" (\"ID\", \"Name\") VALUES (1, 'Bob Jones');"];
  IsTrue("insert into new table query", res == SQLITE_OK, "data should be inserted successfully");
  IsTrue("result array should be empty directly after update", [test.results count] == 0, "results array should be empty after update statement finishes");
  IsTrue("columns array should be empty directly after update", [test.columns count] == 0, "columns array should be empty after update statement finished");
  res = [test query: @"SELECT * FROM \"Person\";"];
  IsTrue("select from table w/1 row", res == SQLITE_OK, "select statement should complete successfully");
  IsTrue("results array should have 1 row", [test.results count] == 1, "select statement did not get correct amount of entires");
  IsTrue("results content", [[[test.results objectAtIndex: 0] objectAtIndex: 0] isEqualToString: @"1"] && [[[test.results objectAtIndex: 0] objectAtIndex: 1] isEqualToString: @"Bob Jones"], "results array should contain one array containing [1, Bob Jones]");
  IsTrue("columns array should have 2 entries", [test.columns count] == 2, "select statement did not get correct amount of columns");
  IsTrue("column 1 name", [[test.columns objectAtIndex: 0] isEqualToString: @"ID"], "column 1 should be named ID");
  IsTrue("column 2 name", [[test.columns objectAtIndex: 1] isEqualToString: @"Name"], "column 1 should be named Name");
  [test dealloc];
}
} TEST_END

TEST_BEGIN("Ensure changes persist") {
@autoreleasepool {
  Database* test = [[Database alloc] init_dbfile: @"test/test2.db"];
  [test query: @"SELECT * FROM \"Person\";"];
  IsTrue("results array should have 1 row", [test.results count] == 1, "select statement did not get correct number of entries");
  IsTrue("results content", [[[test.results objectAtIndex: 0] objectAtIndex: 0] isEqualToString: @"1"] && [[[test.results objectAtIndex: 0] objectAtIndex: 1] isEqualToString: @"Bob Jones"], "results array should still contain the entry [1, Bob Jones]");
  IsTrue("columns array should have 2 entries", [test.columns count] == 2, "select statement did not get correct number of entries");
  IsTrue("column 1 name", [[test.columns objectAtIndex: 0] isEqualToString: @"ID"], "column 1 should be named ID");
  IsTrue("column 2 name", [[test.columns objectAtIndex: 1] isEqualToString: @"Name"], "column 2 should be named Name");
  [test dealloc];
}
} TEST_END

TEST_BEGIN("Update/Delete 1 row") {
@autoreleasepool {
  Database* test = [[Database alloc] init_dbfile: @"test/test2.db"];
  int res = [test query: @"UPDATE \"Person\" SET \"Name\" = 'Bob Smith' WHERE \"Name\" IS 'Bob Jones';"];
  IsTrue("update 1 row", res == SQLITE_OK, "update should execute successfully");
  IsTrue("results length after update", [test.results count] == 0, "results array should be empty after update statement");
  IsTrue("columns length after update", [test.columns count] == 0, "columns array should be empty adter update statement");
  [test query: @"SELECT * FROM \"Person\";"];
  IsTrue("results length after select", [test.results count] == 1, "update should not add new record");
  IsTrue("results content after select", [[[test.results objectAtIndex: 0] objectAtIndex: 0] isEqualToString: @"1"] && [[[test.results objectAtIndex: 0] objectAtIndex: 1] isEqualToString: @"Bob Smith"], "results should contain [1, Bob Smith]");
  res = [test query: @"DELETE FROM \"Person\" WHERE \"Name\" IS 'Bob Smith';"];
  IsTrue("delete 1 row", res == SQLITE_OK, "delete should execute successfully");
  IsTrue("results length after delete", [test.results count] == 0, "results array should be empty after delete statement");
  [test query: @"SELECT * FROM \"Person\";"];
  IsTrue("results length after select", [test.results count] == 0, "results array should be empty for empty table");
  IsTrue("columns length after select", [test.columns count] == 0, "columns array should be empty for empty table");
  [test dealloc];
}
} TEST_END

SUITE_END

int main(int argc, char* argv[]) {
  UTFrameworkInit;
  return 0;

}
