//
//  TvDetailViewController.m
//  FLAGProj
//
//  Created by Francisco Farinha on 12/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TvDetailViewController.h"
#import "HttpRequestsUtility.h"
#import "Configs.h"
#import <MessageUI/MessageUI.h>

@interface TvDetailViewController ()


@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextView *overviewTextView;
@property (weak, nonatomic) IBOutlet UILabel *labelRating;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *originalLanguagelabel;




@end

@implementation TvDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    [self applyBackground];
    [self setContent];
    [self downloadAndApplyImage];
    [self setShareButton];
    
   

    
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)shareButton:(id)sender{
    

    NSString *messagePt = [NSString stringWithFormat:@"A série %@ tem a classificação de %@ estrelas.", self.data.name, self.data.vote_average.stringValue];
    
     NSString *messageEn = [NSString stringWithFormat:@"%@ has a rating of %@ stars.", self.data.name, self.data.vote_average.stringValue];

    NSString *languageCode = NSLocalizedString(@"Language.code", nil);
    
    if([languageCode isEqualToString:@"pt-PT"] ) {
        
        UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[messagePt]
                                          applicationActivities:nil];
        
        [self.navigationController  presentViewController:activityViewController
                                                 animated:YES
                                               completion:^{
                                                   // ...
                                               }];
        
    } else {
        
        UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[messageEn]
                                          applicationActivities:nil];
        
        [self.navigationController  presentViewController:activityViewController
                                                 animated:YES
                                               completion:^{
                                                   // ...
                                               }];
        
    }
    
    
   
    

    
}

-(void)applyBackground {
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor grayColor].CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
}

-(void)downloadAndApplyImage {
    
    NSURL *endPointImageUrl = [HttpRequestsUtility buildRequestURL:BASE_IMAGE_URL_POSTER andPath:self.data.poster_path withQueryParams:nil];
    
    [HttpRequestsUtility executeDownloadImage:endPointImageUrl intoImageView: self.posterImageView withErrorHandler:^(NSError *error) {
        
        NSLog(@"Oh oh, something went wrong - %@", [error localizedDescription]);
    }];
    
}

-(void)setShareButton {
    
    UIImage *shareImage = [[UIImage imageNamed:@"ic_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:shareImage style:UIBarButtonItemStylePlain target:self action:@selector(shareButton:)];
    
    
    [self.navigationItem setRightBarButtonItem: button];
}

-(void)setContent {
    
    
    [self.labelTitle setText: self.data.name];
    

    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    [self.labelRating setText: [fmt stringFromNumber:[NSNumber numberWithFloat:self.data.vote_average.floatValue]]];
    
    
    
    NSString *overviewStr = self.data.overview;
    NSString *noOverview = NSLocalizedString(@"No.Overview", nil);
    
    if ([overviewStr length] == 0) {
        
        [self.overviewTextView setText: noOverview];
        [self.overviewTextView setTextAlignment:NSTextAlignmentCenter];
        
    } else {
        
        
        [self.overviewTextView setText: self.data.overview];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
