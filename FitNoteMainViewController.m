//
//  FitNoteMainViewController.m
//  FitScribe
//
//  Created by Bobby Gintz on 2/4/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "FitNoteMainViewController.h"
#import "Speak.h"
#import "deviceSelector.h"


@interface FitNoteMainViewController ()

@end

@implementation FitNoteMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    UIImageView *backgroundImageView = [[UIImageView alloc]init];
//    backgroundImageView.image = [UIImage imageNamed:@"Ft_Sanders_Background.png"];
//    [self.view insertSubview:backgroundImageView atIndex:0];
    
   
        
        // Load images
    /*****************
        NSArray *imageNames = @[@"FtSanders_splash.png", @"FtSanders_strength.png", @"FtSanders_stressed.png", @"FtSanders_Tennis.png"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (int i = 0; i < imageNames.count; i++) {
            [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
        }
        
        // Normal Animation
        UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 83, 320, 125)];
        animationImageView.animationImages = images;
        animationImageView.animationDuration = 16.0;
        [self.view addSubview:animationImageView];
        [animationImageView startAnimating];
     
     *****************/
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleStartButton:(UIButton *)sender {
    Speak *speaker = [[Speak alloc]init];
    [speaker speakText:@"Welcome to Fit Note"];
    [speaker speakText:@"Lets Work Out"];
}

- (IBAction)handleWorkoutButtom:(UIButton *)sender {

}
@end
