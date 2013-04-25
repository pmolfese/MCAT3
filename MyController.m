#import "MyController.h"

@implementation MyController

-init
{
	[super init];
	pathToPref = [NSString stringWithString:@"~/Library/Application Support/MCAT/"];
	pathToPref = [pathToPref stringByExpandingTildeInPath];
	myQ = [[NSOperationQueue alloc] init];
	return self;
}

-(void)dealloc
{
	[table unregisterDraggedTypes];
	[super dealloc];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

-(void)addFile:(NSString *)aFilePath
{
	if( [[aFilePath lastPathComponent] caseInsensitiveCompare:@".DS_Store"] == 0)
		return;
	ERPFile *myFile = [[ERPFile alloc] init];
	[myFile setName:aFilePath];
	[myFile setInputFile:aFilePath];
	[myFile setOutputFile:[aFilePath stringByAppendingString:@"-output.txt"]];	//default - we change this
	//[self readTextFile:self.inputFile];
	[myFile setInfo:@"Loading"];
	//[myFile readTextFile:aFilePath];
	[tableController addObject:myFile];
	//[NSThread detachNewThreadSelector:@selector(readTextFile:) toTarget:myFile withObject:aFilePath];
	//NSLog(@"Added %@", aFilePath);
}

-(void)loadArray
{
	NSArray *allTheFiles = [tableController arrangedObjects];
	for( ERPFile *myFile in allTheFiles )
	{
		[myFile readTextFile:[myFile inputFile]];
	}
}

- (IBAction)addFiles:(id)sender 
{	
	NSAutoreleasePool *addPool = [[NSAutoreleasePool alloc] init];
	BOOL dir;
    NSOpenPanel *myOpener = [NSOpenPanel openPanel];
	[myOpener setAllowsMultipleSelection:YES];
	[myOpener setCanChooseDirectories:YES];
	if( [myOpener runModalForTypes:[NSArray arrayWithObjects:@"txt", @"raw", nil]] == NSCancelButton )
		return;
	
	[[NSFileManager defaultManager] fileExistsAtPath:[[myOpener filenames] objectAtIndex:0] isDirectory:&dir];
	
	if( ([[myOpener filenames] count] == 1) && ( dir ) )
	{
		//path = [myOpener filenames] objectAtIndex:0];
		NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[myOpener filenames] objectAtIndex:0] error:NULL];
		for( NSString *aPath in content )
		{
			[self addFile:[[[myOpener filenames] objectAtIndex:0] stringByAppendingPathComponent:aPath]];
		}
	}
	else	//it's just a bunch of files or a single file but not a folder
	{
		for( NSString *aFile in [myOpener filenames] )
		{
			[self addFile:aFile];
		}
	}
	
	NSBlockOperation* theOp = [NSBlockOperation blockOperationWithBlock: ^{      
		NSArray *allTheFiles = [tableController arrangedObjects];                   
		for( ERPFile *myFile in allTheFiles )                                       
		{                                                                           
			[myFile readTextFile:[myFile inputFile]];                                  
		}                                                                           
	}];                                                                          
	                                                                             
	[theOp start];
	
	//[NSThread detachNewThreadSelector:@selector(loadArray) toTarget:self withObject:nil]; //was replaced by NSOperation for GCD
	[addPool drain];
}

- (IBAction)typeChanged:(id)sender
{
	//clusterCheck = cluster dropdown
	//mergedFileCheck = merged file drop down
	if( [clusterCheck indexOfSelectedItem] == 0 ) //rotate
	{
		[mergedFileCheck selectItemAtIndex:1];
		[mergedFileCheck setEnabled:YES];
	}
	if( [clusterCheck indexOfSelectedItem] == 1 ) //cluster
	{
		[mergedFileCheck selectItemAtIndex:1];
		[mergedFileCheck setEnabled:NO];
	}
	if( [clusterCheck indexOfSelectedItem] == 2 ) //both
	{
		[mergedFileCheck setEnabled:YES];
		[mergedFileCheck selectItemAtIndex:1];
	}
}

- (IBAction)dismissChannels:(id)sender
{
	[NSApp endSheet:clusterWindow];
	[clusterWindow orderOut:self];
}

- (IBAction)defineClusters:(id)sender 
{
	[NSApp beginSheet:clusterWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(dismissChannels:) contextInfo:nil];	
}

- (IBAction)deleteFiles:(id)sender 
{
    //this is implemented with bindings
}

- (IBAction)dismissProgress:(id)sender
{
	[NSApp endSheet:progressWindow];
	[progressWindow orderOut:self];
}

- (IBAction)cancelBatch:(id)sender
{
	NSLog(@"Cancel button pressed!");
	[NSApp endSheet:progressWindow];
	[myQ cancelAllOperations];
	[progressWindow orderOut:self];
}

