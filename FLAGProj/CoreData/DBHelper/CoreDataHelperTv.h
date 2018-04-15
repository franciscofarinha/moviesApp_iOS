//
//  CoreDataHelperTv.h
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TvShow.h"

@interface CoreDataHelperTv : NSObject

-(void)saveOrUpdateTvShowList:(NSArray*)tvShowList;
-(void)saveOrUpdateTvShow:(TvShow*)tvShow;
-(void)loadTvShowsPage:(NSInteger)page withSize:(NSInteger)pageSize withCompletionHandler:(void (^) (NSMutableArray*, NSError*))completion;

@end
