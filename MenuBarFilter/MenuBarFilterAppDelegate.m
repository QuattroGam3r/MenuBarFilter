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
    [invertWindow setFilter:@"CIColorInvert"];
    
    // create hue overlay
    hueWindow = [[MenuBarFilterWindow alloc] init];
    [hueWindow setFilter:@"CIHueAdjust"];
    [hueWindow setFilterValues:
     [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:M_PI], 
      @"inputAngle", nil]];  
    
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
    
    if ( [invertWindow respondsToSelector:@selector(toggleFullScreen:)] ) {                                                    
        // lion hack
        NSTimer * timer = [NSTimer timerWithTimeInterval:1
                                                  target:self 
                                                selector:@selector(checkForFullscreen) 
                                                userInfo:nil 
                                                 repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer 
                                  forMode:NSDefaultRunLoopMode];
        
        NSTimer * timer2 = [NSTimer timerWithTimeInterval:.1
                                                  target:self 
                                                selector:@selector(checkForAppSwitch) 
                                                userInfo:nil 
                                                 repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer2
                                  forMode:NSDefaultRunLoopMode];
    }
    
    // show overlays
    [self reposition];
    [invertWindow orderFront:nil];
    [hueWindow orderFront:nil]; 
    visible = YES;
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
            visible = NO;
        } else {
            // show
            [hueWindow orderFront:nil];
            [invertWindow orderFront:nil];
            visible = YES;
        }
        return;
    }
    
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

- (void) checkForFullscreen {
    CGRect r = CGRectMake( 0, 0, 1, 1 );
    
    CGImageRef capturedImage = CGWindowListCreateImage(
                                   r, kCGWindowListOptionOnScreenBelowWindow, 
                                                       [invertWindow windowNumber], kCGWindowImageDefault );
    
    NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:capturedImage];
    
    NSColor * color = [bitmapRep colorAtX:0 y:0];
    if ( [color brightnessComponent] > .9 && !visible ) {
        [hueWindow orderFront:nil];
        [invertWindow orderFront:nil];
        visible = YES;
    }
    else if ( [color brightnessComponent] < .9 && visible ) {
        [hueWindow orderOut:nil];
        [invertWindow orderOut:nil];
        visible = NO;
    }
    
    [bitmapRep release];
    CGImageRelease( capturedImage );
}

- (void) checkForAppSwitch {
    static int previousPid = -1;
    int activePid = [[[[NSWorkspace sharedWorkspace] activeApplication]
                      valueForKey:@"NSApplicationProcessIdentifier"] intValue];
    if ( previousPid != activePid ) {
        [self checkForFullscreen];
        previousPid = activePid;
    }
}

@end
