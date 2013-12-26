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

- (instancetype)initWithArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title
{
  if (self = [super init]) {
    self.artist = artist;
    self.album = album;
    self.title = title;
  }
  return self;
}

@end
