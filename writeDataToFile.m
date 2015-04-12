//
//  writeDataToFile.m
//  Tester2
//
//  Created by calvin hicks on 4/12/15.
//  Copyright (c) 2015 calvin hicks. All rights reserved.
//

#import <Foundation/Foundation.h>

void writeData (NSMutableArray* StringArray){
    //write data to a local file on your machine
    for (NSString *entry in StringArray) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:(entry)];
        NSString *string = [NSString stringWithFormat:@"%@\r\n", entry];
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
        if(fh == nil) {
            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            fh = [NSFileHandle fileHandleForWritingAtPath:path];
        }
        [fh seekToEndOfFile];
        [fh writeData:[string dataUsingEncoding:NSUnicodeStringEncoding]];
        [fh closeFile];
    }
}