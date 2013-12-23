//
//  QBTracksController.h
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBTrack;
@class iTunesApplication;
@class iTunesPlaylist;

/**
 * Controller for QBTrack models.
 * We store two arrays, one containing the tracks, one containing a property which groups tracks.
 * This could be, for example, the artist of the track.
 * iTunes returns search results sorted by artist, and within that by album.
 */
@interface QBTracksController : NSObject

@property (strong, readonly) iTunesApplication *iTunes;
@property (strong, readonly) iTunesPlaylist *music;
@property (copy, readonly) NSArray *tracks;
@property (copy, readonly) NSArray *groups;

/**
 * Populate the controller with results.
 * The results are identical to if one searches in the main iTunes library.
 */
- (void)searchWithString:(NSString *)query;

/**
 * Return the indexed QBTrack.
 */
- (QBTrack *)trackAtIndex:(NSUInteger)index;

/**
 * Return the indexed grouping dictionary.
 * The dictionary contains three keys:
 *   image: NSImage of album art
 *   album: Group property
 *   artist: Album artist
 */
- (NSDictionary *)groupAtIndex:(NSUInteger)index;

/**
 * Return the number of tracks.
 */
- (NSUInteger)trackCount;

/**
 * Return the number of tracks which belong to the indexed group.
 * @param index Index of the group
 */
- (NSUInteger)trackCountForGroupIndex:(NSUInteger)index;

/**
 * Return the number of groups.
 */
- (NSUInteger)groupCount;

/**
 * Clear the tracks and groups in the controller.
 * Sets the track and group arrays to empty arrays.
 */
- (void)clear;

@end
