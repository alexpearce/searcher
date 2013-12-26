//
//  QBTrackGroup.m
//  Searcher
//
//  Created by Alex Pearce on 26/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBTrackGroup.h"
#import "QBTrack.h"

static NSString *kPlaceholderArtworkFileURL = @"/System/Library/Frameworks/QuickLook.framework/Resources/Generic Artwork 128@2x.png";

@implementation QBTrackGroup

- (instancetype)initFromTrack:(QBTrack *)track
{
  if (self = [super init]) {
    self.album = track.album;
    self.artist = track.artist;
    self.artwork = [[NSImage alloc] initWithData:track.imageData];
    // Use the placeholder artwork if initialisation from the track data failed
    if (!self.artwork) {
      self.artwork = [[NSImage alloc] initWithContentsOfFile:kPlaceholderArtworkFileURL];
    }
  }
  return self;
}

@end
