/////////////////////////////////////////////////////////////////////////////
//
//  VLXConductor.h
//
//  Created by Dalton Cherry on 8/15/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
/////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VLXConOpCode) {
    VLXConOpCodeBind   =  1, //normal message to send to all clients
    VLXConOpCodeUnBind =  2, //normal message to send to all clients
    VLXConOpCodeWrite  =  3, //normal message to send to all clients
    VLXConOpCodeInfo   =  4, //message not intend for the UI
    VLXConOpCodeServer =  7, //message between just this client and the server
    VLXConOpCodeInvite =  8  //Invite a user to a channel
};

@interface VLXMessage : NSObject

@property(nonatomic,copy)NSString *name; //only used in responses
@property(nonatomic,copy)NSString *body;
@property(nonatomic,copy)NSString *channelName;
@property(nonatomic,assign)VLXConOpCode opcode;
@property(nonatomic,strong)id additional;

@end

static NSString *kVLXAllMessages = @"*";

@interface VLXConductor : NSObject

/**
 Returns the status if the client is connected to the server.
 */
@property(nonatomic,readonly,assign)BOOL isConnected;

typedef void (^VLXConductorMessages)(VLXMessage *message);
typedef void (^VLXConductorConnection)(BOOL isConnected);

/**
 Bind to channel and listen to incoming messages.
 @param: url is the url of the host to bind to (e.g. localhost or xxx.xxx.xxx.xxx).
 @param: authToken is the token to use for authenication to the server.
 @return: returns a new instance of the VLXConductor object
 */
-(instancetype)initWithURL:(NSURL*)url authToken:(NSString*)authToken;

/**
 Set the authToken.
 @param: token is the authToken to use.
 */
-(void)setAuthToken:(NSString*)token;

/**
 Bind to channel and listen to incoming messages.
 
 @param: channelName is the name of the channel to bind to
 @param: messages is the block that will send message objecs as they come in.
 */
-(void)bind:(NSString*)channelName messages:(VLXConductorMessages)messages;

/**
 Unbind from the channel and stop listen for messages on it.
 See the @bind method for more information.
 @param: channelName is the name of the channel to unbind from.
 */
-(void)unbind:(NSString*)channelName;

/**
 Bind which starts listen to incoming server opcode messages.
 Server messages don't use channels, so this is standalone
 
 @param: messages is the block that will send message objecs as they come in.
 */
-(void)serverBind:(VLXConductorMessages)messages;

/**
 Unbind from listening to server messages.
 See the @bind method for more information.
 */
-(void)serverUnbind;

/**
 Send a standard write message to channel.
 @param: body is the text to send in the body of the message
 @param: channel is the channelName to send the message to.
 @param: additional is any additional values to send along with the core messages (this needs to be able to be serialized into JSON with the NSJSONSerializtion API)
 */
-(void)sendMessage:(NSString*)body channel:(NSString*)channelName additional:(id)object;

/**
 Send an info message to channel.
 @param: body is the text to send in the body of the message
 @param: channel is the channelName to send the message to.
 @param: additional is any additional values to send along with the core messages (this needs to be able to be serialized into JSON with the NSJSONSerializtion API)
 */
-(void)sendInfo:(NSString*)body channel:(NSString*)channelName additional:(id)object;

/**
 Invite a user to channel.
 @param: name is the username to send in the invite to
 @param: channel is the channelName to send the message to.
 @param: additional is any additional values to send along with the core messages (this needs to be able to be serialized into JSON with the NSJSONSerializtion API)
 */
-(void)sendInvite:(NSString*)name channel:(NSString*)channelName additional:(id)object;

/**
 Send an server message to channel.
 @param: body is the text to send in the body of the message
 @param: channel is optional in this case. It is only used for contextual information
 @param: additional is any additional values to send along with the core messages (this needs to be able to be serialized into JSON with the NSJSONSerializtion API)
 */
-(void)sendServerMessage:(NSString*)body channel:(NSString*)channelName additional:(id)object;

/**
 Notifies when connection state changes (disconnected or connected).
 @param: connection is the block that will send yes or no depend on if connection state has changed.
 */
-(void)connectionState:(VLXConductorConnection)connection;

/**
 Connect to the server
 */
-(void)connect;

/**
 Disconnect to the server
 */
-(void)disconnect;

@end
