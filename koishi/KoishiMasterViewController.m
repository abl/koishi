//
//  KoishiAppDelegate.h
//  koishi
//
//  Copyright (c) 2013 aleksandyr. All rights reserved.
//

#import "KoishiMasterViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"
#import "KoishiWatchController.h"

@interface KoishiMasterViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@property (nonatomic, readwrite, retain) KoishiWatchController* watch;
//@property (nonatomic, readwrite, retain) NSMutableDictionary* properties;
//@property (nonatomic, readwrite, retain) AVPlayer* player;
@property (nonatomic, readwrite, retain) NSMutableDictionary *faces;
@end

@implementation KoishiMasterViewController

@synthesize model = _model;
@synthesize properties = _properties;

int indexWatch;

- (void)nextIndex:(signed)direction {
    signed start = indexWatch;
    signed index = start+direction;
    NSArray *ordering = [_properties valueForKey:@"Ordering"];
    NSArray *options = [_properties valueForKey:@"Options"];
    while (1) {
        if(index < 0) {
            index = ordering.count-1;
        }
        else if(index >= ordering.count) {
            index = 0;
        } 
        NSString *key = ordering[index];
        NSString *option = [options valueForKey:key];
        NSNumber *enabled = [option valueForKey:@"Enabled"];
        if(enabled.boolValue) {
            break;
        }
        index += direction;
        if(index == start)
            break;
    }
    
    NIDPRINT(@"Loading face %@", ordering[index]);
    
    indexWatch = index;
    _watch = _faces[ordering[indexWatch]];
}

- (void)previousWatch {
    if(_watch != nil) {
        [_watch onExit];
    }
    
    [self nextIndex:-1];
    
    if(_watch != nil) {
        [_watch onLoad];
    }
    
    [self drawWatch];
}

- (void)nextWatch {
    if(_watch != nil) {
        [_watch onExit];
    }

    [self nextIndex:1];
    
    if(_watch != nil) {
        [_watch onLoad];
    }
    
    [self drawWatch];
}

- (void)actionWatch {
    if(_watch != nil) {
        [_watch onAction];
        [self drawWatch];
    }
}

- (void)drawWatch {
    if(_watch != nil) {
        [_watch onDraw];
    } else {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        [songInfo setObject:_properties[@"Ordering"][indexWatch] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:@"Not Implemented" forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:@"Koishi" forKey:MPMediaItemPropertyAlbumTitle];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

- (void)createDefaultPropertyList {
    const bool defaultValue = YES;
    
    NSMutableDictionary *root = [NSMutableDictionary dictionaryWithCapacity:3];
    [root setObject:[NSNumber numberWithInt:1] forKey:@"Version"];
    NSMutableArray *ordering = [NSMutableArray arrayWithObjects:
                                @"Status",
                                @"Calendar",
                                @"Stocks",
                                @"GPS",
                                @"Music",
                                @"Volume",
                                @"Camera",
                                @"Siri",
                                nil];
    [root setObject:ordering forKey:@"Ordering"];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:ordering.count];
    
    [ordering componentsJoinedByString:@""];
    
    for(NSString *key in ordering) {
        NSMutableDictionary *option = [NSMutableDictionary dictionaryWithCapacity:2];
        [option setObject:[NSNumber numberWithBool:defaultValue] forKey:@"Enabled"];
        [option setObject:[[NSArray arrayWithObjects:@"Koishi",@"WatchController",nil] componentsJoinedByString:key] forKey:@"Class"];
        [options setObject:option forKey:key];
    }
    
    [root setObject:options forKey:@"Options"];

    _properties = root;
    
    [self savePropertyList];
}

- (void)savePropertyList {
    NSString *error;
    NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:(id)_properties
                                                                 format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"Settings" ofType:@"plist"];
    
    if(xmlData) {
        NIDPRINT(@"Saving status to plist");
        [xmlData writeToFile:path atomically:YES];
    }
    else {
        NIDPRINT(@"%@", error);
    }
}

- (void)tryLoadPropertyList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSString *error = nil;
    NSPropertyListFormat format;
    id plist;
    
    plist = [NSPropertyListSerialization propertyListFromData:plistData
                                             mutabilityOption:NSPropertyListImmutable
                                                       format:&format
                                             errorDescription:&error];
    if(plist){
        NSMutableDictionary *newProperties = plist;
        if(newProperties.count < 3) {
            error = @"Found empty settings; initializing with defaults.";
        }
        else {
            _properties = newProperties;
            return;
        }
    }
    
    NIDPRINT(@"%@", error);
    [self createDefaultPropertyList];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        [self tryLoadPropertyList];
        self.title = @"Koishi";
        
        NSArray *ordering = [_properties valueForKey:@"Ordering"];
        NSMutableArray* tableContents = [NSMutableArray arrayWithCapacity:ordering.count];
        NSDictionary* options = [_properties valueForKey:@"Options"];
        int index = 0;
        
        _faces = [[NSMutableDictionary alloc] initWithCapacity:ordering.count];
        
        for(NSString *key in ordering) {
            NSDictionary *option = [options valueForKey:key];
            NSNumber *enabled = [option valueForKey:@"Enabled"];
            [tableContents addObject:
             [NISwitchFormElement switchElementWithID:index++ labelText:key value:enabled.boolValue didChangeTarget:self didChangeSelector:@selector(switchDidChangeValue:)]
             ];
            
            Class face = NSClassFromString(options[key][@"Class"]);
            
            if(face == nil) {
                NIDPRINT(@"Could not dynaload %@", options[key][@"Class"]);
                continue;
            }
            NIDPRINT(@"Dynaloading %@", options[key][@"Class"]);
            
            KoishiWatchController *faceInstance = [[face alloc] init];
            
            [faceInstance onLoad];
            
            [_faces setObject:faceInstance forKey:key];
            
            if(enabled.boolValue && _watch == nil) {
                indexWatch = index-1;
                _watch = faceInstance;
                [self drawWatch];
            }
            
        }
        
        // We want to treat the table contents as a sectioned array, so we use
        // initWithSectionedArray:delegate: here.
        _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                         delegate:(id)[NICellFactory class]];
    }
    return self;
}

- (void)switchDidChangeValue:(UISwitch *)switchUI {
    NSArray *ordering = [_properties valueForKey:@"Ordering"];
    NSString *key = ordering[switchUI.tag];
    NIDPRINT(@"Toggled %@ to %d", key, switchUI.on);
    
    [[[_properties valueForKey:@"Options"] valueForKey:key] setObject:[NSNumber numberWithBool:switchUI.on] forKey:@"Enabled"];
    [self savePropertyList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = _model;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
