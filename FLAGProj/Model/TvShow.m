//
//  TvShow.m
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TvShow.h"

@implementation TvShow

-(instancetype)initWithDictionary:(NSDictionary*)obj {
    self = [super init];
    if(self) {
        self.tvShowId = [obj objectForKey:@"id"];
        self.poster_path = [obj objectForKey:@"poster_path"];
        self.overview = [obj objectForKey:@"overview"];
        self.release_date = [obj objectForKey:@"release_date"];
        self.original_title = [obj objectForKey:@"original_title"];
        self.original_language = [obj objectForKey:@"original_language"];
        self.name = [obj objectForKey:@"name"];
        self.backdrop_path = [obj objectForKey:@"backdrop_path"];
        self.popularity = [obj objectForKey:@"popularity"];
        self.vote_count = [obj objectForKey:@"vote_count"];
        self.vote_average = [obj objectForKey:@"vote_average"];
        
    }
    return self;
}

-(instancetype)initWithCDModel:(CDTvShow*)cdObj {
    self = [super init];
    if(self) {
        self.tvShowId = [NSNumber numberWithInteger:cdObj.tvshow_id];
        self.poster_path = cdObj.poster_path;
        self.overview = cdObj.overview;
        self.release_date = cdObj.release_date;
        self.original_title = cdObj.original_language;
        self.original_language = cdObj.original_language;
        self.name = cdObj.name;
        self.backdrop_path = cdObj.backdrop_path;
        self.popularity = [NSNumber numberWithInteger:cdObj.popularity];
        self.vote_count = [NSNumber numberWithInteger:cdObj.vote_count];
        self.vote_average = [NSNumber numberWithDouble:cdObj.vote_average];
      
    }
    return self;
}

@end
