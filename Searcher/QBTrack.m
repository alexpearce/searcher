//
//  QBTrack.m
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBTrack.h"
#import "iTunes.h"

@implementation QBTrack

- (id)initWithiTunesTrack:(iTunesTrack *)track
{
  if (self = [super init]) {
    _obj = track;
    _artist = track.artist;
    _album = track.album;
    _title = track.name;
    // Sometimes [iTunesArtwork data] sometimes returns an NSAppleEventDescriptor, so we explictly create an NSImage using the raw data
    // @see http://stackoverflow.com/questions/7035350
    SBElementArray *artworks = [track artworks];
    if ([artworks count] > 0) {
      _imageData = [artworks[0] rawData];
    } else {
      _imageData = nil;
    }
  }
  return self;
}

- (void)play
{
  [_obj playOnce:NO];
}

@end
