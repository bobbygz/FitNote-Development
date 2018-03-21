//
//  Speak.h
//  FitScribe
//
//  Created by Bobby Gintz on 1/28/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Speak : NSObject
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;


- (void) speakText:(NSString *) textToSpeak;
- (void) speakNumber:(int) numberToSpeak;


- (NSString *) spellInt:(int)number;
@end
