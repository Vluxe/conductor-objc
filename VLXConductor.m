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

@interface VLXMessage ()

+(VLXMessage*)messageFromString:(NSString*)jsonString;
-(NSString*)toJSONString;

@end

@interface VLXObserver : NSObject

@property(nonatomic,strong)VLXConductorMessages messages;
@property(nonatomic,strong)id observer;

@end

@interface VLXConductor ()<JFWebSocketDelegate>

@property(nonatomic,strong)JFWebSocket *socket;
@property(nonatomic,strong)NSMutableDictionary *channels;
@property(nonatomic,strong)NSMutableArray *serverArray;

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
        [self writeMessage:@"" channel:channelName opcode:1 additional:nil];
        array = [[NSMutableArray alloc] init];
        [self.channels setObject:array forKey:channelName];
    }
    BOOL add = NO;
    VLXObserver *obs = [self findObs:channelName observer:observer];
    if(!obs) {
        add = YES;
        obs = [[VLXObserver alloc] init];
        obs.observer = observer;
    }
    obs.messages = messages;
    if(add) {
        [array addObject:obs];
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)unbind:(NSString*)channelName observer:(id)observer
{
    VLXObserver *obs = [self findObs:channelName observer:observer];
    NSMutableArray *array = self.channels[channelName];
    [array removeObject:obs];
    if(array.count == 0) {
        [self writeMessage:@"" channel:channelName opcode:2 additional:nil];
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)serverBind:(id)observer messages:(VLXConductorMessages)messages
{
    if(!self.serverArray) {
        self.serverArray = [[NSMutableArray alloc] init];
    }
    VLXObserver *obs = [self findServerObs:observer];
    BOOL add = NO;
    if(!obs) {
        add = YES;
        obs = [[VLXObserver alloc] init];
        obs.observer = observer;
    }
    obs.messages = messages;
    if(add) {
        [self.serverArray addObject:obs];
    }
}
/////////////////////////////////////////////////////////////////////////////
-(void)serverUnbind:(id)observer
{
    VLXObserver *obs = [self findServerObs:observer];
    [self.serverArray removeObject:obs];
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
-(void)sendInvite:(NSString*)name channel:(NSString*)channelName
{
    [self writeMessage:name channel:channelName opcode:VLXConOpCodeInvite additional:nil];
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
-(VLXObserver*)findObs:(NSString*)channelName observer:(id)observer
{
    NSMutableArray *array = self.channels[channelName];
    for(VLXObserver *obs in array) {
        if(obs.observer == observer) {
            return obs;
        }
    }
    return nil;
}
/////////////////////////////////////////////////////////////////////////////
-(VLXObserver*)findServerObs:(id)observer
{
    for(VLXObserver *obs in self.serverArray) {
        if(obs.observer == observer) {
            return obs;
        }
    }
    return nil;
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
    VLXMessage *message = [VLXMessage messageFromString:string];
    if(message.opcode == VLXConOpCodeWrite || message.opcode == VLXConOpCodeInfo ||
       message.opcode == VLXConOpCodeInvite) {
        NSArray *array = self.channels[message.channelName];
        for(VLXObserver *obs in array) {
            obs.messages(message);
        }
        array = self.channels[kVLXAllMessages];
        for(VLXObserver *obs in array) {
            obs.messages(message);
        }
    } else if(message.opcode == VLXConOpCodeServer) {
        for(VLXObserver *obs in self.serverArray) {
            obs.messages(message);
        }
    }
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

@implementation VLXMessage

static NSString *kBody = @"body";
static NSString *kName = @"name";
static NSString *kChannelName = @"channelName";
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
    [dict setObject:self.body forKey:kBody];
    [dict setObject:self.name forKey:kName];
    [dict setObject:self.channelName forKey:kChannelName];
    [dict setObject:self.additional forKey:kAdditional];
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
