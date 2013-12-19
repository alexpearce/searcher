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

@synthesize artist = _artist;
@synthesize album = _album;
@synthesize title = _title;
@synthesize obj = _obj;

- (id)initWithiTunesTrack:(iTunesTrack *)track
{
  if (self = [super init]) {
    _obj = track;
    _artist = track.artist;
    _album = track.album;
    _title = track.name;
  }
  return self;
}

- (void)play
{
  [_obj playOnce:NO];
}

@end
