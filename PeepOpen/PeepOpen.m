//
//  PeepOpen.m
//  PeepOpen
//
//  Created by Michael Enriquez on 5/6/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "PeepOpen.h"

@class IDEWorkspaceWindowController;

@interface NSObject()
+ (id)workspaceWindowControllers;
+ (id)lastActiveWorkspaceWindow;
@end

@interface PeepOpen ()
- (NSURL *)projectRoot;
@end

@implementation PeepOpen

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
}

- (id)init
{
    if (self = [super init]) {
        NSMenuItem *fileMenuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        
        if (fileMenuItem) {
            NSMenuItem *open = [[NSMenuItem alloc] initWithTitle:@"Open with PeepOpen…" action:@selector(openWithPeepOpen) keyEquivalent:@"o"];
            NSInteger openPeepOpenMenuItemIndex = [fileMenuItem.submenu indexOfItemWithTitle:@"Open Quickly…"] + 1;
            [open setKeyEquivalentModifierMask:NSCommandKeyMask | NSControlKeyMask];
            [open setTarget:self];
            [[fileMenuItem submenu] insertItem:open atIndex:openPeepOpenMenuItemIndex];
            [open release];
        }
    }
    return self;
}

- (void)openWithPeepOpen
{
    NSURL *peepOpenUrl = [[NSURL alloc] initWithScheme:@"peepopen" host:@"" path:self.projectRoot.path];
    [[NSWorkspace sharedWorkspace] openURL:peepOpenUrl];
    [peepOpenUrl release];
}

- (NSURL *)projectRoot
{
    Class IDEWorkspaceWindowController = NSClassFromString(@"IDEWorkspaceWindow");
    NSURL *fileURL = (NSURL *)[[IDEWorkspaceWindowController lastActiveWorkspaceWindow] valueForKeyPath:@"windowController._workspace.representingFilePath._fileURL"];
    
    return [fileURL URLByDeletingLastPathComponent];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
