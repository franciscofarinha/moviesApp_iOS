//
//  TvViewController.m
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TvViewController.h"

#import "Configs.h"
#import "HttpRequestsUtility.h"
#import "TvShowResponse.h"
#import "CoreDataHelperTv.h"
#import "TableViewCell.h"
#import "TvShow.h"
#import "TvDetailViewController.h"
#import "Reachability.h"
#import "AppDelegate.h"


@interface TvViewController ()<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *popularTvListView;

@property (strong, nonatomic) NSMutableArray *repoTvShows;
@property (strong, nonatomic) NSMutableArray *foundTvShows;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *loadedOnLabel;

@property (strong, nonatomic) CoreDataHelperTv *dbHelper;
@property (weak, nonatomic) NSNumber *pageNumber;
@property (weak, nonatomic) NSNumber *loadingPageNumber;
@property (weak, nonatomic) NSNumber *loadingCount;
@property (assign, nonatomic) BOOL isConnected;
@property (assign, nonatomic) BOOL requestIsLoading;
@property (assign, nonatomic) BOOL isSearching;
@property (weak, nonatomic) IBOutlet UISearchBar *searchTvShows;
@property (assign, nonatomic) BOOL noResults;
@property (strong, nonatomic) NSMutableArray *results;

@property(nonatomic) BOOL showsCancelButton;

@end

@implementation TvViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAppearance];
    
    
    self.dbHelper = [[CoreDataHelperTv alloc] init];
    self.repoTvShows = [[NSMutableArray alloc] init];
    self.foundTvShows =  [[NSMutableArray alloc] init];
    
    
    self.searchTvShows.delegate = self;
    [self.searchTvShows setShowsCancelButton:YES];
    
    self.popularTvListView.dataSource = self;
    self.popularTvListView.delegate = self;
    self.popularTvListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    

    NSString *loadedOn = NSLocalizedString(@"MoviesList.Header.RefreshDate.Text", nil);
    
    [self.loadedOnLabel setText: loadedOn];
    
    
    
    int currentPage = 1;
    
    self.pageNumber = [NSNumber numberWithInt: currentPage];
    
    int currentLoadingPage = 1;
    
    self.loadingPageNumber = [NSNumber numberWithInt: currentLoadingPage];
    
    
    
    
    [self setUpNetworkStatus];
    NSLog(_isConnected ? @"Yes" : @"No");
    
    
    
    
    
    
    
    
    
    //REFRESH CONTROLL
    
    self.popularTvListView.refreshControl = [[UIRefreshControl alloc] init];
    

    self.popularTvListView.refreshControl.tintColor = [UIColor orangeColor];
    
    [self.popularTvListView.refreshControl  addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
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

#pragma mark - Set Appearance
-(void)setAppearance{
    
    self.searchTvShows.tintColor = [UIColor orangeColor];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor orangeColor]];
    [bar setBackgroundColor:[UIColor blackColor]];
    
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor orangeColor]];
    
    
    
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor orangeColor]];
}

#pragma mark - Search Bar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if(self.foundTvShows.count > 0){
        
        [self.foundTvShows removeAllObjects];
    }
    
    UILabel *noResultsLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.popularTvListView.bounds.size.width, self.popularTvListView.bounds.size.height)];
    noResultsLabel.text             = @"";
    
    
    
    
    
    
    self.popularTvListView.tableFooterView = nil;
    
    self.isSearching = YES;
    
    
    
    for(int i = 0; i < self.repoTvShows.count; i++) {
        
        TvShow *tvItem = (TvShow*) self.repoTvShows[ i ];
        
   
        NSString *lowerTitle = [tvItem.name lowercaseString];
        NSString *lowerSearch = [searchBar.text lowercaseString];
        
        if([lowerTitle containsString: lowerSearch]) {
            
            if(![self.foundTvShows containsObject: tvItem]) {
                
                [self.foundTvShows addObject: tvItem];
            }
            
            NSLog(@"found me");
            _noResults = NO;
            
        } else {
            
            
            NSLog(@"sem resultados");
        }
        
        
        
    }
    
    NSLog(@"%lu", self.foundTvShows.count);
    
    
    
    
    [self.popularTvListView reloadData];
    
    if (self.foundTvShows.count > 0) {
        
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
        
        
        
        UIView *noResultsUiView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, self.popularTvListView.bounds.size.width , self.popularTvListView.bounds.size.height)];
        
        CGPoint centerImageView = noResultsImageView.center;
        centerImageView.x = noResultsUiView.center.x;
        centerImageView.y = (noResultsLabel.center.y -50);
        noResultsImageView.center = centerImageView;
        
   
        
        [noResultsUiView addSubview:noResultsImageView];
        
        [noResultsUiView addSubview:noResultsLabel];
        
        
        
        self.popularTvListView.backgroundView = noResultsUiView;
        self.popularTvListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        

        
    }
    if(self.noResults == NO){
        
        
        self.popularTvListView.backgroundView = nil;
    }
    
    

    
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.foundTvShows removeAllObjects];
    
    self.isSearching = NO;
    
    searchBar.text = @"";
    
    
    [self createFooter];
    
    [_popularTvListView reloadData];
    
}




