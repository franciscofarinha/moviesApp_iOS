//
//  ViewController.m
//  FLAGProj
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "ViewController.h"

#import "Configs.h"
#import "HttpRequestsUtility.h"
#import "MoviesResponse.h"
#import "CoreDataHelper.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *downloadImage;
@property (strong, nonatomic) CoreDataHelper *dbHelper;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dbHelper = [[CoreDataHelper alloc] init];
    
    
    NSLocale *deviceLocale = [NSLocale currentLocale];
    
    NSNumberFormatter *formater = [[NSNumberFormatter alloc] init];
    formater.locale = deviceLocale;
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.locale = deviceLocale;
    
    NSString *headerText = NSLocalizedString(@"MoviesList.Header.RefreshDate.Text", nil);
    
    
    
    //create a request for movies and call the webservice for a response
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"movie/now_playing" withQueryParams:@{@"api_key": API_KEY, @"language": @"pt-PT", @"page": @"1"}];

    __weak ViewController *weakSelf = self;
    [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
        //this completion handler code is executing in background
        if(error != nil) {
            NSLog(@"error - %@", [error localizedDescription]);
        }
        else {
            //parse the service response and transform into Model Objects
            NSDictionary *dict = (NSDictionary*)response;
            NSLog(@"response - %@", dict);

            MoviesResponse *responseParse = [[MoviesResponse alloc] initWithDictionary:dict];

            //save retrieved model objects in coredata database via dbhelper instanfe
            [weakSelf.dbHelper saveOrUpdateMovieList:responseParse.results];
        }
    }];


    //create an image URL to download
    NSURL *imgRequestURL = [HttpRequestsUtility buildRequestURL:@"http://upload.wikimedia.org/wikipedia/commons/7/7f/Williams_River-27527.jpg" andPath:nil withQueryParams:nil];

    //execute download image and set UI image view resource in completion handler, useful for example when you need to work the image before applying it to the UIImageView
    [HttpRequestsUtility executeDownloadImage:imgRequestURL withCompletion:^(UIImage *image, NSError *error) {
        //this completion handler code is executing in foreground main thread
        if(error == nil) {
            weakSelf.downloadImage.image = image;
        }
    }];
    
    //execute download image and set UI image view resource in imageview passed by parameter; receive errors in failure block if an error occurs -> this is useful for example in lists, download images asynchronously
    [HttpRequestsUtility executeDownloadImage:imgRequestURL intoImageView:self.downloadImage withErrorHandler:^(NSError *error) {
        NSLog(@"Oh oh, something went wrong - %@", [error localizedDescription]);
    }];
    
    
    //load Movie Objects from core data, with pagination, executing all data fetch in background and delivering the results in foreground main thread
    [self.dbHelper loadMoviesPage:1 withSize:10 withCompletionHandler:^(NSMutableArray *results, NSError *error) {
        if(results.count) {
            NSLog(@"resultsCount - %lu", results.count);
        }

        if(error) {
            NSLog(@"error - %@", [error localizedDescription]);
        }
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
