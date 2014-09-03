//
//  CB.m
//  Furniture
//
//  Created by Dustin Dettmer on 8/27/14.
//  Copyright (c) 2014 Dustin Dettmer. All rights reserved.
//

#import "CB.h"

typedef void (^CBCallbackBlock)(CB *cb, id result);
typedef id (^CBCallbackBlockChain)(CB *cb, id result);

@interface CBEvent : NSObject

@property (strong) id block;
@property (strong) dispatch_queue_t queue;
@property (assign) BOOL chain;

@end

@implementation CBEvent
@end

@interface CB ()

@property (weak, readwrite) id weakSelf;
@property (strong, readwrite) id strongSelf;

@property (strong) NSMutableArray *events;

@end

@implementation CB

- (void)fire:(CBEvent*)event result:(id)parameter
{
    dispatch_async(event.queue, ^{
        
        id result = nil;
        
        if(event.queue == dispatch_get_main_queue()) {
            
            self.strongSelf = self.weakSelf;
            
            if(!self.strongSelf)
                return;
        }
        
        if(event.chain) {
            
            result = ((CBCallbackBlockChain)event.block)(self, parameter);
        }
        else {
            
            ((CBCallbackBlock)event.block)(self, parameter);
        }
        
        self.strongSelf = nil;
        
        CBEvent *event = self.events.firstObject;
        
        if(event) {
            
            [self.events removeObjectAtIndex:0];
            
            [self fire:event result:result];
        }
    });
}

+ (instancetype)weak:(__weak id)weakSelf parameter:(id)object background:(id(^)(CB *cb, id object))block
{
    CB *cb = [CB new];
    
    cb.weakSelf = weakSelf;
    cb.events = [NSMutableArray array];
    
    CBEvent *event = [CBEvent new];
    
    event.block = block;
    event.queue = dispatch_get_global_queue(0, 0);
    event.chain = YES;
    
    [cb fire:event result:object];
    
    return cb;
}

+ (instancetype)weak:(__weak id)weakSelf background:(id (^)(CB *))block
{
    return [self weak:weakSelf parameter:nil background:^id(CB *cb, id object) {
        
        return block(cb);
    }];
}

- (CB*)background:(void(^)(CB *cb, id result))block
{
    CBEvent *event = [CBEvent new];
    
    event.block = block;
    event.queue = dispatch_get_global_queue(0, 0);
    
    [self.events addObject:event];
    
    return self;
}

- (CB*)backgroundChain:(id(^)(CB *cb, id result))block
{
    CBEvent *event = [CBEvent new];
    
    event.block = block;
    event.queue = dispatch_get_global_queue(0, 0);
    event.chain = YES;
    
    [self.events addObject:event];
    
    return self;
}

- (CB*)foreground:(void(^)(CB *cb, id result))block
{
    CBEvent *event = [CBEvent new];
    
    event.block = block;
    event.queue = dispatch_get_main_queue();
    
    [self.events addObject:event];
    
    return self;
}

- (CB*)foregroundChain:(id(^)(CB *cb, id result))block
{
    CBEvent *event = [CBEvent new];
    
    event.block = block;
    event.queue = dispatch_get_main_queue();
    event.chain = YES;
    
    [self.events addObject:event];
    
    return self;
}

@end
