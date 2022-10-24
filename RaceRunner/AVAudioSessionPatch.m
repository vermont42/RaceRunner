//
//  AVAudioSessionPatch.m
//  RaceRunner
//
//  Created by Josh Adams on 11/10/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

#import "AVAudioSessionPatch.h"
#import <Foundation/Foundation.h>

@implementation AVAudioSessionPatch

+ (BOOL)setSession:(AVAudioSession *)session category:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(__autoreleasing NSError **)outError {
  return [session setCategory:category withOptions:options error:outError];
}

@end
