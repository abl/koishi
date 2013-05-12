//
//  KoishiAppDelegate.m
//  koishi
//
//  Copyright (c) 2013 aleksandyr. All rights reserved.
//

#import "KoishiAppDelegate.h"

#import "KoishiMasterViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

@interface KoishiAppDelegate()
@property (nonatomic, retain) MPMoviePlayerController *audioPlayer;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, retain) KoishiMasterViewController *controller;
@end

@implementation KoishiAppDelegate


@synthesize window = _window;
@synthesize audioPlayer = _audioPlayer;
@synthesize bgTask = _bgTask;

// if the iOS device allows background execution,
// this Handler will be called
- (void)backgroundHandler {
    
    NSLog(@"### -->VOIP backgrounding callback");
    
    UIApplication*    app = [UIApplication sharedApplication];
    
    _bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (1) {
            [_controller drawWatch];
            sleep(1);
        }
    });
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
    if (backgroundAccepted)
    {
        NSLog(@"VOIP backgrounding accepted");
    }
    
    UIApplication*    app = [UIApplication sharedApplication];
    
    _bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }];
    
    
    // Start the long-running task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (1) {
            [_controller drawWatch];
            sleep(1);
        }    
    }); 
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    NSError *myErr;
    
    // Initialize the AVAudioSession here.
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&myErr]) {
        // Handle the error here.
        NSLog(@"Audio Session error %@, %@", myErr, [myErr userInfo]);
    }
    else{
        // Since there were no errors initializing the session, we'll allow begin receiving remote control events
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"silence" ofType:@"wav"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath: path];
    
    _audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [_audioPlayer setShouldAutoplay:YES];
    [_audioPlayer setControlStyle: MPMovieControlStyleEmbedded];
    _audioPlayer.view.hidden = YES;
    
    [_audioPlayer prepareToPlay];
    
    

    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    [self becomeFirstResponder];
    
    //[_audioPlayer play];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    _controller = [[KoishiMasterViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:_controller];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPreviousTrack:
                NIDPRINT(@"Previous");
                [_controller previousWatch];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NIDPRINT(@"Next");
                [_controller nextWatch];
                break;
            
            case UIEventSubtypeRemoteControlPlay:
                NIDPRINT(@"Play");
                [_controller actionWatch];
                break;
                
            default:
                NIDPRINT(@"UNSUPPORTED");
                break;
        }
    }
}

@end
