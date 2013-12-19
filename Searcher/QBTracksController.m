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

@interface QBTracksController ()

- (NSDictionary *)createGroupFromTrack:(iTunesTrack *)track length:(NSUInteger)length;

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
    if (!_music) {
      NSLog(@"Could not find Music playlist");
    }
    _tracks = [[NSArray alloc] init];
    _groups = [[NSArray alloc] init];
    _groupPropertyKey = @"album";
  }
  return self;
}

- (NSDictionary *)createGroupFromTrack:(iTunesTrack *)track length:(NSUInteger)length
{
  SBElementArray *trackArtworks = [track artworks];
  iTunesArtwork *artwork;
  NSImage *placeholder = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/Frameworks/QuickLook.framework/Resources/Generic Artwork 128.png"];
  NSImage *image = nil;
  
  if ([trackArtworks count] > 0) {
    // TODO: is there a problem using the first element? Would it ever be != 0?
    artwork = [trackArtworks objectAtIndex:0];
    // Sometimes [iTunesArtwork data] sometimes returns an NSAppleEventDescriptor, so we explictly create an NSImage using the raw data
    // @see http://stackoverflow.com/questions/7035350
    image = [[NSImage alloc] initWithData:[artwork rawData]];
  }
  if (image == nil) {
    // If there's no artwork for the song, or initWithData: failed, use the placeholder
    image = placeholder;
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
  SBElementArray *resultReferences = [_music searchFor:query only:iTunesESrAAll];
  // By sending get, we force the evaluation of the object.
  // This is more efficient than looping over the SBElementArray with fast enumeration, which makes one apple event per loop, as only one event is sent.
  NSArray *results = [resultReferences arrayByApplyingSelector:@selector(get)];
  
  NSString *trackGroupProperty;
  NSUInteger groupCount = 0;
  NSMutableArray *theTracks = [NSMutableArray arrayWithCapacity:results.count];
  NSMutableArray *theGroups = [NSMutableArray array];
  
  // Keep track of the current group property to build groups.
  // Set an (probably) unique property so we don't match the first search result.
  NSString *currentGroup = @"F4WeSPfCVw";
  NSUInteger index = 0;
  for (iTunesTrack *track in results) {
    trackGroupProperty = [track valueForKey:_groupPropertyKey];
    
    // If the group property has changed, we've just past a "group boundary", so add a group element
    // for the group we've just left.
    // Otherwise, we're still inside the group, so increment the count
    if (![currentGroup isEqualToString:trackGroupProperty]) {
      // If the group count is zero
      if (groupCount > 0) {
        [self createGroupFromTrack:track length:groupCount];
        [theGroups addObject:[self createGroupFromTrack:results[index - 1] length:groupCount]];
      }
      currentGroup = trackGroupProperty;
      groupCount = 1;
    } else {
      groupCount += 1;
    }
    // Add the group from the last track
    [theTracks addObject:[[QBTrack alloc] initWithiTunesTrack:track]];
    index += 1;
    if (index == [results count]) {
      [theGroups addObject:[self createGroupFromTrack:track length:groupCount]];
    }
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

- (NSInteger)trackCount
{
  return [_tracks count];
}

- (NSInteger)propertyAtIndexTrackCount:(NSUInteger)index
{
  // It may be that the group property is disjoint in the search results, that is identical values may not occur sequentially.
  // Then, there are groups with duplicate property names.
  // To work around this, we count the number of tracks a group has
  return [_groups[index][@"count"] unsignedIntegerValue];
}

- (NSInteger)groupCount
{
  return [_groups count];
}

- (void)clear
{
  _tracks = [NSArray array];
  _groups = [NSArray array];
}


@end
