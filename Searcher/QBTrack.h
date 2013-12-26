//
//  QBTrack.h
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class iTunesTrack;

/**
 * A wrapper for iTunesTrack objects.
 * iTunesTrack is an SBObject, which don't always behave like NSObject.
 * So, we explictly retrieve the properties we need and store them in properties.
 */
@interface QBTrack : NSObject

@property (copy) NSString *artist;
@property (copy) NSString *album;
@property (copy) NSString *title;
@property (copy) NSData *imageData;
@property (strong) iTunesTrack *obj;

- (instancetype)initWithArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title;

@end
