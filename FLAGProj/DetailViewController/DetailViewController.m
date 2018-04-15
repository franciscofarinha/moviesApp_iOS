//
//  DetailViewController.m
//  FLAGProj
//
//  Created by formando on 08/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "DetailViewController.h"
#import "HttpRequestsUtility.h"
#import "Configs.h"
#import <MessageUI/MessageUI.h>

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UITextView *overviewTextView;


//- (IBAction)shareButton:(id)sender;

@end

@implementation DetailViewController

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
    

    NSString *messagePt = [NSString stringWithFormat:@"O filme %@ tem a classificação de %@ estrelas", self.data.title, self.data.vote_average.stringValue];
    
    NSString *messageEn = [NSString stringWithFormat:@"The Movie %@ has a rating of %@ stars", self.data.title, self.data.vote_average.stringValue];
    
    NSString *languageCode = NSLocalizedString(@"Language.code", nil);
    
    if([languageCode isEqualToString:@"pt-PT"]) {
        
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
    
    
    [self.titleLabel setText: self.data.title];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date  = [dateFormatter dateFromString:self.data.release_date];
    
    NSString *language = NSLocalizedString(@"Language", nil);
    
    if([language isEqualToString:@"pt"]) {
        
        
        // Convert to new Date Format
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSString *newDate = [dateFormatter stringFromDate:date];
        [self.releaseDateLabel setText: newDate];
        
    } else {
        
        [self.releaseDateLabel setText: self.data.release_date];
        
    }
    

    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    [self.ratingLabel setText: [fmt stringFromNumber:[NSNumber numberWithFloat:self.data.vote_average.floatValue]]];
    
    
    NSString *overviewStr = self.data.overview;
    NSString *noOverview = NSLocalizedString(@"No.Overview", nil);
    
    if ([overviewStr length] == 0) {
        
        [self.overviewTextView setText: noOverview];
        [self.overviewTextView setTextAlignment:NSTextAlignmentCenter];
        
    } else {
        
        
        [self.overviewTextView setText: self.data.overview];
    }
}


@end
