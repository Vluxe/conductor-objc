/////////////////////////////////////////////////////////////////////////////
//
//  VLXConductor.m
//
//  Created by Dalton Cherry on 8/15/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
/////////////////////////////////////////////////////////////////////////////

#import "VLXConductor.h"
#import "JFWebSocket.h"

@interface VLXObserver : NSObject

@property(nonatomic,strong)VLXConductorMessages messages;
@property(nonatomic,strong)id observer;

@end

@interface VLXConductor ()<JFWebSocketDelegate>

@property(nonatomic,strong)JFWebSocket *socket;
@property(nonatomic,strong)NSMutableDictionary *channels;

@end

@implementation VLXConductor

/////////////////////////////////////////////////////////////////////////////
-(instancetype)initWithURL:(NSURL*)url authToken:(NSString*)authToken
{
    if(self = [super init])
    {
        self.socket = [[JFWebSocket alloc] initWithURL:url];
        self.socket.delegate = self;
        [self.socket addHeader:authToken forKey:@"Token"];
        [self.socket connect];
        self.channels = [[NSMutableDictionary alloc] init];
    }
    return self;
}
/////////////////////////////////////////////////////////////////////////////
-(void)bind:(NSString*)channelName observer:(id)observer messages:(VLXConductorMessages)messages
{
    NSMutableArray *array = self.channels[channelName];
    if(!array) {
        //send bind message
        array = [[NSMutableArray alloc] init];
        [self.channels setObject:array forKey:channelName];
    }
    //unbind/check observer isn't in the array first...
    VLXObserver *obs = [[VLXObserver alloc] init];
    obs.observer = observer;
    obs.messages = messages;
    [array addObject:obs];
}
/////////////////////////////////////////////////////////////////////////////
-(void)unbind:(NSString*)channelName observer:(id)observer
{
    
}
/////////////////////////////////////////////////////////////////////////////
-(void)sendMessage:(NSString*)body channel:(NSString*)channelName opcode:(VLXConOpCode)code additional:(id)object
{
    //send a message to the server
}
/////////////////////////////////////////////////////////////////////////////
#pragma - mark websocket delegate methods
/////////////////////////////////////////////////////////////////////////////
-(void)websocketDidConnect:(JFWebSocket*)socket
{
    //don't really need to do anything (expect maybe auto reconnect state stuff)
}
/////////////////////////////////////////////////////////////////////////////
-(void)websocketDidDisconnect:(JFWebSocket*)socket error:(NSError*)error
{
    //auto reconnect stuff
}
/////////////////////////////////////////////////////////////////////////////
-(void)websocket:(JFWebSocket*)socket didReceiveMessage:(NSString*)string
{
    //convert string to JSON, then to message object and broadcast to the blocks
}
/////////////////////////////////////////////////////////////////////////////
-(void)websocket:(JFWebSocket*)socket didReceiveData:(NSData*)data
{
    //nothing in conductor for binary right now
}
/////////////////////////////////////////////////////////////////////////////
-(void)websocketDidWriteError:(JFWebSocket*)socket error:(NSError*)error
{
    //do we need to forward the errors along?
}
/////////////////////////////////////////////////////////////////////////////

@end

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

@implementation VLXObserver

@end
