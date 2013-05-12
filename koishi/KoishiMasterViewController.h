//
//  KoishiAppDelegate.h
//  koishi
//
//  Copyright (c) 2013 aleksandyr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

// All docs are in the .m.
@interface KoishiMasterViewController : UITableViewController
@property (nonatomic, readwrite, retain) NSMutableDictionary* properties;

- (void)previousWatch;
- (void)nextWatch;
- (void)actionWatch;
- (void)drawWatch;

@end
