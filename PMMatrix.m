//
//  PMMatrix.m
//  MCAT3
//
//  Created by Peter Molfese on 7/1/08.
//  Copyright 2008 Fireball Presentations. All rights reserved.
//

#import "PMMatrix.h"


@implementation PMMatrix

@synthesize myMatrix;
@synthesize rows;
@synthesize cols;

-(id)init
{
	if( [super init] == nil )
	{
		NSLog(@"Failed to init super: PMMatrix");
		return nil;
	}
	myMatrix = [[NSMutableArray alloc] initWithCapacity:128];
	rows = 0;
	cols = 0;
	
	return self;
}

//getters
-(NSArray *)getRowAtIndex:(int)rowIndex
{
	NSMutableArray *myArray = [[NSMutableArray alloc] initWithCapacity:cols];
	for( NSArray *aColumn in myMatrix )
	{
		if( [aColumn count] < rowIndex )
		{
			NSLog(@"Trying to access row out of bounds: %i", rowIndex);
			return nil;
		}
		[myArray addObject:[aColumn objectAtIndex:rowIndex]];
	}
	return myArray;
}

-(NSArray *)getColAtIndex:(int)colIndex
{
	//NSLog(@"Getting Columns %i", colIndex);
	
	if( [myMatrix count] < colIndex )
	{
		NSLog(@"Trying to access col out of bounds: %i", colIndex);
		return nil;
	}
	return [myMatrix objectAtIndex:colIndex];
}

-(NSNumber *)getObjectAtRow:(int)rowIndex andColumn:(int)colIndex
{
	if( [myMatrix count] < colIndex )
	{
		NSLog(@"Trying to access col out of bounds: %i", colIndex);
		return nil;
	}
	if( [[myMatrix objectAtIndex:colIndex] count] < rowIndex )
	{
		NSLog(@"Trying to access row out of bounds: %i", rowIndex);
		return nil;
	}
	return [[myMatrix objectAtIndex:colIndex] objectAtIndex:rowIndex];
}

//setters
-(BOOL)addRow:(NSArray *)someArray
{
	int i, ct = [someArray count];
	if( self.rows == 0 && self.cols == 0 )
	{
		//NSLog(@"Setting up new PMMatrix...");
		//this is a new matrix, set it up
		for( i=0; i<ct; ++i )
		{
			[myMatrix addObject:[NSMutableArray arrayWithCapacity:250]];
			self.cols++;
		}
	}
	//assuming the rows are NSDecimalNumbers...
	for( i=0; i<ct; ++i )
	{
		[[myMatrix objectAtIndex:i] addObject:[someArray objectAtIndex:i]];
	}
	self.rows++;
	//NSLog(@"Num rows: %i, Num cols: %i", self.rows, self.cols);
	return TRUE;
}

-(BOOL)addRowOfStrings:(NSString *)someArray
{
	NSArray *myCols = [someArray componentsSeparatedByString:@"\t"];
	int i = 0;
    int ct = [myCols count];
	if( ct == 0 || ct == 1 )
		return FALSE;
	NSMutableArray *arrayConvert = [NSMutableArray arrayWithCapacity:ct];
	for( i=0; i<ct; ++i )
	{
		[arrayConvert addObject:[NSDecimalNumber decimalNumberWithString:[myCols objectAtIndex:i]]];
	}
	[self addRow:arrayConvert];
	return TRUE;
}

-(BOOL)addCol:(NSArray *)someArray
{
	if( self.cols == 0 )
	{
		//brand new
		[myMatrix addObject:[NSMutableArray arrayWithArray:someArray]];
		self.cols++;
		self.rows = [someArray count];
	}
	else if( [someArray count] != self.rows )
	{
		NSLog(@"Trying to add column with different number of rows");
		return FALSE;
	}
	else
	{
		[myMatrix addObject:[NSMutableArray arrayWithArray:someArray]];
		self.cols++;
	}
	return TRUE;
}

//handy things
-(NSArray *)arrayWithAverageOfColumns:(NSArray *)columnNumbers
{
	//NSLog(@"Beginning arrayWithAverageOfColumns:");
	int i;
	NSMutableArray *setOfColumns = [NSMutableArray arrayWithCapacity:0];
	
	for( i=0; i<[columnNumbers count]; i++ )
	{
		int myIndex = [[columnNumbers objectAtIndex:i] intValue];
		NSArray *aColumnOfInterest = [self getColAtIndex:(myIndex-1)];
		[setOfColumns addObject:aColumnOfInterest];
	}
	NSArray *retArray = [self averageColumns:setOfColumns];
	return retArray;
}

-(NSArray *)averageColumns:(NSArray *)columns
{
	//NSLog(@"Beginning averageColumns:");
	NSMutableArray *aveArray = [[NSMutableArray alloc] initWithCapacity:[self rows]];
	int i, j;
	double newNum = 0;
	
	for( i=0; i<self.rows; i++ )
	{
		newNum = 0;
		for( j=0; j<[columns count]; j++ )
		{
			newNum += [[[columns objectAtIndex:j] objectAtIndex:i] doubleValue];
		}
		newNum /= [columns count];
		[aveArray addObject:[NSNumber numberWithDouble:newNum]];
	}
	//NSLog(@"AveArray Size: %i", [aveArray count]);
	
	return aveArray;
}

-(BOOL)rotateMatrix
{
	//I'll implement this when I have some extra time...
	return FALSE;
}

@end
