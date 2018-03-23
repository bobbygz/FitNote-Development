//
//  Speak.m
//  FitScribe
//
//  Created by Bobby Gintz on 1/28/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "Speak.h"

@implementation Speak
@synthesize speechSynthesizer;
- (id)init
{
    self = [super init];
    if (self) {
    speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        
    }
    return self;
}

- (void) speakText:(NSString *) textToSpeak
{
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:textToSpeak];
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    [self.speechSynthesizer speakUtterance:utterance];
}

- (void) speakNumber:(int) numberToSpeak{
    NSString *numberInWordFormat = [self spellInt:numberToSpeak];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:numberInWordFormat];
     utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    [self.speechSynthesizer speakUtterance:utterance];

}


// Say hello
//AVSpeechSynthesizer *speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
//AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"Welcome to Fit Note,  Lets work out!"];
//utterance.rate = AVSpeechUtteranceMaximumSpeechRate/4.0f;
//[speechSynthesizer speakUtterance:utterance];
//utterance = [AVSpeechUtterance  speechUtteranceWithString:@"One"];
//utterance.rate = AVSpeechUtteranceMaximumSpeechRate/4.0f;
//[speechSynthesizer speakUtterance:utterance];
//
//// Convert from number to words
//int testNum = 23;
//NSString *wordNumber;
//NSNumber *numberValue = [NSNumber numberWithInt:testNum]; // needs to ne NSNumber
//NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
//[numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
//wordNumber = [numberFormatter stringFromNumber:numberValue];
//utterance = [AVSpeechUtterance  speechUtteranceWithString:(@"%@",wordNumber)];
//[speechSynthesizer speakUtterance:utterance];


- (NSString *) spellInt:(int)number {
    NSNumber *numberAsNumber = [NSNumber numberWithInt:number];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterSpellOutStyle];
    return [formatter stringFromNumber:numberAsNumber];
}

@end
