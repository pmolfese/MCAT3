//
//  ERPFile.h
//  MCAT3
//
//  Created by Peter Molfese on 7/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMMatrix.h"
#import "MyController.h"


@interface ERPFile : NSOperation 
{
	NSString *name;
	NSString *info;
	NSString *inputFile;
	NSString *outputFile;
	NSMutableArray *categories;
	NSMutableArray *categoryNames;
	NSDictionary *channelClusters;
	NSUInteger type;
	NSObject *theController;
	NSString *outString;
	BOOL isLoaded;
}
@property(readwrite,copy) NSString *name;
@property(readwrite,copy) NSString *info;
@property(readwrite,copy) NSString *inputFile;
@property(readwrite,copy) NSString *outputFile;
@property(readwrite,copy) NSMutableArray *categories;
@property(readwrite,copy) NSMutableArray *categoryNames;
@property(readwrite,copy) NSDictionary *channelClusters;
@property(readwrite) NSUInteger type;
@property(readwrite) BOOL isLoaded;
@property(readwrite) NSObject *theController;
@property(readwrite,assign) NSString *outString;


//read and write functions
-(NSArray *)clusterFile;
-(BOOL)readEGIFile:(NSString *)pathToFile;
-(BOOL)readTextFile:(NSString *)pathToFile;
-(NSString *)returnClustered;
-(NSString *)returnRotated;
-(NSString *)returnFile;
-(BOOL)writeClusterdTextFile:(NSString *)pathToFile;
-(BOOL)writeRotatedTextFile:(NSString *)pathToFile;
-(BOOL)writeTextFile:(NSString *)pathToFile;
-(void)processFile;
-(void)main;



@end
