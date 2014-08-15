/////////////////////////////////////////////////////////////////////////////
//
//  VLXConductor.h
//
//  Created by Dalton Cherry on 8/15/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
/////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@interface VLXConductor : NSObject

typedef NS_ENUM(NSUInteger, VLXConOpCode) {
    VLXConOpCodeWrite  =  2, //normal message to send to all clients
    VLXConOpCodeInfo   =  3, //message not intend for the UI
    VLXConOpCodeServer =  5 //message between just this client and the server
};

typedef void (^VLXConductorMessages)(id object);

/**
 Bind to channel and listen to incoming messages.
 @param: url is the url of the host to bind to (e.g. localhost or xxx.xxx.xxx.xxx).
 @param: authToken is the token to use for authenication to the server.
 @return: returns a new instance of the VLXConductor object
 */
-(instancetype)initWithURL:(NSURL*)url authToken:(NSString*)authToken;

/**
 Bind to channel and listen to incoming messages. 
 The bind/unbind setup allows for multiple observers of channel messages
 to make getting the same message in multiple locations simple (e.g. a view controller and your app delegate).
 This will NOT send multiple bind messages and only bind on the first observer. The same also holds true for the unbind 
 and it will only send an unbind message once all observers have been removed.
 
 @param: channelName is the name of the channel to bind to
 @param: observer is the object that is listening for the messages (e.g. your view controller object)
 @param: messages is the block that will send message objecs as they come in.
 */
-(void)bind:(NSString*)channelName observer:(id)observer messages:(VLXConductorMessages)messages;

/**
 Unbind from the channel and stop listen for messages on it. 
 See the @bind method for more information.
 @param: channelName is the name of the channel to unbind from.
 @param: observer is the object that was listening for the messages (e.g. your view controller object)
 */
-(void)unbind:(NSString*)channelName observer:(id)observer;

/**
 Send a message to channel.
 @param: body is the text to send in the body of the message
 @param: channel is the channelName to send the message to.
 @param: opcode is the code to intend the desired action of the message
 @param: additional is any additional values to send along with the core messages (this needs to be able to be serialized into JSON with the NSJSONSerializtion API)
 */
-(void)sendMessage:(NSString*)body channel:(NSString*)channelName opcode:(VLXConOpCode)code additional:(id)object;

@end
