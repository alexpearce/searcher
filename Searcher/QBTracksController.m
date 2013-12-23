//
//  QBTracksController.m
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBTracksController.h"
#import "QBTrack.h"

#import "iTunes.h"

static NSString *kGroupPropertyKey = @"album";
static NSString *kPlaceholderImageURL = @"/System/Library/Frameworks/QuickLook.framework/Resources/Generic Artwork 128.png";

@interface QBTracksController () {
  NSImage *_placeholderImage;
}

- (NSDictionary *)createGroupFromTrack:(QBTrack *)track length:(NSUInteger)length;

@end

@implementation QBTracksController

- (id)init
{
  if (self = [super init]) {
    _iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    SBElementArray *sources = _iTunes.sources;
    for (iTunesSource *source in sources) {
      SBElementArray *playlists = source.playlists;
      for (iTunesPlaylist *playlist in playlists) {
        if (playlist.specialKind == iTunesESpKMusic) {
          _music = playlist;
        }
      }
    }
    NSAssert(_music, @"Could not find iTunes Music playlist.");
    _placeholderImage = [[NSImage alloc] initWithContentsOfFile:kPlaceholderImageURL];
    [self clear];
  }
  return self;
}

- (NSDictionary *)createGroupFromTrack:(QBTrack *)track length:(NSUInteger)length
{
  NSImage *image;
  if (track.imageData) {
    image = [[NSImage alloc] initWithData:track.imageData];
  }
  // If there's no artwork for the track, or initWithData: failed, use the placeholder
  if (!image) {
    image = _placeholderImage;
  }
  return @{
           @"album": track.album,
           @"artist": track.artist,
           @"image": image,
           @"count": [NSNumber numberWithUnsignedInteger:length]
           };
}

- (void)searchWithString:(NSString *)query
{
  // The SBElementArray contains iTunesTracks, which are references to the objects.
  SBElementArray *results = [_music searchFor:query only:iTunesESrAAll];
  NSUInteger resultsCount = [results count];
  
  NSString *trackGroupProperty;
  NSUInteger groupCount = 0;
  QBTrack *currentTrack;
  QBTrack *previousTrack;
  NSMutableArray *theTracks = [NSMutableArray arrayWithCapacity:resultsCount];
  NSMutableArray *theGroups = [NSMutableArray array];
  
  // Keep track of the current group property to build groups.
  // Set a (probably) unique property so we don't match the first search result.
  NSString *currentGroup = @"F4WeSPfCVw";
  for (iTunesTrack *track in results) {
    currentTrack = [[QBTrack alloc] initWithiTunesTrack:track];
    trackGroupProperty = [currentTrack valueForKey:kGroupPropertyKey];
    
    // If the group property has changed, we've just past a "group boundary", so add a group element
    // for the group we've just left.
    // Otherwise, we're still inside the group, so increment the count
    if (![currentGroup isEqualToString:trackGroupProperty]) {
      if (groupCount > 0) {
        [theGroups addObject:[self createGroupFromTrack:previousTrack length:groupCount]];
      }
      currentGroup = trackGroupProperty;
      groupCount = 1;
    } else {
      groupCount += 1;
    }

    [theTracks addObject:currentTrack];
    previousTrack = currentTrack;
  }
  // Add the group from the last track (if there is one)
  if (currentTrack) {
    [theGroups addObject:[self createGroupFromTrack:currentTrack length:groupCount]];
  }
  _groups = [NSArray arrayWithArray:theGroups];
  _tracks = [NSArray arrayWithArray:theTracks];
}

- (NSDictionary *)groupAtIndex:(NSUInteger)index
{
  return _groups[index];
}

- (QBTrack *)trackAtIndex:(NSUInteger)index
{
  return _tracks[index];
}

- (NSUInteger)trackCount
{
  return [_tracks count];
}

- (NSUInteger)trackCountForGroupIndex:(NSUInteger)index
{
  NSDictionary *group = [self groupAtIndex:index];
  return [group[@"count"] unsignedIntegerValue];
}

- (NSUInteger)groupCount
{
  return [_groups count];
}

- (void)clear
{
  _tracks = nil;
  _groups = nil;
  _tracks = [NSArray array];
  _groups = [NSArray array];
}


@end
