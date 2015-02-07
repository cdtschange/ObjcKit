//
//  Speecher.m
//  Yumi
//
//  Created by Mao on 15/2/7.
//  Copyright (c) 2015年 Mao. All rights reserved.
//  Referred from Hark Github
//

#import "Speecher.h"
#import <AVFoundation/AVFoundation.h>

@interface Speecher()<AVSpeechSynthesizerDelegate>

@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, assign) BOOL speaking;

@end

@implementation Speecher


+ (Speecher *)shared{
    static Speecher *shared_ = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        shared_ = [[Speecher alloc] init];
    });
    return shared_;
}

-(instancetype)init{
    if (self = [super init]) {
        
        NSError *error = nil;
        if(![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error]){
            NSLog(@"%@", error);
        }
        self.rate = 0.1;
        self.volume = 1;
        self.pitchMultiplier = 1;
    }
    return self;
}

-(void)speakWithText:(NSString *)text{
    if (!self.speechSynthesizer) {
        self.speechSynthesizer = [AVSpeechSynthesizer new];
        self.speechSynthesizer.delegate = self;
    }
    if(self.speechSynthesizer.isSpeaking){
        [self stopSpeak];
    }
    NSString *voiceLanguage = [self voiceLanguageForText:text];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    if([voiceLanguage length]){
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:voiceLanguage];
    }
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate + self.rate * (AVSpeechUtteranceMaximumSpeechRate-AVSpeechUtteranceMinimumSpeechRate);
    utterance.volume = self.volume;
    utterance.pitchMultiplier = self.pitchMultiplier;
    [self.speechSynthesizer speakUtterance:utterance];
}
-(void)stopSpeak{
    if(self.speechSynthesizer.isSpeaking){
        [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (NSString *)voiceLanguageForText:(NSString *)text{
    CFRange range = CFRangeMake(0, MIN(400, text.length));
    NSString *currentLanguage = [AVSpeechSynthesisVoice currentLanguageCode];
    NSString *language = (NSString *)CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, range));
    if(language && ![currentLanguage hasPrefix:language]){
        NSArray *availableLanguages = [[AVSpeechSynthesisVoice speechVoices] valueForKeyPath:@"language"];
        if([availableLanguages containsObject:language]){
            return language;
        }
        // TODO: also support Cantonese (zh-HK)
        // Language code translations for simplified and traditional Chinese
        if([language isEqualToString:@"zh-Hans"]){
            return @"zh-CN";
        }
        if([language isEqualToString:@"zh-Hant"]){
            return @"zh-TW";
        }
        // Fall back to searching for languages starting with the current language code
        NSString *languageCode = [[language componentsSeparatedByString:@"-"] firstObject];
        for(NSString *language in availableLanguages){
            if([language hasPrefix:languageCode]){
                return language;
            }
        }
    }
    
    return currentLanguage;
}

#pragma mark - delegate


- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    self.speaking = NO;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    self.speaking = YES;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    self.speaking = NO;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    self.speaking = NO;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    self.speaking = YES;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
}

@end
