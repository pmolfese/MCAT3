//
//  ERPFile.m
//  MCAT3
//
//  Created by Peter Molfese on 7/2/08.
//  Copyright 2008 Fireball Presentations. All rights reserved.
//

#import "ERPFile.h"


@implementation ERPFile

@synthesize name;
@synthesize info;
@synthesize inputFile;
@synthesize outputFile;
@synthesize categories;
@synthesize categoryNames;
@synthesize channelClusters;
@synthesize type;
@synthesize theController;
@synthesize outString;
@synthesize isLoaded;

-(id)init
{
	if( [super init] == nil )
	{
		NSLog(@"Failed to init super ERPFile");
		return nil;
	}
	categories = [[NSMutableArray alloc] initWithCapacity:1];
	categoryNames = [[NSMutableArray alloc] initWithCapacity:1];
	channelClusters = nil;
	self.isLoaded = NO;
	self.type = 0;			//type is 0 means unset; 1 is rotated; 2 is clustered; 3 is rotated & clustered
	return self;
}

-(BOOL)readEGIFile:(NSString *)pathToFile
{
	return 0;	//not yet implemented...  waiting for NS4.4 file format
}

-(BOOL)readTextFile:(NSString *)pathToFile
{
	PMMatrix *newMatrix = [[PMMatrix alloc] init];	//where we'll put the matrix
	NSString *theFile = [NSString stringWithContentsOfFile:pathToFile];
	NSArray *rows = [theFile componentsSeparatedByString:@"\r"];
	if( [rows count] < 3 )
	{
		rows = [theFile componentsSeparatedByString:@"\n"];	//funny line endings
	}
	
	for( NSString *myRow in rows )
	{
		[newMatrix addRowOfStrings:myRow];
	}
	
	[self setInfo:[NSString stringWithFormat:@"Matrix: %i x %i", [newMatrix cols], [newMatrix rows]]];
	[categories addObject:newMatrix];
	[categoryNames addObject:@"all"];
	self.isLoaded = YES;
	return 1;
}

-(NSArray *)clusterFile
{
	NSArray *chToAve = [[self channelClusters] objectForKey:@"channels"];
	PMMatrix *aMatrix = [categories objectAtIndex:0];
	NSMutableArray *outcomeArray = [NSMutableArray new];
	for( NSArray *aSet in chToAve )
	{
		[outcomeArray addObject:[aMatrix arrayWithAverageOfColumns:aSet]];
	}
	return outcomeArray;
}

-(NSString *)returnClustered
{
	int i;
	NSArray *clue = [self clusterFile];
	if( clue == nil )
	{
		[NSAlert alertWithMessageText:@"MCAT encountered an error" defaultButton:@"OK" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Restart MCAT and check your files"];
		return nil;
	}
	NSArray *names = [channelClusters objectForKey:@"names"];
	if( [clue count] != [names count] )
	{
		NSLog(@"Oops, number of clusters isn't the same as number of names");
		[NSAlert alertWithMessageText:@"Problem converging cluster names to averages...  Please check your input files and restart MCAT3" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
		return FALSE;
	}
	
	PMMatrix *newMatrix = [[PMMatrix alloc] init];
	for( i=0; i<[clue count]; i++ )
	{
		[newMatrix addCol:[clue objectAtIndex:i]];
	}
	NSMutableString *outputString = [NSMutableString stringWithString:@""];
	
	for( i=0; i<[newMatrix rows]; i++ )
	{
		NSArray *anyRow = [newMatrix getRowAtIndex:i];
		[outputString appendString:[anyRow componentsJoinedByString:@" "]];
		[outputString appendString:@"\n"];
	}
	return outputString;
}

-(NSString *)returnRotated
{
	NSMutableString *outputString = [NSMutableString stringWithString:@""];
	PMMatrix *aMatrix = [categories objectAtIndex:0];
	int i;
	for( i=0; i<[aMatrix cols]; i++ )
	{
		NSArray *aCol = [aMatrix getColAtIndex:i];
		[outputString appendString:[aCol componentsJoinedByString:@" "]];
		[outputString appendString:@"\n"];
	}
	return outputString;
}

-(NSString *)returnFile
{
	int i, j;
	NSArray *clue = [self clusterFile];
	if( clue == nil )
	{
		[NSAlert alertWithMessageText:@"MCAT encountered an error" defaultButton:@"OK" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Restart MCAT and check your files"];
		return nil;
	}
	NSArray *names = [channelClusters objectForKey:@"names"];
	if( [clue count] != [names count] )
	{
		NSLog(@"Oops, number of clusters isn't the same as number of names");
		[NSAlert alertWithMessageText:@"Problem converging cluster names to averages...  Please check your input files and restart MCAT3" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
		
	}
	NSMutableString *outputString = [NSMutableString stringWithString:@""];
	for( i=0; i< [names count]; i++ )
	{
		[outputString appendString:[names objectAtIndex:i]];
		[outputString appendString:@" "];
		for( j=0; j<[[clue objectAtIndex:i] count]; j++ )
		{
			[outputString appendString:[[[clue objectAtIndex:i] objectAtIndex:j] stringValue]];
			[outputString appendString:@" "];
		}
		[outputString appendString:@"\n"];
	}
	return outputString;
}

-(BOOL)writeClusterdTextFile:(NSString *)pathToFile
{
	[[self outString] writeToFile:pathToFile atomically:NO encoding:1 error:NULL];	
	return TRUE;
}

-(BOOL)writeRotatedTextFile:(NSString *)pathToFile
{
	[[self outString] writeToFile:pathToFile atomically:NO encoding:1 error:NULL];
	return TRUE;
}

-(BOOL)writeTextFile:(NSString *)pathToFile
{
	[[self outString] writeToFile:pathToFile atomically:NO encoding:1 error:NULL];	
	return TRUE;
}

-(void)processFile;
{
	//NSDictionary *channelClusters;
	
	
	switch( self.type )
	{
		case 0:
			NSLog(@"Do nothing to the file - just concatenate");
			break;
		case 1:
			//NSLog(@"Type is 1: Rotate");
			//code goes here;
			//[self readTextFile:self.inputFile];
			[self setOutputFile:[[self inputFile] stringByDeletingPathExtension]];
			[self setOutputFile:[[self outputFile] stringByAppendingString:@"-r.txt"]];
			//[self writeRotatedTextFile:outputFile];
			self.outString = [self returnRotated];
			break;
		case 2:
			//[self readTextFile:self.inputFile];
			[self setOutputFile:[[self inputFile] stringByDeletingPathExtension]];
			[self setOutputFile:[[self outputFile] stringByAppendingString:@"-c.txt"]];
			//[self writeClusterdTextFile:outputFile];
			self.outString = [self returnClustered];
			break;
		case 3:
			//[self readTextFile:self.inputFile];
			[self setOutputFile:[[self inputFile] stringByDeletingPathExtension]];
			[self setOutputFile:[[self outputFile] stringByAppendingString:@"-cr.txt"]];
			//[self writeTextFile:self.outputFile];
			self.outString = [self returnFile];
			break;
		default:
			NSLog(@"Type is unknown");
			break;
	}
	if( self.outString == nil )
	{
		[NSAlert alertWithMessageText:@"outputString is empty!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Restart MCAT"];
	}
}

-(void)main
{
	while( self.isLoaded == NO )
	{
		sleep(5);
	}
	[self processFile];
	[theController incrementTheBar];
}

@end
