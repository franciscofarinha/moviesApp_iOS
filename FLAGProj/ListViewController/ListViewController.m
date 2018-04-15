//
//  ListViewController.m
//  FLAGProj
//
//  Created by formando on 08/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "ListViewController.h"

#import "Configs.h"
#import "HttpRequestsUtility.h"
#import "MoviesResponse.h"
#import "CoreDataHelper.h"
#import "TableViewCell.h"
#import "Movie.h"
#import "DetailViewController.h"
#import "Reachability.h"



@interface ListViewController ()<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *nowPlayingListView;
@property (strong, nonatomic) NSMutableArray *repoMovies;
@property (strong, nonatomic) NSMutableArray *foundMovies;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) CoreDataHelper *dbHelper;
@property (weak, nonatomic) NSNumber *pageNumber;
@property (weak, nonatomic) NSNumber *loadingPageNumber;
@property (weak, nonatomic) NSNumber *loadingCount;
@property (assign, nonatomic) BOOL isConnected;
@property (assign, nonatomic) BOOL requestIsLoading;
@property (assign, nonatomic) BOOL isSearching;
@property (weak, nonatomic) IBOutlet UISearchBar *searchMovies;
@property(nonatomic) BOOL showsCancelButton;
@property(nonatomic, readwrite, retain) UIView *backgroundView;
@property (assign, nonatomic) BOOL noResults;
//@property (assign, nonatomic) BOOL moreSavedItems;
@property (weak, nonatomic) IBOutlet UILabel *labelLoadedOn;


@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    [self setAppearance];
 
    
    
    self.dbHelper = [[CoreDataHelper alloc] init];
    self.repoMovies = [[NSMutableArray alloc] init];
    self.foundMovies =  [[NSMutableArray alloc] init];
    
    
    self.searchMovies.delegate = self;
    [self.searchMovies setShowsCancelButton:YES];
    
    self.nowPlayingListView.dataSource = self;
    self.nowPlayingListView.delegate = self;
    self.nowPlayingListView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    

    NSString *loadedOn = NSLocalizedString(@"MoviesList.Header.RefreshDate.Text", nil);
    
    [self.labelLoadedOn setText: loadedOn];
    

    
    
    int currentPage = 1;
    
    self.pageNumber = [NSNumber numberWithInt: currentPage];
    
    int currentLoadingPage = 1;
    
    self.loadingPageNumber = [NSNumber numberWithInt: currentLoadingPage];
    
 
    
    
    [self setUpNetworkStatus];
    NSLog(_isConnected ? @"Yes" : @"No");
   
   
    
    
    
   
    
    
    
    //REFRESH CONTROLL
    
    self.nowPlayingListView.refreshControl = [[UIRefreshControl alloc] init];

    self.nowPlayingListView.refreshControl.tintColor = [UIColor orangeColor];

    [self.nowPlayingListView.refreshControl  addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    
}




#pragma mark - Set Appearance
-(void)setAppearance{
    
    self.searchMovies.tintColor = [UIColor orangeColor];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor orangeColor]];
    [bar setBackgroundColor:[UIColor blackColor]];
    

    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor orangeColor]];
    
    
    
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor orangeColor]];
}


#pragma mark - Search Bar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    
    if(self.foundMovies.count > 0){
        
        [self.foundMovies removeAllObjects];
    }
    
   UILabel *noResultsLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _nowPlayingListView.bounds.size.width, _nowPlayingListView.bounds.size.height)];
     noResultsLabel.text             = @"";
    
    
   
    

   
    self.nowPlayingListView.tableFooterView = nil;
    
    self.isSearching = YES;
   

    
  
    
    for(int i = 0; i < _repoMovies.count; i++) {
        
        Movie *movieItem = (Movie*) self.repoMovies[ i ];
        

        NSString *lowerTitle = [movieItem.title lowercaseString];
        NSString *lowerSearch = [searchBar.text lowercaseString];
        
            if([lowerTitle containsString: lowerSearch]) {
            
                if(![self.foundMovies containsObject: movieItem]) {
                    
                    [self.foundMovies addObject: movieItem];
                }
           
                NSLog(@"found me");
                _noResults = NO;
            
        } else {
            
            
            NSLog(@"sem resultados");
        }
        
     
        
    }
    
    NSLog(@"%lu", self.foundMovies.count);
    
   

    
    
    [_nowPlayingListView reloadData];
   
    if (self.foundMovies.count > 0) {
        
        _noResults = NO;
    } else {
        
         _noResults = YES;
    }
    
    
    if (self.noResults){
        
        NSString *noResults = NSLocalizedString(@"NoResults.Search.Text", nil);
        noResultsLabel.text             = noResults;
        noResultsLabel.textColor        = [UIColor blackColor];
        noResultsLabel.textAlignment    = NSTextAlignmentCenter;
        
        
        UIImageView *noResultsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_error_48pt"]] ;
        
  
        
        UIView *noResultsUiView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, _nowPlayingListView.bounds.size.width , _nowPlayingListView.bounds.size.height)];
        
        CGPoint centerImageView = noResultsImageView.center;
        centerImageView.x = noResultsUiView.center.x;
        centerImageView.y = (noResultsLabel.center.y -50);
        noResultsImageView.center = centerImageView;
        

        
        [noResultsUiView addSubview:noResultsImageView];
        
        [noResultsUiView addSubview:noResultsLabel];
        
       
        
        _nowPlayingListView.backgroundView = noResultsUiView;
        _nowPlayingListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        

        
    }
    if(self.noResults == NO){
        
      
        _nowPlayingListView.backgroundView = nil;
    }
    
    

}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.foundMovies removeAllObjects];
    
    self.isSearching = NO;
    
    searchBar.text = @"";
    
   
    [self createFooter];

    [_nowPlayingListView reloadData];
    
}
    
    


