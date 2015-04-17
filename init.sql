CREATE TABLE IF NOT EXISTS "Routes" (
"ID" INTEGER PRIMARY KEY,
"Name" text,
"Distance" float,
"Time" int,
"Year" int,
"Month" int,
"Day" int
)
;

CREATE TABLE IF NOT EXISTS "Coordinates" (
"ID" INTEGER PRIMARY KEY,
"RouteID" REFERENCES "Routes"("ID") ON DELETE CASCADE ON UPDATE CASCADE,
"Latitude" float,
"Longitude" float,
"Altitude" int
)
;

CREATE TABLE IF NOT EXISTS "Times" (
"ID" INTEGER PRIMARY KEY,
"CoordinateID" REFERENCES "Coordinates"("ID") ON DELETE CASCADE ON UPDATE CASCADE,
"Hour" int,
"Minute" int,
"Second" int
)
;
