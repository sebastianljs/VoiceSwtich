//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/*For the task variable:
 1 = turn on the lights;
 2 = turn off the lights;
 3 = turn on the AC;
 4 = turn off the AC;
 5 = turn on the TV;
 6 = turn off the TV;
 7 = current Temperature;
 8 = current users;
 9 = I don't understand.
 */

#import <AVFoundation/AVFoundation.h>

#import "ViewController.h"

#define API_KEY @"AIzaSyC7vkIp6NHBP58mk3DtCxQ6PUFqEP32_Rc"

#define SAMPLE_RATE 16000

@interface ViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) IBOutlet UITextView *textView;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

char *returnData = "";
int taskVar = 9;

@implementation ViewController

- (NSString *) soundFilePath {
  NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docsDir = dirPaths[0];
  return [docsDir stringByAppendingPathComponent:@"sound.caf"];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSURL *soundFileURL = [NSURL fileURLWithPath:[self soundFilePath]];
  NSDictionary *recordSettings = @{AVEncoderAudioQualityKey:@(AVAudioQualityMax),
                                   AVEncoderBitRateKey: @16,
                                   AVNumberOfChannelsKey: @1,
                                   AVSampleRateKey: @(SAMPLE_RATE)};
  NSError *error;
  _audioRecorder = [[AVAudioRecorder alloc]
                    initWithURL:soundFileURL
                    settings:recordSettings
                    error:&error];
  if (error) {
    NSLog(@"error: %@", error.localizedDescription);
  }
}

- (IBAction)recordAudio:(id)sender {
  if (_audioRecorder.recording) {
        [_audioRecorder stop];
      
      NSString *service = @"https:/speech.googleapis.com/v1beta1/speech:syncrecognize";
      service = [service stringByAppendingString:@"?key="];
      service = [service stringByAppendingString:API_KEY];
      
      NSData *audioData = [NSData dataWithContentsOfFile:[self soundFilePath]];
      NSDictionary *configRequest = @{@"encoding":@"LINEAR16",
                                      @"sampleRate":@(SAMPLE_RATE),
                                      @"languageCode":@"en-US",
                                      @"maxAlternatives":@1};
      NSDictionary *audioRequest = @{@"content":[audioData base64EncodedStringWithOptions:0]};
      NSDictionary *requestDictionary = @{@"config":configRequest,
                                          @"audio":audioRequest};
      NSError *error;
      NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDictionary
                                                            options:0
                                                              error:&error];
      
      NSString *path = service;
      NSURL *URL = [NSURL URLWithString:path];
      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
      [request addValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
      NSString *contentType = @"application/json";
      [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
      [request setHTTPBody:requestData];
      [request setHTTPMethod:@"POST"];
      
      NSURLSessionTask *task =
      [[NSURLSession sharedSession]
       dataTaskWithRequest:request
       completionHandler:
       ^(NSData *data, NSURLResponse *response, NSError *error) {
           dispatch_async(dispatch_get_main_queue(),
                          ^{
                              NSString *stringResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                              _textView.text = stringResult;
                              //returnData = [stringResult UTF8String];
                              NSLog(@"RESULT: %@", stringResult);
                          });
       }];
      [task resume];
      NSString * originalString= @"\"{\"results\": [{\"alternatives\": [{\"transcript\": \"turn off the lights\",\"confidence\": 0.8699}]}]}\"";
      // Intermediate
      NSString *numberString;
      
      NSScanner *scanner = [NSScanner scannerWithString:originalString];
      NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
      
      // Throw away characters before the first number.
      [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
      
      // Collect numbers.
      [scanner scanCharactersFromSet:numbers intoString:&numberString];
      
      // Result.
      double confidence = [numberString doubleValue];
      NSLog(@"confidence is %f", confidence);
      NSString *alteredString = [originalString stringByReplacingOccurrencesOfString:@"confidence"
                                           withString:@"aaaa"];
      if (confidence < 0.40){
          NSLog(@"Sorry I don't understand.");
      } else if (([alteredString localizedCaseInsensitiveContainsString:@"light"])&&([alteredString localizedCaseInsensitiveContainsString:@"on"])){
          taskVar = 1;
      } else if (([alteredString localizedCaseInsensitiveContainsString:@"light"])&&([alteredString localizedCaseInsensitiveContainsString:@"off"])){
          taskVar = 2;
      } else if (([alteredString localizedCaseInsensitiveContainsString:@"AC"])&&([alteredString localizedCaseInsensitiveContainsString:@"on"])){
          taskVar = 3;
      } else if ((([alteredString localizedCaseInsensitiveContainsString:@"television"])||([alteredString localizedCaseInsensitiveContainsString:@"tv"]))&&([alteredString localizedCaseInsensitiveContainsString:@"on"])){
          taskVar = 5;
      } else if ((([alteredString localizedCaseInsensitiveContainsString:@"television"])||([alteredString localizedCaseInsensitiveContainsString:@"tv"]))&&([alteredString localizedCaseInsensitiveContainsString:@"off"])){
          taskVar = 6;
      } else if ([alteredString localizedCaseInsensitiveContainsString:@"temperature"]){
          taskVar = 7;
      } else if ([alteredString localizedCaseInsensitiveContainsString:@"user"]){
          taskVar = 8;
      }
      NSLog(@"TaskVar is %i",taskVar);
      
      switch (taskVar) {
          case 1:
              
              break;
          case 2:
              
              break;
          case 3:
              
              break;
          case 4:
              
              break;
          case 5:
              
              break;
          case 6:
              
              break;
          case 7:
              
              break;
          case 8:
              
              break;
          case 9:
              
              break;
          default:
              break;
      }
      
  } else{
      AVAudioSession *audioSession = [AVAudioSession sharedInstance];
      [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
      [_audioRecorder record];
      }
}

@end