#pragma mark - Handle Refresh Method

-(IBAction)handleRefresh : (id)sender
{
    if(self.isConnected) {
        
        self.nowPlayingListView.tableFooterView = nil;
        
        [self.foundMovies removeAllObjects];
        [self.repoMovies removeAllObjects];
        

        
        self.isSearching = NO;
        
        self.nowPlayingListView.backgroundView = nil;
        
        int currentPage = 1;
        
        self.pageNumber = [NSNumber numberWithInt: currentPage];
        

        [self setUpNetworkStatus];
        [self.nowPlayingListView.refreshControl endRefreshing];
        [self.nowPlayingListView reloadData];
    } else {
        
        
         [self.nowPlayingListView.refreshControl endRefreshing];
         [self setUpNetworkStatus];
    }
    
  
}

#pragma mark - Request
-(void)requestDataFromAPI:(NSNumber*)pageToLoad {
    

    NSString *languageCode = NSLocalizedString(@"Language.code", nil);
    
    
    //create a request for movies and call the webservice for a response
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"movie/now_playing" withQueryParams:@{@"api_key": API_KEY, @"language": languageCode, @"page": pageToLoad.stringValue}];
    
    
    
    
    __weak ListViewController *weakSelf = self;
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
            
            // weakSelf.repoMovies = responseParse.results;
            
            
            //acrescentar método para verificar repetições de items
            [weakSelf.repoMovies addObjectsFromArray: responseParse.results];
          
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.nowPlayingListView reloadData];
            });
            
              //SAVE TO DB
            
            [weakSelf.dbHelper saveOrUpdateMovieList:responseParse.results];
           
        }
         weakSelf.requestIsLoading = NO;
    }];
    
    //
    NSString *myString = requestURL.absoluteString;
    NSLog(@"%@", myString);
    //
    
    
   
}

#pragma mark - Update Time

-(void)updateLoadingTime {
    
    NSDate *loadingDate = [[NSDate alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    

    
    NSString *formattedDateString = [dateFormatter stringFromDate:loadingDate];
    
    NSLog(@"formattedDateString: %@", formattedDateString);
    
    

        [self.labelDate setText: formattedDateString ];
    

        [[NSUserDefaults standardUserDefaults] setObject:loadingDate forKey:@"savedLoadingTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
  
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//
//    // height of the footer
//    // this needs to be set, otherwise the height is zero and no footer will show
//    return 80;
//}

#pragma mark - Footer


-(void)createFooter {
    
    

    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.nowPlayingListView.bounds.size.width, 48)];
     footerView.backgroundColor = [UIColor blackColor];

    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.nowPlayingListView.bounds.size.width, footerView.bounds.size.height)];
    UIImage *footerImage = [UIImage imageNamed:@"ic_more_horiz_white_48pt"];

    [button setImage: footerImage forState:UIControlStateNormal];

    [button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [footerView addSubview:button];
    
    self.nowPlayingListView.tableFooterView = footerView;
}

#pragma mark - Footer Tapped
- (void)footerTapped {
    
    if (_requestIsLoading){
        
        return;
    }
    _requestIsLoading = YES;
    

    
    
    
    if(_isConnected){
        
        int currentPage = [self.pageNumber intValue];
        
        currentPage = currentPage + 1;
        
        self.pageNumber = [NSNumber numberWithInt: currentPage];
        
        
        NSLog(@"%d", [self.pageNumber intValue]);
        
        [self requestDataFromAPI: self.pageNumber ];
        
        
    } else {
        
        if( _loadingCount < [NSNumber numberWithInt:10]) {
            
            NSLog(@"na mais");
            
        } else {
            
            int currentLoadingPage = [self.loadingPageNumber intValue];
            
            currentLoadingPage = currentLoadingPage + 1;
            
            self.loadingPageNumber = [NSNumber numberWithInt: currentLoadingPage];
            
            [self loadFromDB: self.loadingPageNumber];
            
    }
        
       
        
    }
    
    
    
}

#pragma mark - list methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    
    TableViewCell *cell = (TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"custom-cell-view"];
    
    Movie *movieItem = [Movie alloc];
    
    if(_isSearching) {
        
         movieItem = self.foundMovies[indexPath.row];
    } else {
        
        movieItem =  self.repoMovies[indexPath.row];
    }
    

    

    
    NSURL *endPointImageUrl = [HttpRequestsUtility buildRequestURL:BASE_IMAGE_URL andPath:movieItem.backdrop_path withQueryParams:nil];
    
    
    if(endPointImageUrl != nil){
        
        [HttpRequestsUtility executeDownloadImage:endPointImageUrl intoImageView:cell.cellImageView withErrorHandler:^(NSError *error) {
            NSLog(@"Oh oh, something went wrong - %@", [error localizedDescription]);
        }];
        
    }

  
    

    
    [cell setCellContent: movieItem.title];
    
    
     return cell;
}





- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(_isSearching) {
        
        return self.foundMovies.count;
    } else {
        
        return _repoMovies.count;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
  
    Movie *movieItem = [Movie alloc];
    
    if(_isSearching) {
        
       movieItem = (Movie*) self.foundMovies[indexPath.row];
    } else {
        
       movieItem = (Movie*) self.repoMovies[indexPath.row];
    }
    
    //Instanciação manual do ecrã seguinte no fluxo recorrendo ao carregamento do storyboard a partir do nome deste e o ViewController a partir do identificador atribuido no Interface Builder
    UIStoryboard *sbMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *vc = (DetailViewController*)[sbMain instantiateViewControllerWithIdentifier:@"detail-movie-view-controller"];
    
  
    vc.data = movieItem;
    
    
    //navegação de forma programática para o ecrã seguinte no fluxo
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Network Status

-(void)setUpNetworkStatus {
    
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
            
            self.isConnected = YES;
            
            [self requestDataFromAPI: self.pageNumber ];
            [self updateLoadingTime];
            [self createFooter];
     
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
        
        self.isConnected = NO;
        [self loadFromDB: _loadingPageNumber];
        
        
        
        
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
    
    
    
}

#pragma mark - Load from DB

-(void)loadFromDB:(NSNumber*)pageToLoad{
    
    __weak ListViewController *weakSelf = self;
    [self.dbHelper loadMoviesPage:pageToLoad.longValue withSize:10 withCompletionHandler:^(NSMutableArray *results, NSError *error) {
        
         _loadingCount = [NSNumber numberWithInteger:results.count];
        
        if(results.count) {
            NSLog(@"resultsCount - %lu", results.count);
            

            
               [weakSelf.repoMovies addObjectsFromArray: results];
               [weakSelf.nowPlayingListView reloadData];
            
            
            
            NSDate *savedValue = [[NSUserDefaults standardUserDefaults]
                                    objectForKey:@"savedLoadingTime"];
            
        
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
       
            
            NSString *formattedDateString = [dateFormatter stringFromDate:savedValue];
            
            
            [self.labelDate setText: formattedDateString ];
             [self createFooterToLoadFromDB];
           
            
            //mais paginas?
            
        }
        
        if(error) {
            NSLog(@"error - %@", [error localizedDescription]);
        
        }
    }];
}

-(void)createFooterToLoadFromDB{
    
    
   
    
    // creates a custom view inside the footer
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.nowPlayingListView.bounds.size.width, 48)];
    footerView.backgroundColor = [UIColor blackColor];
    // create a button with image and add it to the view
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.nowPlayingListView.bounds.size.width, footerView.bounds.size.height)];
    

        UIImage *footerImage = [UIImage imageNamed:@"ic_more_horiz_white_48pt"];
        
        [button setImage: footerImage forState:UIControlStateNormal];
    
        [button addTarget:self action:@selector(dbFooterTapped) forControlEvents:UIControlEventTouchUpInside];
        

    
    [footerView addSubview:button];
    
        
        self.nowPlayingListView.tableFooterView = footerView;
    
    
}

#pragma mark - DB Footer Tapped
- (void)dbFooterTapped {
    
    
    
    NSLog(@"You've tapped the db footer!");
    
    if( _loadingCount < [NSNumber numberWithInt:10]) {
        
        NSLog(@"na mais, só ha %d", _loadingCount.intValue);
        

        
        _nowPlayingListView.tableFooterView = nil;
        
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.nowPlayingListView.bounds.size.width, 48)];
        footerView.backgroundColor = [UIColor blackColor];
        // create a button with image and add it to the view
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.nowPlayingListView.bounds.size.width, footerView.bounds.size.height)];
        
        [button setTitle: NSLocalizedString(@"footerEndMovies", nil) forState:UIControlStateNormal];
        
        [footerView addSubview:button];
        
        
        self.nowPlayingListView.tableFooterView = footerView;
        
        
        
    } else {
    

        
            int currentLoadingPage = [self.loadingPageNumber intValue];
            
            currentLoadingPage = currentLoadingPage + 1;
            
            self.loadingPageNumber = [NSNumber numberWithInt: currentLoadingPage];
            
            [self loadFromDB: self.loadingPageNumber];
 
    
    }
}

@end
