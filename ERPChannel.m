//
//  ERPChannel.m
//  MCAT3
//
//  Created by Peter Molfese on 7/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ERPChannel.h"


@implementation ERPChannel

@synthesize channels;
@synthesize name;

-(id)init
{
	if( [super init] == nil )
	{
		return nil;
	}
	
	channels = [NSString stringWithString:@""];
	name = [NSString stringWithString:@"UN"];
	
	return self;
}

-(NSString *)stringOfChannels
{
	NSMutableString *ch = [NSMutableString stringWithString:[self name]];
	[ch appendString:@" "];
	[ch appendString:[self channels]];
	return ch;
}

@end