-(void)createMergedFile:(NSArray *)listOfFiles
{
	NSMutableString *mergedFileString = [NSMutableString stringWithCapacity:300];
	for( NSString *aFile in listOfFiles )
	{
		[mergedFileString appendString:[NSString stringWithContentsOfFile:aFile encoding:1 error:NULL]];
	}
	NSString *outPath = [[listOfFiles objectAtIndex:0] stringByDeletingLastPathComponent];
	outPath = [outPath stringByAppendingString:@"/merged.txt"];
	[mergedFileString writeToFile:outPath atomically:YES encoding:1 error:NULL];
}

-(void)deleteTempFiles:(NSArray *)listOfFiles
{
	//NSLog(@"Deleting temps...");
	for( NSString *aFile in listOfFiles )
	{
		NSFileManager *myManager = [NSFileManager defaultManager];
		[myManager removeItemAtPath:aFile error:NULL];
	}
}

-(void)processHelper
{
	NSAutoreleasePool *myPool = [NSAutoreleasePool new];
	[myQ waitUntilAllOperationsAreFinished];
	[progressBar setDoubleValue:[progressBar maxValue]];
	[progressBar stopAnimation:self];
	[NSApp endSheet:progressWindow];
	[progressWindow orderOut:self];
	
	//NSLog(@"Merge Check %i", [mergedFileCheck indexOfSelectedItem]);
	if( [mergedFileCheck indexOfSelectedItem] == 0 )	//individual files only
	{
		for( ERPFile *myFile in [tableController arrangedObjects] )
		{
			[myFile writeTextFile:[myFile outputFile]];
		}
	}
	if( [mergedFileCheck indexOfSelectedItem] == 1 )	//merged file only
	{
		NSMutableString *finalMerged = [NSMutableString new];
		for( ERPFile *myFile in [tableController arrangedObjects] )
		{
			[finalMerged appendString:[myFile outString]];
		}
		NSSavePanel *mySP = [NSSavePanel savePanel];
		if( [mySP runModal] == NSOKButton )
		{
			[finalMerged writeToFile:[mySP filename] atomically:YES encoding:1 error:NULL];
		}
	}
	if( [mergedFileCheck indexOfSelectedItem] == 2 )	//both merged and individual files
	{
		NSMutableString *finalMerged = [NSMutableString new];
		for( ERPFile *myFile in [tableController arrangedObjects] )
		{
			[myFile writeTextFile:[myFile outputFile]];
			[finalMerged appendString:[myFile outString]];
		}
		NSSavePanel *mySP = [NSSavePanel savePanel];
		if( [mySP runModal] == NSOKButton )
		{
			[finalMerged writeToFile:[mySP filename] atomically:YES encoding:1 error:NULL];
		}
	}
	
	NSArray *list = [tableController arrangedObjects];
	[tableController removeObjects:list];
	[myPool drain];
}

-(void)startTheBar
{
	[progressBar startAnimation:self];
}

-(void)incrementTheBar
{
	[progressBar incrementBy:1.0];
}

- (IBAction)processFiles:(id)sender 
{
	NSAutoreleasePool *myPool = [NSAutoreleasePool new];
	NSArray *allFiles = [NSArray arrayWithArray:[tableController arrangedObjects]];
	//need to specify the channel clusters selected to each file first
	//also need to specify the ERPFile's "type" as 1-3:
	//1 = rotate
	//2 = cluster
	//3 = rotate & cluster
	//[self getClusters];
	
	if( ([clusterCheck indexOfSelectedItem] == 1) || ([clusterCheck indexOfSelectedItem] == 2) )
	{
		if( [self getClusters] == NULL )
		{
			NSLog(@"Clusters NULL");
			[[NSAlert alertWithMessageText:@"MCAT3: Alert - No clusters Defined" defaultButton:@"OK" alternateButton:nil otherButton:nil 
				informativeTextWithFormat:@"Please define clusters before proceeding."] runModal];
			return;
		}
	}
	
	[progressBar setIndeterminate:NO];
	[progressBar setMinValue:0];
	[progressBar setMaxValue:[allFiles count]];
	[progressBar setDoubleValue:0];
	[progressBar setUsesThreadedAnimation:TRUE];
	[myQ cancelAllOperations];
	[myQ setMaxConcurrentOperationCount:4];
	
	for( ERPFile *aFile in allFiles )
	{
		if( [clusterCheck indexOfSelectedItem] == 2 )
		{
			//NSLog(@"Cluster & Rotate");
			//type = 3
			aFile.type = 3;
			aFile.channelClusters = [self getClusters];
			aFile.theController = self;
		}
		else if(  [clusterCheck indexOfSelectedItem] == 1  )
		{
			//NSLog(@"Cluster only");
			//type = 2
			aFile.type = 2;
			aFile.channelClusters = [self getClusters];
			aFile.theController = self;
		}
		else if(  [clusterCheck indexOfSelectedItem] == 0  )
		{
			//NSLog(@"Rotate only");
			//type = 1
			aFile.type = 1;
			aFile.channelClusters = [self getClusters];
			aFile.theController = self;
		}
		else
		{
			NSLog(@"Unknown type Index: %i", [clusterCheck indexOfSelectedItem]);
			//type = 0
			aFile.type = 0;
		}
		[myQ addOperation:aFile];
	}
	[NSApp beginSheet:progressWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(dismissProgress:) contextInfo:nil];
	[NSThread detachNewThreadSelector:@selector(startTheBar) toTarget:self withObject:NULL];
	[NSThread detachNewThreadSelector:@selector(processHelper) toTarget:self withObject:nil];
	[myPool drain];
}

