//
//  TvShowResponse.m
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TvShowResponse.h"
#import "TvShow.h"

@interface TvShowResponse ()

@end

@implementation TvShowResponse

-(instancetype)initWithDictionary:(NSDictionary*)obj {
    self = [super init];
    if(self) {
        self.page = [obj objectForKey:@"page"];
        self.total_pages = [obj objectForKey:@"total_pages"];
        NSArray *results = [obj objectForKey:@"results"];
        self.results = [NSMutableArray new];
        for(id item in results) {
            [self.results addObject:[[TvShow alloc] initWithDictionary:item]];
        }
    }
    return self;
}
@end
