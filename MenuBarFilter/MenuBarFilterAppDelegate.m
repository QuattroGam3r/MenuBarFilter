//
//  MenuBarFilterAppDelegate.m
//  MenuBarFilter
//
//  Created by eece on 24/02/2011.
//  Copyright 2011 eece. All rights reserved.
//

#import "MenuBarFilterAppDelegate.h"

@implementation MenuBarFilterAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
    
    // create invert overlay
    invertWindow = [[MenuBarFilterWindow alloc] init];
    [invertWindow setLevel:kCGStatusWindowLevel+1];
    [invertWindow setFilter:@"CIColorInvert"];
    [invertWindow setCollectionBehavior:1 | 16];
    
    // create hue overlay
    hueWindow = [[MenuBarFilterWindow alloc] init];
    [hueWindow setLevel:kCGStatusWindowLevel+1];
    [hueWindow setFilter:@"CIHueAdjust"];
    [hueWindow setFilterValues:
     [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:M_PI], 
      @"inputAngle", nil]];  
    [hueWindow setCollectionBehavior:1 | 16];
    
    // add observer for screen changes
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reposition) 
                                                 name:NSApplicationDidChangeScreenParametersNotification 
                                               object:nil];
    
    // add observer for full-screen
    [[NSApplication sharedApplication] addObserver:self
                                        forKeyPath:@"currentSystemPresentationOptions"
                                           options:( NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew )
                                           context:NULL];
    
    // show overlays
    [self reposition];
    [invertWindow orderFront:nil];
    [hueWindow orderFront:nil]; 
}

- (void) reposition {
    CGFloat menuHeight = 21;
    
    NSRect frame = [[NSScreen mainScreen] frame];
    frame.origin.y = NSHeight(frame) - menuHeight;
    frame.size.height = menuHeight;
    
    [hueWindow setFrame:frame display:NO];
    [invertWindow setFrame:frame display:NO];
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    
    if ( [keyPath isEqualToString:@"currentSystemPresentationOptions"] ) {
        if ( [[change valueForKey:@"new"] boolValue] ) {
            // hide
            [hueWindow orderOut:nil];
            [invertWindow orderOut:nil];
        } else {
            // show
            [hueWindow orderFront:nil];
            [invertWindow orderFront:nil];
        }
        return;
    }
    
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

@end
