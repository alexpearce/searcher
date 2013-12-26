//
//  QBMusicSource.h
//  Searcher
//
//  Created by Alex Pearce on 26/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBTrack;
@class QBTrackGroup;

/**
 * A QBMusicSource is a source of QBTracks, grouped in to QBGroups.
 * It allows filtering of its contents by searching and can start playing any of the results.
 */
@protocol QBMusicSource <NSObject>

/**
 * Populate the source with the results matching the query string.
 * It is up to the source to decide what a match is.
 */
- (void)searchWithString:(NSString *)query;

/**
 * Array of QBTracks matching the query.
 */
- (NSArray *)tracksArray;

/*
 * Play the nth query result.
 */
- (void)playTrackAtTrackIndex:(NSUInteger)index;

/*
 * Track instance corresponding to the nth query result.
 */
- (QBTrack *)trackAtTrackIndex:(NSUInteger)index;

/*
 * Number of QBTracks matched by the query.
 */
- (NSUInteger)trackCount;

/*
 * Array of groups matching the query.
 */
- (NSArray *)groupsArray;

/*
 * Group of the nth query result.
 */
- (QBTrackGroup *)groupAtTrackIndex:(NSUInteger)index;

/**
 * Return the nth group.
 */
- (QBTrackGroup *)groupAtGroupIndex:(NSUInteger)index;

/*
 * Return the number of groups matched by the query.
 */
- (NSUInteger)groupCount;

@end
