//
//  CoreDataHelperTv.m
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "CoreDataHelperTv.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "TvShow.h"
#import "CDTvShow+CoreDataClass.h"


@interface CoreDataHelperTv ()

@property (nonatomic, strong) NSManagedObjectContext *moc;

@end


@implementation CoreDataHelperTv

-(instancetype)init {
    self = [super init];
    if(self) {
        self.moc = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) getManagedContext];
    }
    return self;
}


-(void)saveOrUpdateTvShowList:(NSArray*)tvShowList {
    for(TvShow *item in tvShowList) {
        [self saveOrUpdateTvShow:item];
    }
}

-(void)saveOrUpdateTvShow:(TvShow*)tvShow {
    
     [self.moc performBlock:^{
        NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDTvShow"];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"tvshow_id == %@", tvShow.tvShowId.stringValue];
        [userFetch setPredicate:filter];
        
        NSError *cdError = nil;
        
        NSArray *fetchResult = [self.moc executeFetchRequest:userFetch error:&cdError];
        
        CDTvShow *cdTvShow = nil;
        if(fetchResult.count) {
            cdTvShow = fetchResult.firstObject;
        }else {
            cdTvShow = [NSEntityDescription insertNewObjectForEntityForName:@"CDTvShow" inManagedObjectContext:self.moc];
        }
        
        [cdTvShow setTvshow_id:tvShow.tvShowId.integerValue];
        [cdTvShow setName:tvShow.name];
        if(![tvShow.poster_path isEqual:[NSNull null]]){
            
            [cdTvShow setPoster_path:tvShow.poster_path];
        }
        
        
        [cdTvShow setOverview:tvShow.overview];
        [cdTvShow setRelease_date:tvShow.release_date];
        [cdTvShow setOriginal_title:tvShow.original_title];
        [cdTvShow setOriginal_language:tvShow.original_language];
         
        
        
        if(![tvShow.backdrop_path isEqual:[NSNull null]]){
            
            [cdTvShow setBackdrop_path:tvShow.backdrop_path];
        }
        
        [cdTvShow setPopularity:tvShow.popularity.integerValue];
        [cdTvShow setVote_count:tvShow.vote_count.integerValue];
        [cdTvShow setVote_average:tvShow.vote_average.doubleValue];
        
         [self.moc save:&cdError];
     }];
}

-(void)loadTvShowsPage:(NSInteger)page withSize:(NSInteger)pageSize withCompletionHandler:(void (^) (NSMutableArray*, NSError*))completion {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *tvShowsArray = [NSMutableArray new];
        
        NSFetchRequest *tvShowsFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDTvShow"];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"tvshow_id" ascending:NO];
        [tvShowsFetch setSortDescriptors:@[sort]];
        
        NSInteger startOffset = page > 0 ? ((page-1)*pageSize) : 0;
        [tvShowsFetch setFetchOffset:startOffset];
        [tvShowsFetch setFetchLimit:pageSize];
        NSError *cdError = nil;
        
        NSArray *fetchResult = [self.moc executeFetchRequest:tvShowsFetch error:&cdError];
        if(fetchResult.count) {
            for(CDTvShow *item in fetchResult) {
                [tvShowsArray addObject:[[TvShow alloc] initWithCDModel:item]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(tvShowsArray, cdError);
        });
    });
}

@end
