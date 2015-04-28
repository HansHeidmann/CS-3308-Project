CC = clang
OBJCFLAGS := $(shell gnustep-config --objc-flags)
OBJCLIBS := $(shell gnustep-config --objc-libs) -lgnustep-base
SQLLIB = -lsqlite3
TEST= test
SRC= InPace/InPace

.PHONY: clean

test: $(TEST)/UTFramework.o $(TEST)/db_test.mm
	$(CC)++ $^ $(OBJCFLAGS) $(OBJCLIBS) $(SQLLIB) -pthread -o $(TEST)/db_test 

$(TEST)/UTFramework.o: $(TEST)/UTFramework.cpp
	$(CC) -pthread -c $^ -o $@

database: database.o sql
	$(CC) $< $(OBJCLIBS) $(SQLLIB) -o $@

database.o: $(SRC)/Database.m $(SRC)/Database.h
	$(CC) $(OBJCFLAGS) -c $<

sql: init.sql
	sqlite3 -init init.sql database.db .quit

clean:
	rm -f *.o
	rm -f *.d
	rm -f *~
	rm -f database
	rm -f database.db
	rm -f test/*.db
	rm -f test/db_test
