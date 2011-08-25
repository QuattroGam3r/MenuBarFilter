//
//  MenuBarFilterAppDelegate.h
//  MenuBarFilter
//
//  Created by eece on 24/02/2011.
//  Copyright 2011 eece. All rights reserved.
//

#include "MenuBarFilterWindow.h"

@interface MenuBarFilterAppDelegate : NSObject <NSApplicationDelegate> {

@private
    MenuBarFilterWindow * invertWindow;
    MenuBarFilterWindow * hueWindow;
    BOOL visible;

}

- (void) reposition;

@end
