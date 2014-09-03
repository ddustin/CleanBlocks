//
//  CB.h
//  Furniture
//
//  Created by Dustin Dettmer on 8/27/14.
//  Copyright (c) 2014 Dustin Dettmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CB : NSObject

@property (weak, readonly) id weakSelf;
@property (strong, readonly) id strongSelf; // Set to the value of weakSelf before foreground calls and nil'ed afterwards

+ (instancetype)weak:(__weak id)weakSelf background:(id(^)(CB *cb))block;
+ (instancetype)weak:(__weak id)weakSelf parameter:(id)object background:(id(^)(CB *cb, id object))block;
+ (instancetype)weak:(__weak id)weakSelf after:(double)delay foreground:(void(^)(CB *cb))block;

// StrongSelf will be nil when background events are called
- (CB*)background:(void(^)(CB *cb, id result))block;
- (CB*)backgroundChain:(id(^)(CB *cb, id result))block;

// Before foreground events are called, strongSelf is assigned to the value of
// weak self. If that is nil, the foreground event is not called.
// After the call finishes, strongSelf will be set to nil again.
- (CB*)foreground:(void(^)(CB *cb, id result))block;
- (CB*)foregroundChain:(id(^)(CB *cb, id result))block;

@end

// Helper macro to access strongSelf in the foreground.
#define CBSELF ((typeof(self))cb.strongSelf)

// For use with legacy block block callback methods
#define CBWEAKSELF __weak typeof(self) weakSelf = self;
#define CBSTRONGSELF __strong typeof(self) strongSelf = weakSelf;
#define CBSTRONGSELFRETURN CBSTRONGSELF if(!strongSelf) return;
