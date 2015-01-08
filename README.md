conductor-objc
==============

Objective-C client library for conductor. See the server implementation here: [conductor](https://github.com/Vluxe/conductor).

## Example

The first step is to setup where to connect. This would be somewhere that is only run once to alloc the object.

```objc
//self.conductor is a property in your app delegate, singleton, or whatever works best for your implementation.
self.conductor = [[VLXConductor alloc] initWithURL:[NSURL URLWithString:@"myConductorServer"] authToken:@"mytoken"];
//"myConductorServer" is the address of your conductor server (standard resources, like domains or IPs).
//"mytoken" is the auth token to connect to the stream as. This also depends our your conductor server implementation. Normally this is used as a standard authToken to identify the user connecting. 
```

Next connect to the stream:

```objc
[self.conductor connect];
```

That is it! You can now bind to channels and send messages. To learn more about the different message types see here: [conductor](https://github.com/Vluxe/conductor).

### Bind

```objc
[self.conductor connect];
```

### Unbind

```objc
[self.conductor connect];
```

### ServerBind

```objc
[self.conductor connect];
```

### Write Message

This is the standard message type of "Write". This message type is to be treated

```objc
[self.conductor sendMessage:@"Hello world!" channel:@"myChannel" additional:nil];
```

### Info Message

This is the message type of "Info". This message type is designed to just be used as information and not as important as the "Write" message.

```objc
[self.conductor sendInfo:@"Hello world!" channel:@"myChannel" additional:nil];
```

### Server Message

This is the message type of "Server". The "channel" parameter is optional in this case. It is only used for contextual information. This message type is only a 1 to 1 with the conductor server and is used only to fetch/notify information the server stores or needs (e.g. message history).

```objc
[self.conductor sendServer:@"History" channel:@"" additional:nil];
```

### Invite Message

This is the message type of "Invite". This message type is used to invite a user to a channel.

```objc
[self.conductor sendInvite:@"username" channel:@"myChannel" additional:nil];
```

### Message Notes
 
The additional field is used to send extra information that doesn't fit in the message text body. This object needs be serializable into JSON with the NSJSONSerializtion API.

### connectionState

```objc
[self.conductor connectionState:^(BOOL connected){
	//if connected is YES, then the state changed to connected.
}];
```

### connect

Connect to the conductor server if not already connected.

```objc
[self.conductor connect];
```

### disconnect

Disconnect from the conductor server if connected.

```objc
[self.conductor disconnect];
```

## Install

The recommended approach for installing conductor is via the CocoaPods package manager.

```ruby
pod "conductor-objc"
```

## Requirements

conductor-objc depends on [jetfire](https://github.com/acmacalister/jetfire).

OS X 10.9/iOS 7 or higher.

## License

Conductor is licensed under the Apache v2 License.

## Contact

### Vluxe
* https://github.com/Vluxe
* https://twitter.com/vluxeio
* vluxe.io

### Dalton Cherry
* https://github.com/daltoniam
* http://twitter.com/daltoniam
* http://daltoniam.com
