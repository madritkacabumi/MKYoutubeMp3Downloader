//
//  NodeRunner.h
//  MKYoutubeDownloader
//
//  Created by Madrit Kacabumi on 21.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

#ifndef NodeRunner_h
#define NodeRunner_h
#import <Foundation/Foundation.h>

@interface NodeRunner : NSObject {}
+ (void) startEngineWithArguments:(NSArray*)arguments;
@end

#endif
