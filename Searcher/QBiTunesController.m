//
//  QBITunesController.m
//  Searcher
//
//  Created by Alex Pearce on 26/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "iTunes.h"

#import "QBiTunesController.h"
#import "QBTrack.h"
#import "QBTrackGroup.h"

static NSString *kGroupSortingKey = @"album";

@interface QBiTunesController ()

@property (strong) iTunesPlaylist *music;
// The nth entry holds the nth query result, as a QBTrack
@property (copy) NSArray *tracks;
// The nth entry holds the nth QBTrackGroup
@property (copy) NSArray *groups;
// The nth entry holds the group index for the nth track, as an NSNumber
@property (copy) NSArray *trackGroupIndices;

- (QBTrack *)trackForTrack:(iTunesTrack *)track;

@end

@implementation QBiTunesController

- (instancetype)init
{
  if (self = [super init]) {
    // Find the main music library
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    SBElementArray *sources = iTunes.sources;
    for (iTunesSource *source in sources) {
      SBElementArray *playlists = source.playlists;
      for (iTunesPlaylist *playlist in playlists) {
        if (playlist.specialKind == iTunesESpKMusic) {
          self.music = playlist;
        }
      }
    }
    NSAssert(_music, @"Could not find iTunes playlist.");
    
    self.tracks = [NSArray array];
    self.groups = [NSArray array];
    self.trackGroupIndices = [NSArray array];
  }
  return self;
}

- (QBTrack *)trackForTrack:(iTunesTrack *)track
{
  QBTrack *qbTrack = [[QBTrack alloc] initWithArtist:track.artist album:track.album title:track.name];
  iTunesArtwork *artwork = [[track artworks] firstObject];
  if (artwork) {
    qbTrack.imageData = [artwork rawData];
  } else {
    qbTrack.imageData = nil;
  }
  return qbTrack;
}

#pragma mark - QBMusicSource

- (void)searchWithString:(NSString *)query
{
  SBElementArray *results = [_music searchFor:query only:iTunesESrAAll];
  NSUInteger resultCount = [results count];
  
  NSUInteger groupIndex = 0;
  NSUInteger tracksInGroup = 0;
  QBTrackGroup *tempGroup;
  NSMutableArray *mutGroups = [NSMutableArray array];
  NSMutableArray *mutTrackGroupIndicies = [NSMutableArray arrayWithCapacity:resultCount];
  
  QBTrack *currentTrack;
  QBTrack *previousTrack;
  NSMutableArray *mutTracks = [NSMutableArray arrayWithCapacity:resultCount];
  
  for (iTunesTrack *track in results) {
    currentTrack = [self trackForTrack:track];
    [mutTracks addObject:currentTrack];
    [mutTrackGroupIndicies addObject:[NSNumber numberWithUnsignedInteger:groupIndex]];
    
    // If the current track's group property =! that of the previous track, we've entered a new group
    if (![[currentTrack valueForKey:kGroupSortingKey] isEqualToString:[previousTrack valueForKey:kGroupSortingKey]] && tracksInGroup > 0) {
      tempGroup = [[QBTrackGroup alloc] initFromTrack:previousTrack];
      tempGroup.trackCount = tracksInGroup;
      [mutGroups addObject:tempGroup];
      
      tracksInGroup = 1;
      groupIndex += 1;
    } else {
      tracksInGroup += 1;
    }
    
    previousTrack = currentTrack;
  }
  if (previousTrack) {
    tempGroup = [[QBTrackGroup alloc] initFromTrack:previousTrack];
    tempGroup.trackCount = tracksInGroup;
    [mutGroups addObject:tempGroup];
  }
  
  // Populate the properties
  self.tracks = [NSArray arrayWithArray:mutTracks];
  self.groups = [NSArray arrayWithArray:mutGroups];
  self.trackGroupIndices = [NSArray arrayWithArray:mutTrackGroupIndicies];
}

- (void)playTrackAtTrackIndex:(NSUInteger)index
{
  NSLog(@"Playing track '%@'", [self trackAtTrackIndex:index].title);
}

- (NSArray *)tracksArray
{
  return self.tracks;
}

- (QBTrack *)trackAtTrackIndex:(NSUInteger)index
{
  return _tracks[index];
}

- (NSUInteger)trackCount
{
  return [_tracks count];
}

- (NSArray *)groupsArray
{
  return self.groups;
}

- (QBTrackGroup *)groupAtTrackIndex:(NSUInteger)index
{
  return _groups[[_trackGroupIndices[index] unsignedIntegerValue]];
}

- (QBTrackGroup *)groupAtGroupIndex:(NSUInteger)index
{
  return _groups[index];
}

- (NSUInteger)groupCount
{
  return [_groups count];
}

@end
