//
//  KoishiStatusWatchController.m
//  koishi
//
//  Copyright (c) 2013 aleksandyr. All rights reserved.
//

#import "KoishiStatusWatchController.h"

#import "NimbusCore.h"

@implementation KoishiStatusWatchController
- (void) onAction {
    
}

- (void) onDraw {
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    NSString *batteryString;
    NSString *stateString;
    
    float batteryLevel = floorf([[UIDevice currentDevice] batteryLevel]*100);
    
    switch ([[UIDevice currentDevice] batteryState]) {
        case UIDeviceBatteryStateCharging:
            batteryString = [NSString stringWithFormat:@"%d%%", (int)batteryLevel];
            stateString = @"Charging";
            break;
            
        case UIDeviceBatteryStateFull:
            batteryString = [NSString stringWithFormat:@"%d%%", (int)batteryLevel];
            stateString = @"Full";
            break;
        
        case UIDeviceBatteryStateUnknown:
            batteryString = @"Unknown";
            stateString = @"Unknown";
            break;
        
        case UIDeviceBatteryStateUnplugged:
            batteryString = [NSString stringWithFormat:@"%d%%", (int)batteryLevel];
            stateString = @"Unplugged";
            break;

        default:
            batteryString = [NSString stringWithFormat:@"%d%%", (int)batteryLevel];
            stateString = @"???";
            break;
    }
    
    
    [songInfo setObject:@"Status" forKey:MPMediaItemPropertyArtist];
    [songInfo setObject:batteryString forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:stateString forKey:MPMediaItemPropertyAlbumTitle];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
}

- (void) onLoad {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    NIDPRINT("KoishiStatusWatchController loaded!");
}

- (void) onExit {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    NIDPRINT("KoishiStatusWatchController unloaded!");
}
@end
