//
//  MenuBarFilterWindow.h
//  MenuBarFilter
//
//  Created by eece on 24/02/2011.
//  Copyright 2011 eece. All rights reserved.
//

@interface MenuBarFilterWindow : NSWindow {

@private
	long wid;
	void * fid;
}

- (void) setFilter:(NSString *)filterName;
- (void) setFilterValues:(NSDictionary *)filterValues;

@end
