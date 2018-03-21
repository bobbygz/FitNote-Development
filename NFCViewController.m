//
//  NFCViewController.m
//  FitNote
//
//  Created by Bobby Gintz on 3/10/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "NFCViewController.h"

@interface NFCViewController  ()
@end

@implementation NFCViewController


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
    NSArray *imageNames = @[@"NFC1.png", @"NFC2.png", @"NFC3.png", @"NFC4.png", @"NFC5.png" ];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
          [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
           }
    
    // Normal Animation
    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 00, 340, 568)];
    animationImageView.animationImages = images;
    animationImageView.animationDuration = 16.0;
    [self.view addSubview:animationImageView];
    [animationImageView startAnimating];
    
}

@end
