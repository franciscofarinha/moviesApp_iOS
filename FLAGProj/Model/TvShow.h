//
//  TvShow.h
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDTvShow+CoreDataClass.h"

@interface TvShow : NSObject

@property (nonatomic, strong) NSNumber *tvShowId;
@property (nonatomic, strong) NSString *poster_path;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSString *release_date;
@property (nonatomic, strong) NSString *original_title;
@property (nonatomic, strong) NSString *original_language;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *backdrop_path;
@property (nonatomic, strong) NSNumber *popularity;
@property (nonatomic, strong) NSNumber *vote_count;
@property (nonatomic, strong) NSNumber *vote_average;
@property (nonatomic, strong) NSNumber *first_air_date;

-(instancetype)initWithDictionary:(NSDictionary*)obj;
-(instancetype)initWithCDModel:(CDTvShow*)cdObj;

@end
