
//  Tester2

//

//  Created by calvin hicks on 4/12/15.

//  Copyright (c) 2015 calvin hicks. All rights reserved.

//

//testing testing testing



#import <Foundation/Foundation.h>





void writeData (NSMutableArray* StringArray){
    
    Boolean notEnd = true;
    
    int count = 0;
    
    int loopNumber = 0;
    
    NSMutableString *resultString = @"";
    
    //write data to a local file on your machine
    
    //for (NSString *entry in StringArray) {
    
    while (notEnd) {
        
        NSMutableString *string = [StringArray objectAtIndex: loopNumber];
        
        NSString *path =  @"/Users/calvinehicks/Desktop/test.txt";//[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:(entry)];
        
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
        
        //NSLog(@"string: %@", string);
        
        if(count == 0 && [string isEqualToString: @"start"]) {
            
            
            
        }
        
        if([string isEqualToString: @"end"]) {
            
            notEnd = false;
            
            break;
            
        }
        
        if(fh == nil) {
            
            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            
            fh = [NSFileHandle fileHandleForWritingAtPath:path];
            
        }
        
        [fh seekToEndOfFile];
        
        
        
        if(count == 3) { //write to file
            
            //[resultString appendString:(string)];
            
            resultString = [resultString stringByAppendingString: @", "];
            
            resultString = [resultString stringByAppendingString: string];
            
            resultString = [resultString stringByAppendingString: @"\n"];
            
            //NSLog(@"result: %@", resultString);
            
            [fh writeData:[resultString dataUsingEncoding:NSUnicodeStringEncoding]];
            
            [fh closeFile];
            
            count = 0;
            
            loopNumber++;
            
        }
        
        else if(count < 3) {
            
            if(count != 0) {
                
                resultString = [resultString stringByAppendingString: @", "];
                
                //NSLog(@"result: %@", resultString);
                
            }
            
            resultString = [resultString stringByAppendingString:string];
            
            NSLog(@"result: %@", resultString);
            
            NSLog(@"string: %@", string);
            
            count++;
            
            loopNumber++;
            
        }
        
    }
    
}



int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        
        // insert code here...
        
        NSLog(@"Hello, World!");
        
        NSMutableArray *writableData = @[@"testing", @"element2", @"element3", @"element4", @"testing", @"element2", @"element3", @"element4", @"testing", @"element2", @"element3", @"element4", @"testing", @"element2", @"element3", @"element4", @"end"];
        
        writeData(writableData);
        
    }
    
    return 0;
    
}

