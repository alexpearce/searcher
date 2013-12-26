//
//  QBTrackGroup.h
//  Searcher
//
//  Created by Alex Pearce on 26/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBTrack;

@interface QBTrackGroup : NSObject

@property (copy) NSString *artist;
@property (copy) NSString *album;
@property (strong) NSImage *artwork;
// Number of tracks in the group.
@property NSUInteger trackCount;

- (instancetype)initFromTrack:(QBTrack *)track;

@end
