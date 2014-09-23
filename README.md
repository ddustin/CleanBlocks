CleanBlocks
===========

A simpler way use blocks safely.

CleanBlocks also keeps code flow in a visually apparently order that avoids excessive indentation while working well with Xcode's autocompletion.

### Fill self.label.text with the text of google.com

```objective-c
    [[CB weak:self background:^id(CB *cb) {
        
        return [NSString stringWithContentsOfURL:[NSURL URLWithString:@"google.com"]
                                        encoding:NSUTF8StringEncoding
                                           error:nil];
        
    }] foreground:^(CB *cb, id result) {
        
        CBSELF.label.text = result;
    }];
```

CB will keep a weak reference to self. Before calling the foreground block it will strongify the self reference. If the result of strongifying is nil, the foreground method will safely not be called. This can happen if, for instance, self is a view controller that has been dismissed.

To install:
- Drag CB.h and CB.m to your Project Manager tap (on the left)
- Make sure "Copy items into destination group's folder" is checkmarked
- Modify &lt;Project Name&gt;-Prefix.pch to have this line
```objective-c
#import "CB.h"
```

And enjoy! Check out more complicated examples that are supported.

### Chain multiple foreground and background calls together

```objective-c
    [[[[CB weak:self parameter:self.query1 background:^id(CB *cb, id object) {
        
        return [Server.shared myLongRunningFunction:object];
        
    }] foregroundChain:^id(CB *cb, id result) {
        
        CBSELF.label1.text = result;
        
        return CBSELF.query2;
        
    }] backgroundChain:^id(CB *cb, id result) {
        
        return [Server.shared myLongRunningFunction:object];
        
    }] foreground:^(CB *cb, id result) {
        
        CBSELF.label2.text = result;
    }];
```

### Manually handle weakSelf and strongSelf reference for use with legacy syntax

Sometimes you need to use an api with a block callback but you still want to handle self safely.

```objective-c
    CBWEAKSELF
    
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        CBSTRONGSELFRETURN
        
        strongSelf.label.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }];
```
