//
//  CDTvShow+CoreDataProperties.h
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "CDTvShow+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDTvShow (CoreDataProperties)

+ (NSFetchRequest<CDTvShow *> *)fetchRequest;

@property (nonatomic) int64_t tvshow_id;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *poster_path;
@property (nullable, nonatomic, copy) NSString *overview;
@property (nullable, nonatomic, copy) NSString *release_date;
@property (nullable, nonatomic, copy) NSString *original_title;
@property (nullable, nonatomic, copy) NSString *original_language;
@property (nullable, nonatomic, copy) NSString *backdrop_path;
@property (nonatomic) int64_t popularity;
@property (nonatomic) int64_t vote_count;
@property (nonatomic) double vote_average;

@end

NS_ASSUME_NONNULL_END