- (IBAction)addChannel:(id)sender
{
	ERPChannel *newChannel = [[ERPChannel alloc] init];
	[channelController addObject:newChannel];
}

- (IBAction)deleteChannel:(id)sender
{
	//this is implemented with bindings
}

- (IBAction)deleteChannelSet:(id)sender
{
	NSAlert *myAlert = [NSAlert alertWithMessageText:@"You are about to delete an electrode set!"
									   defaultButton:@"No" alternateButton:@"Yes" otherButton:nil informativeTextWithFormat:@"Do you wish to continue?"];
	if([myAlert runModal]  == NSAlertDefaultReturn)
	{
		//NSLog(@"Cancel Delete Operation");
		return;
	}
	//NSLog(@"Deleting: %@", [channelSelect titleOfSelectedItem]);
	NSMutableString *fileToDelete = [NSMutableString stringWithString:pathToPref];
	[fileToDelete appendString:@"/"];
	[fileToDelete appendString:[channelSelect titleOfSelectedItem]];
	[fileToDelete appendString:@".txt"];
	//NSLog(@"Deleting: %@", fileToDelete);
	NSFileManager *myFM = [NSFileManager defaultManager];
	[myFM removeItemAtPath: fileToDelete error: NULL];
	[channelSelect removeItemWithTitle:[channelSelect titleOfSelectedItem]];
	[self selectChannel:self];
}

- (IBAction)saveChannel:(id)sender
{
	NSSavePanel *mySP = [NSSavePanel savePanel];
	[mySP setRequiredFileType:@"txt"];
	[mySP runModalForDirectory:pathToPref file:@"NewChannelSetName"];
	NSMutableString *outputFile = [NSMutableString stringWithString:@""];
	NSArray *listOCh = [NSArray arrayWithArray:[channelController arrangedObjects]];
	int i, j=[listOCh count];
	for( i=0; i < j; ++i )
	{
		[outputFile appendString:[[listOCh objectAtIndex:i] stringOfChannels]];
		if( i < j-1 )
			[outputFile appendString:@"\n"];	//because we can't have a spare line
	}
	
	[outputFile writeToFile:[mySP filename] atomically:YES encoding:1 error:NULL];
	[channelSelect addItemWithTitle:[[[mySP filename] lastPathComponent] stringByDeletingPathExtension]];
	
}

- (IBAction)selectChannel:(id)sender
{
	//NSLog(@"Channel Set Changed: %@", [channelSelect titleOfSelectedItem]);
	int i;
	//delete what was there before
	NSArray *pseudoControl = [channelController arrangedObjects];
	[channelController removeObjects:pseudoControl];
	//define preference file path
	NSMutableString *openPref = [NSMutableString stringWithString:pathToPref];
	[openPref appendString:@"/"];
	[openPref appendString:[channelSelect titleOfSelectedItem]];
	[openPref appendString:@".txt"];
	//NSLog(@"Opening: %@", openPref);
	
	NSString *fileToOpen = [NSString stringWithContentsOfFile:openPref];
	NSArray *fileByLine = [fileToOpen componentsSeparatedByString:@"\n"];
	//NSLog(@"This many lines: %i", [fileByLine count]);
	for( NSString *myStr in fileByLine )
	{
		NSArray *aLine = [myStr componentsSeparatedByString:@" "];
		ERPChannel *newChannel = [[ERPChannel alloc] init];
		[newChannel setName:[aLine objectAtIndex:0]];
		NSMutableString *listChannels = [NSMutableString stringWithString:@""];
		for( i=1; i<[aLine count]; ++i )
		{
			[listChannels appendString:[aLine objectAtIndex:i]];
			[listChannels appendString:@" "];
		}
		NSRange aRange;
		aRange.location = [listChannels length] - 1;
		aRange.length = 1;
		[listChannels deleteCharactersInRange:aRange];
		[newChannel setChannels:listChannels];
		[channelController addObject:newChannel];
	}
}

