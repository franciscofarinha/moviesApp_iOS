//
//  CDTvShow+CoreDataProperties.m
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "CDTvShow+CoreDataProperties.h"

@implementation CDTvShow (CoreDataProperties)

+ (NSFetchRequest<CDTvShow *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"CDTvShow"];
}

@dynamic tvshow_id;
@dynamic name;
@dynamic poster_path;
@dynamic overview;
@dynamic release_date;
@dynamic original_title;
@dynamic original_language;
@dynamic backdrop_path;
@dynamic popularity;
@dynamic vote_count;
@dynamic vote_average;

@end
