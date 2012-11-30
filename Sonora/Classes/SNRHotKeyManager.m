/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SNRHotKeyManager.h"
#import "SNRSearchWindowController.h"
#import "SNRSearchViewController.h"
#import "SNRQueueController.h"
#import "SNRQueueCoordinator.h"

#import "NSWindow+SNRAdditions.h"

@implementation SNRHotKeyManager

+ (SNRHotKeyManager*)sharedManager
{
    static SNRHotKeyManager *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       manager = [[self alloc] init];
    });
    return manager;
}

- (void)registerHotKeys
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // search
    if (![[ud objectForKey:kUserDefaultsSearchShortcutKey] isKindOfClass:[NSData class]]) {
        // Set up the default search shortcut
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_Period modifierFlags:NSCommandKeyMask];
        [ud setObject:[shortcut data] forKey:kUserDefaultsSearchShortcutKey];
    }
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:kUserDefaultsSearchShortcutKey handler:^{
        SNRSearchWindowController *search = [SNRSearchWindowController sharedWindowController];
        if ([search.window isVisible]) {
            search.openedViaShortcut = NO;
            [NSApp hide:nil];
            [search hideWindow:nil];
        } else {
            if (![NSApp isActive]) {
                for (NSWindow *window in [NSApp windows]) {
                    if (![window isFullscreen]) {
                        [window orderOut:nil];
                    }
                }
                [NSApp activateIgnoringOtherApps:YES];
                search.openedViaShortcut = YES;
            }
            [search.window makeFirstResponder:search.searchViewController.searchField];
            [search showWindow:nil];
        }
    }];
    
    // previous song
    if (![[ud objectForKey:kUserDefaultsPreviousSongShortcutKey] isKindOfClass:[NSData class]]) {
        // Set up the default previous song shortcut
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_LeftArrow
                                                   modifierFlags:NSCommandKeyMask | NSControlKeyMask];
        [ud setObject:[shortcut data] forKey:kUserDefaultsPreviousSongShortcutKey];
    }
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:kUserDefaultsPreviousSongShortcutKey handler:^{
        [SNR_MainQueueController previous];
    }];

    // next song
    if (![[ud objectForKey:kUserDefaultsNextSongShortcutKey] isKindOfClass:[NSData class]]) {
        // Set up the default next song shortcut
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_RightArrow
                                                   modifierFlags:NSCommandKeyMask | NSControlKeyMask];
        [ud setObject:[shortcut data] forKey:kUserDefaultsNextSongShortcutKey];
    }
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:kUserDefaultsNextSongShortcutKey handler:^{
        [SNR_MainQueueController next];
    }];
    
    // play / pause
    if (![[ud objectForKey:kUserDefaultsPlayPauseShortcutKey] isKindOfClass:[NSData class]]) {
        // Set up the default pause shortcut
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_Space
                                                   modifierFlags:NSCommandKeyMask | NSControlKeyMask];
        [ud setObject:[shortcut data] forKey:kUserDefaultsPlayPauseShortcutKey];
    }
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:kUserDefaultsPlayPauseShortcutKey handler:^{
        [SNR_MainQueueController playPause];
    }];
}
@end
