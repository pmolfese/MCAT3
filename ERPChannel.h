//
//  ERPChannel.h
//  MCAT3
//
//  Created by Peter Molfese on 7/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ERPChannel : NSObject 
{
	NSString *name;
	NSString *channels;
}
@property (readwrite,copy) NSString *name;
@property (readwrite,copy) NSString *channels;
-(NSString *)stringOfChannels;

@end