#pragma mark - Handle Refresh Method

-(IBAction)handleRefresh : (id)sender
{
    
    if(self.isConnected) {
        
        self.popularTvListView.tableFooterView = nil;
        
        
        [self.foundTvShows removeAllObjects];
        [self.repoTvShows removeAllObjects];
        
        
        self.isSearching = NO;
        
        self.popularTvListView.backgroundView = nil;
        
        int currentPage = 1;
        
        self.pageNumber = [NSNumber numberWithInt: currentPage];
        

        [self setUpNetworkStatus];
        [self.popularTvListView.refreshControl endRefreshing];
        [self.popularTvListView reloadData];
        
    }  else {
        
        [self.popularTvListView.refreshControl endRefreshing];
        [self setUpNetworkStatus];
    }
    
    
    
    
}

#pragma mark - Request
-(void)requestDataFromAPI:(NSNumber*)pageToLoad {
    
    
    NSString *languageCode = NSLocalizedString(@"Language.code", nil);
    
    //create a request for movies and call the webservice for a response
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"tv/popular" withQueryParams:@{@"api_key": API_KEY, @"language": languageCode, @"page": pageToLoad.stringValue}];
    
    
    
    
    __weak TvViewController *weakSelf = self;
    [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
        //this completion handler code is executing in background
        
        if(error != nil) {
            NSLog(@"error - %@", [error localizedDescription]);
        }
        else {
            //parse the service response and transform into Model Objects
            NSDictionary *dict = (NSDictionary*)response;
            NSLog(@"response - %@", dict);
            
            TvShowResponse *responseParse = [[TvShowResponse alloc] initWithDictionary:dict];
            
            //save retrieved model objects in coredata database via dbhelper instanfe
            
            // weakSelf.repoMovies = responseParse.results;
            
            
            //acrescentar método para verificar repetições de items
            [weakSelf.repoTvShows addObjectsFromArray: responseParse.results];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.popularTvListView reloadData];
            });
            
            //SAVE TO DB
            
            [weakSelf.dbHelper saveOrUpdateTvShowList:responseParse.results];
            
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
    
    
    //NSLog(@"%@", loadingDate);
    
    
    
    [self.labelDate setText: formattedDateString ];
    
    [[NSUserDefaults standardUserDefaults] setObject:formattedDateString forKey:@"savedTvLoadingTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    
    
    
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
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.popularTvListView.bounds.size.width, 48)];
    footerView.backgroundColor = [UIColor blackColor];

    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.popularTvListView.bounds.size.width, footerView.bounds.size.height)];
    UIImage *footerImage = [UIImage imageNamed:@"ic_more_horiz_white_48pt"];
    
    [button setImage: footerImage forState:UIControlStateNormal];

    [button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [footerView addSubview:button];
    
    self.popularTvListView.tableFooterView = footerView;
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
            
            int currentLoadingPage = [self.pageNumber intValue];
            
            currentLoadingPage = currentLoadingPage + 1;
            
            self.loadingPageNumber = [NSNumber numberWithInt: currentLoadingPage];
            
            [self loadFromDB: self.loadingPageNumber ];
            
        }
        
        
        
    }
    
    
    
}