-(void)awakeFromNib
{
	[table registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	
	NSFileManager *myFM = [NSFileManager defaultManager];
	NSArray *prefsDir = [myFM directoryContentsAtPath:pathToPref];
	if( prefsDir == nil )
	{
		[myFM createDirectoryAtPath:pathToPref attributes:nil];
	}
	if( [prefsDir count] <= 1 )
	{
		[channelSelect removeAllItems];
		[channelSelect addItemWithTitle:@"GSN200 128 Default"];
		NSMutableString *newPath = [NSMutableString stringWithCapacity:2];
		[newPath appendString:pathToPref];
		[newPath appendString:@"/GSN200 128 Default.txt"];
		NSMutableString *fullDefine = [NSMutableString stringWithCapacity:10];
		[fullDefine appendString:@"FL 18 19 20 22 23 24 25 26 27 28 33 34 39 128\n"];
		[fullDefine appendString:@"FR 1 2 3 4 8 9 10 14 15 121 122 123 124 125\n"];
		[fullDefine appendString:@"CL 7 12 13 21 29 30 31 32 35 36 37 38 41 42 43 46 47 48 51\n"];
		[fullDefine appendString:@"CR 5 81 88 94 98 99 103 104 105 106 107 109 110 111 112 113 117 118 119\n"];
		[fullDefine appendString:@"PL 54 61 67 53 60 52 59 58 64 63\n"];
		[fullDefine appendString:@"PR 78 79 80 87 86 93 92 97 96 100\n"];
		[fullDefine appendString:@"OL 65 66 69 70 71 72 74 75\n"];
		[fullDefine appendString:@"OR 77 83 84 85 89 90 91 95\n"];
		[fullDefine appendString:@"TL 40 44 45 49 50 56 57\n"];
		[fullDefine appendString:@"TR 101 102 108 114 115 116 120"];
		[fullDefine writeToFile:newPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
		NSLog(@"wrote: %@", newPath);
	}
	else
	{
		[channelSelect removeAllItems];
		for( NSString *aFile in prefsDir )
		{
			//NSLog(@"File found in directory: %@", aFile);
			if( [aFile caseInsensitiveCompare:@".DS_Store"] != 0 )
			{
				[channelSelect addItemWithTitle:[aFile stringByDeletingPathExtension]];
			}
		}
	}
	[self selectChannel:self];
	
	
}

- (NSDictionary *)getClusters
{
	NSMutableArray *names = [NSMutableArray new];
	NSMutableArray *channels = [NSMutableArray new];
	
	//awesome code goes here;
	//NSLog(@"Current Cluster Selection: %@", [channelSelect titleOfSelectedItem]);
	NSArray *listOfChannels = [channelController arrangedObjects];
	
	if( [listOfChannels count] == 0 )
	{
		return NULL;
	}
	
	for( ERPChannel *myChannel in listOfChannels )
	{
		[names addObject:[myChannel name]];
		//NSLog(@"Added %@", [myChannel name]);
		NSScanner *myScanner = [NSScanner scannerWithString:[myChannel channels]];
		[myScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];	//skip the white space
		NSMutableArray *listOfChannels = [NSMutableArray new];
		while( [myScanner isAtEnd] == FALSE )
		{
			int aCh;
			[myScanner scanInt:&aCh];
			[listOfChannels addObject:[NSNumber numberWithInt:aCh]];
		}
		[channels addObject:listOfChannels];
	}
	
	NSDictionary *myDictionary = [NSDictionary dictionaryWithObjectsAndKeys:names, @"names", channels, @"channels", nil];
	return myDictionary;
}

//drag and drop table support here:

-(NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info 
				proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op 
{
    // Add code here to validate the drop
    NSLog(@"validate Drop");
	[tv setDropRow: -1 dropOperation: NSTableViewDropOn];
    return NSDragOperationCopy;    
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info 
			  row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	int i;
	int compareStr;
	
	
    NSPasteboard* pboard = [info draggingPasteboard];
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) 
	{
        NSArray *theFiles = [[pboard propertyListForType:NSFilenamesPboardType] retain];
        // Perform operation using the list of files
		NSArray *sortedFiles = [NSArray arrayWithArray:[theFiles sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
		
		
		for( i=0; i<[theFiles count]; ++i )
		{
			NSString *myStr = [NSString stringWithString: [sortedFiles objectAtIndex:i]];
			compareStr = [[myStr pathExtension] caseInsensitiveCompare:@"TXT"];
			if( compareStr == 0 )
			{
				[self addFile:myStr];
			}
			else
			{
				NSLog(@"Wrong File Type");
			}
		}
    }
	[NSThread detachNewThreadSelector:@selector(loadArray) toTarget:self withObject:nil];
	return YES;
}


@end
