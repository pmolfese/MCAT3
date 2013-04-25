#import <Cocoa/Cocoa.h>
#import "ERPFile.h"
#import "ERPChannel.h"
#import "PMMatrix.h"

@interface MyController : NSObject /* Specify a superclass (eg: NSObject or NSView) */ {
    IBOutlet id clusterWindow;
    IBOutlet id table;
    IBOutlet id tableController;
	IBOutlet id rotateCheck;
	IBOutlet id clusterCheck;	//dropdown
	IBOutlet id channelSelect;
	IBOutlet id baselineField;
	IBOutlet id theApplication;
	IBOutlet id channelController;
	IBOutlet id channelSelectName;
	IBOutlet id progressWindow;
	IBOutlet id progressBar;
	IBOutlet id mainWindow;
	IBOutlet id mergedFileCheck;	//dropdown
	NSString *pathToPref;
	NSOperationQueue *myQ;
}
- (void)addFile:(NSString *)aFilePath;
- (IBAction)addFiles:(id)sender;
- (IBAction)defineClusters:(id)sender;
- (IBAction)deleteFiles:(id)sender;
- (IBAction)processFiles:(id)sender;
- (IBAction)addChannel:(id)sender;
- (IBAction)deleteChannel:(id)sender;
- (IBAction)deleteChannelSet:(id)sender;
- (IBAction)saveChannel:(id)sender;
- (IBAction)selectChannel:(id)sender;
- (IBAction)dismissChannels:(id)sender;
- (IBAction)dismissProgress:(id)sender;
- (IBAction)cancelBatch:(id)sender;
- (IBAction)typeChanged:(id)sender;
- (NSDictionary *)getClusters;
- (void)incrementTheBar;
- (void)startTheBar;
@end
