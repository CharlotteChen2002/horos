/*=========================================================================
 This file is part of the Horos Project (www.horosproject.org)
 
 Horos is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation,  version 3 of the License.
 
 The Horos Project was based originally upon the OsiriX Project which at the time of
 the code fork was licensed as a LGPL project.  However, not all of the the source-code
 was properly documented and file headers were not all updated with the appropriate
 license terms. The Horos Project, originally was licensed under the  GNU GPL license.
 However, contributors to the software since that time have agreed to modify the license
 to the GNU LGPL in order to be conform to the changes previously made to the
 OsiriX Project.
 
 Horos is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY EXPRESS OR IMPLIED, INCLUDING ANY WARRANTY OF
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE OR USE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with Horos.  If not, see http://www.gnu.org/licenses/lgpl.html
 
 Prior versions of this file were published by the OsiriX team pursuant to
 the below notice and licensing protocol.
 ============================================================================
 Program:   OsiriX
  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - LGPL
  
  See http://www.osirix-viewer.com/copyright.html for details.
     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
 ============================================================================*/

#import "OsiriXToolbar.h"
#import "ViewerController.h"
#import "ToolbarPanel.h"
#import "NSWindow+N2.h"
#import <objc/runtime.h>

@implementation OsiriXToolbar

- (void)runCustomizationPalette:(id)sender
{
	[super runCustomizationPalette: sender];
}

@end

// Horos' toolbar icons are large PDFs (~530pt). Older AppKit scaled image-based toolbar
// items down to the standard 32pt automatically; the macOS 26+ toolbar lays items out at
// the image's intrinsic size, so the toolbar grows to fill most of the window. Clamp every
// image set on a toolbar item (browser, viewers, plugins) to the classic 32pt size.

static const CGFloat HorosToolbarItemImageMaxSize = 32;

@implementation NSToolbarItem (HorosToolbarImageSize)

+ (void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        Method original = class_getInstanceMethod(self, @selector(setImage:));
        Method clamped = class_getInstanceMethod(self, @selector(horos_setImageClampedToToolbarSize:));
        if (original && clamped)
            method_exchangeImplementations(original, clamped);
    });
}

- (void)horos_setImageClampedToToolbarSize:(NSImage *)image
{
    NSSize size = image.size;
    if (image && (size.width > HorosToolbarItemImageMaxSize || size.height > HorosToolbarItemImageMaxSize))
    {
        CGFloat scale = HorosToolbarItemImageMaxSize / MAX(size.width, size.height);
        image = [[image copy] autorelease]; // don't resize the shared +imageNamed: instance
        image.size = NSMakeSize(round(size.width * scale), round(size.height * scale));
    }

    [self horos_setImageClampedToToolbarSize:image]; // swapped: calls the original -setImage:
}

@end
