//
//  CB.h
//  Furniture
//
//  Created by Dustin Dettmer on 8/27/14.
//  Copyright (c) 2014 Dustin Dettmer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CBCallbackType)(id result);

@interface CB : NSObject

@property (weak) id weakSelf;
@property (strong) id strongSelf; // Set to the value of weakSelf before block calls and nil'ed afterwards

+ (instancetype)weak:(__weak id)weakSelf parameter:(id)object background:(id(^)(CB *cb, id object))block;

- (CB*)background:(void(^)(CB *cb, id result))block;
- (CB*)backgroundChain:(id(^)(CB *cb, id result))block;

// Foreground events will not fire if weakSelf is nil / released.
- (CB*)foreground:(void(^)(CB *cb, id result))block;
- (CB*)foregroundChain:(id(^)(CB *cb, id result))block;

@end

#define CBSELF ((typeof(self))cb.strongSelf)

// For use with legacy block block callback methods
#define CBWEAKSELF __weak typeof(self) weakSelf = self;
#define CBSTRONGSELF __strong typeof(self) strongSelf = weakSelf;
#define CBSTRONGSELFRETURN CBSTRONGSELF if(!strongSelf) return;
