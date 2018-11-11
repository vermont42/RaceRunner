//
//  AVAudioSessionPatch.h
//  RaceRunner
//
//  Created by Joshua Adams on 11/10/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

#ifndef AVAudioSessionPatch_h
#define AVAudioSessionPatch_h

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioSessionPatch : NSObject

+ (BOOL)setSession:(AVAudioSession *)session category:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(__autoreleasing NSError **)outError;

@end

NS_ASSUME_NONNULL_END

#endif /* AVAudioSessionPatch_h */
