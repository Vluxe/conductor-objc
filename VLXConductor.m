/////////////////////////////////////////////////////////////////////////////
//
//  VLXConductor.m
//
//  Created by Dalton Cherry on 8/15/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
/////////////////////////////////////////////////////////////////////////////

#import "VLXConductor.h"
#import "JFRWebSocket.h"

@interface VLXMessage ()

+(VLXMessage*)messageFromString:(NSString*)jsonString;
-(NSString*)toJSONString;

@end

@interface VLXObserver : NSObject

@property(nonatomic,strong)VLXConductorMessages messages;
@property(nonatomic,strong)id observer;

@end

@interface VLXConductor ()<JFRWebSocketDelegate>

@property(nonatomic,strong)JFRWebSocket *socket;
@property(nonatomic,strong)NSMutableDictionary *channels;
@property(nonatomic,strong)VLXConductorConnection connectionStatus;
@property(nonatomic,strong)VLXConductorMessages serverMessages;

@end

@implementation VLXConductor

/////////////////////////////////////////////////////////////////////////////
-(instancetype)initWithURL:(NSURL*)url authToken:(NSString*)authToken
{
    if(self = [super init])
    {
        self.socket = [[JFRWebSocket alloc] initWithURL:url protocols:@[@"chat",@"superchat"]];
        self.socket.delegate = self;
        [self.socket addHeader:authToken forKey:@"Token"];
        [self.socket connect];
        self.channels = [[NSMutableDictionary alloc] init];
    }
    return self;
}
/////////////////////////////////////////////////////////////////////////////
-(void)setAuthToken:(NSString*)token
{
    [self.socket addHeader:token forKey:@"Token"];
}
/////////////////////////////////////////////////////////////////////////////
-(void)bind:(NSString*)channelName messages:(VLXConductorMessages)messages
{
    [self.channels setObject:messages forKey:channelName];
    if(![channelName isEqualToString:kVLXAllMessages]) {
        [self writeMessage:@"" channel:channelName opcode:VLXConOpCodeBind additional:nil];
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)unbind:(NSString*)channelName
{
    [self.channels removeObjectForKey:channelName];
    if(![channelName isEqualToString:kVLXAllMessages]) {
        [self writeMessage:@"" channel:channelName opcode:VLXConOpCodeUnBind additional:nil];
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)serverBind:(VLXConductorMessages)messages
{
    self.serverMessages = messages;
}
/////////////////////////////////////////////////////////////////////////////
-(void)serverUnbind
{
    self.serverMessages = nil;
}
/////////////////////////////////////////////////////////////////////////////
-(void)sendMessage:(NSString*)body channel:(NSString*)channelName additional:(id)object
{
    [self writeMessage:body channel:channelName opcode:VLXConOpCodeWrite additional:object];
}
/////////////////////////////////////////////////////////////////////////////
-(void)sendInfo:(NSString*)body channel:(NSString*)channelName additional:(id)object
{
    [self writeMessage:body channel:channelName opcode:VLXConOpCodeInfo additional:object];
}
/////////////////////////////////////////////////////////////////////////////
-(void)sendInvite:(NSString*)name channel:(NSString*)channelName additional:(id)object
{
    [self writeMessage:name channel:channelName opcode:VLXConOpCodeInvite additional:object];
}
/////////////////////////////////////////////////////////////////////////////
-(void)sendServerMessage:(NSString*)body channel:(NSString*)channelName additional:(id)object
{
    [self writeMessage:body channel:channelName opcode:VLXConOpCodeServer additional:object];
}
/////////////////////////////////////////////////////////////////////////////
-(void)connectionState:(VLXConductorConnection)connection
{
    self.connectionStatus = connection;
}
/////////////////////////////////////////////////////////////////////////////
#pragma - mark private methods
/////////////////////////////////////////////////////////////////////////////
-(void)writeMessage:(NSString*)body channel:(NSString*)channelName opcode:(VLXConOpCode)code additional:(id)object
{
    VLXMessage *message = [VLXMessage new];
    message.body = body;
    message.channelName = channelName;
    message.opcode = code;
    message.additional = object;
    [self.socket writeString:[message toJSONString]];
}
/////////////////////////////////////////////////////////////////////////////
#pragma - mark websocket delegate methods
/////////////////////////////////////////////////////////////////////////////
-(void)websocketDidConnect:(JFRWebSocket*)socket
{
    //NSLog(@"socket connected");
    _isConnected = YES;
    if(self.connectionStatus) {
        self.connectionStatus(_isConnected);
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error
{
    //NSLog(@"socket disconnected");
    _isConnected = NO;
    if(self.connectionStatus) {
        self.connectionStatus(_isConnected);
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string
{
    VLXMessage *message = [VLXMessage messageFromString:string];
    if(message.opcode == VLXConOpCodeServer || message.opcode == VLXConOpCodeInvite) {
        if(self.serverMessages) {
            self.serverMessages(message);
        }
    } else {
        VLXConductorMessages callback = self.channels[message.channelName];
        if(callback) {
            callback(message);
        }
        callback = self.channels[kVLXAllMessages];
        if(callback) {
            callback(message);
        }
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data
{
    //nothing in conductor for binary right now
}
/////////////////////////////////////////////////////////////////////////////
-(void)websocketDidWriteError:(JFRWebSocket*)socket error:(NSError*)error
{
    //do we need to forward the errors along?
}
/////////////////////////////////////////////////////////////////////////////
-(void)connect
{
    if(!self.isConnected) {
        [self.channels removeAllObjects];
        [self.socket connect];
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)disconnect
{
    if(self.isConnected) {
        [self.channels removeAllObjects];
        [self.socket disconnect];
    }
}
/////////////////////////////////////////////////////////////////////////////

@end

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

@implementation VLXMessage

static NSString *kBody = @"body";
static NSString *kName = @"name";
static NSString *kChannelName = @"channel_name";
static NSString *kOpCode = @"opcode";
static NSString *kAdditional = @"additional";

/////////////////////////////////////////////////////////////////////////////
+(VLXMessage*)messageFromString:(NSString*)jsonString
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    VLXMessage *message = [VLXMessage new];
    message.body = dict[kBody];
    message.name = dict[kName];
    message.channelName = dict[kChannelName];
    message.additional = dict[kAdditional];
    message.opcode = [dict[kOpCode] intValue];
    return message;
}
/////////////////////////////////////////////////////////////////////////////
-(NSString*)toJSONString
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:5];
    if(self.body) {
        [dict setObject:self.body forKey:kBody];
    }
    if(self.name) {
        [dict setObject:self.name forKey:kName];
    }
    if(self.channelName) {
        [dict setObject:self.channelName forKey:kChannelName];
    }
    if(self.additional) {
        [dict setObject:self.additional forKey:kAdditional];
    }
    [dict setObject:@(self.opcode) forKey:kOpCode];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
/////////////////////////////////////////////////////////////////////////////

@end

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

@implementation VLXObserver

@end