#pragma mark - list methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    
    TableViewCell *cell = (TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"custom-cell-view"];
    
    TvShow *tvItem = [TvShow alloc];
    
    if(_isSearching) {
        
        
        tvItem = self.foundTvShows[indexPath.row];
        
    } else {
        
        tvItem =  self.repoTvShows[indexPath.row];
    }
    
    
    
    
    
    NSURL *endPointImageUrl = [HttpRequestsUtility buildRequestURL:BASE_IMAGE_URL andPath:tvItem.backdrop_path withQueryParams:nil];
    
    
    if(endPointImageUrl != nil){
        
        [HttpRequestsUtility executeDownloadImage:endPointImageUrl intoImageView:cell.cellImageView withErrorHandler:^(NSError *error) {
            NSLog(@"Oh oh, something went wrong - %@", [error localizedDescription]);
        }];
        
    }
    
    
    
    
    
    [cell setCellContent: tvItem.name];
    
    
    return cell;
}





- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(_isSearching) {
        
        return self.foundTvShows.count;
    } else {
        
        return _repoTvShows.count;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    TvShow *tvItem = [TvShow alloc];
    
    if(_isSearching) {
        
        tvItem = (TvShow*) self.foundTvShows[indexPath.row];
    } else {
        
        tvItem = (TvShow*) self.repoTvShows[indexPath.row];
    }
    
    //Instanciação manual do ecrã seguinte no fluxo recorrendo ao carregamento do storyboard a partir do nome deste e o ViewController a partir do identificador atribuido no Interface Builder
    UIStoryboard *sbMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TvDetailViewController *vc = (TvDetailViewController*)[sbMain instantiateViewControllerWithIdentifier:@"detail-tv-view-controller"];
    
    //afectação das propriedades do ecrã antes de promover a sua apresentação
    vc.data = tvItem;
    
    
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
    
    __weak TvViewController *weakSelf = self;
    [self.dbHelper loadTvShowsPage:pageToLoad.longValue withSize:10 withCompletionHandler:^(NSMutableArray *results, NSError *error) {
        
         _loadingCount = [NSNumber numberWithInteger:results.count];
        
        if(results.count) {
            NSLog(@"resultsCount - %lu", results.count);
            
            
            
            [weakSelf.repoTvShows addObjectsFromArray: results];
            [weakSelf.popularTvListView reloadData];
            
            NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                    stringForKey:@"savedTvLoadingTime"];
            
            [self.labelDate setText: savedValue ];
            [self createFooterToLoadFromDB];
            
     
            
        }
        
        if(error) {
            NSLog(@"error - %@", [error localizedDescription]);
            
        }
    }];
}



-(void)createFooterToLoadFromDB{
    
    
    //NSString *loadMore = NSLocalizedString(@"LoadMore.Footer.Text", nil);
    
    // creates a custom view inside the footer
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.popularTvListView.bounds.size.width, 48)];
    footerView.backgroundColor = [UIColor blackColor];
    // create a button with image and add it to the view
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.popularTvListView.bounds.size.width, footerView.bounds.size.height)];
    
    
    UIImage *footerImage = [UIImage imageNamed:@"ic_more_horiz_white_48pt"];
    
    [button setImage: footerImage forState:UIControlStateNormal];

    [button addTarget:self action:@selector(dbFooterTapped) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [footerView addSubview:button];
    
    
    self.popularTvListView.tableFooterView = footerView;
    
    
}

#pragma mark - Footer Tapped
- (void)dbFooterTapped {
    
    
    
    NSLog(@"You've tapped the db footer!");
    
    if( _loadingCount < [NSNumber numberWithInt:10]) {
        
        NSLog(@"na mais, só ha %d", _loadingCount.intValue);
        

        
        self.popularTvListView.tableFooterView = nil;
        
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.popularTvListView.bounds.size.width, 48)];
        footerView.backgroundColor = [UIColor blackColor];
        // create a button with image and add it to the view
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.popularTvListView.bounds.size.width, footerView.bounds.size.height)];
        
        

        
        [button setTitle: NSLocalizedString(@"footerEndTvShows", nil) forState:UIControlStateNormal];
        
        [footerView addSubview:button];
        
        
        self.popularTvListView.tableFooterView = footerView;
        
        
        
    } else {
 
        
        int currentLoadingPage = [self.loadingPageNumber intValue];
        
        currentLoadingPage = currentLoadingPage + 1;
        
        self.loadingPageNumber = [NSNumber numberWithInt: currentLoadingPage];
        
        [self loadFromDB: self.loadingPageNumber];
        
        
    }
}

@end
