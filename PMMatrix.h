//
//  PMMatrix.h
//  MCAT3
//
//  Created by Peter Molfese on 7/1/08.
//  Copyright 2008 Fireball Presentation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PMMatrix : NSObject 
{
	NSMutableArray *myMatrix;
	int rows;
	int cols;
}
@property(readwrite,copy) NSMutableArray *myMatrix;
@property(readwrite) int rows;
@property(readwrite) int cols;

//getters
-(NSArray *)getRowAtIndex:(int)rowIndex;
-(NSArray *)getColAtIndex:(int)colIndex;
-(NSNumber *)getObjectAtRow:(int)rowIndex andColumn:(int)colIndex;

//setters
-(BOOL)addRow:(NSArray *)someArray;
-(BOOL)addRowOfStrings:(NSString *)someArray;
-(BOOL)addCol:(NSArray *)someArray;

//handy things
-(NSArray *)arrayWithAverageOfColumns:(NSArray *)columnNumbers;
-(NSArray *)averageColumns:(NSArray *)columns;
-(BOOL)rotateMatrix;

@end
