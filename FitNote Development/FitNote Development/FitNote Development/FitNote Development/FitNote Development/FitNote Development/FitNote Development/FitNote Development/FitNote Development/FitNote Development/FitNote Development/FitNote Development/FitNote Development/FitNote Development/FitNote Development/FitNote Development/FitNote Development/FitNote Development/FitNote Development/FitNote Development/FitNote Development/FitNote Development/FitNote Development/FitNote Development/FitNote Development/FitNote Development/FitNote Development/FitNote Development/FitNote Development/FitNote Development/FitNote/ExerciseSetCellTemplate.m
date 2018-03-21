//
//  ExerciseSetCellTemplate.m
//  FitScribe
//
//  Created by Bobby Gintz on 1/22/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "ExerciseSetCellTemplate.h"

@implementation ExerciseSetCellTemplate
@synthesize numberOfReps, height, weight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.height = 20;
        self.backgroundColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        // Initialization code
        self.numberOfReps = [[UILabel alloc] init];
        self.numberOfReps.textAlignment = NSTextAlignmentLeft;
        self.numberOfReps.font = [UIFont boldSystemFontOfSize:20];
        self.numberOfReps.text = @"replabel";
        [self.contentView addSubview:self.numberOfReps];
        
        // Initialization code
        self.weight = [[UILabel alloc] init];
        self.weight.textAlignment = NSTextAlignmentLeft;
        self.weight.font = [UIFont boldSystemFontOfSize:20];
        self.weight.text = @"weight label";
        [self.contentView addSubview:self.weight];


    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat boundsY = contentRect.origin.y;
    CGRect fr;
    
    fr = CGRectMake(boundsX + 10, boundsY + 2, 120, 50);
    self.numberOfReps.frame=fr;
    
    contentRect = self.contentView.bounds;
    boundsX = contentRect.origin.x;
    boundsY = contentRect.origin.y;

    fr = CGRectMake(boundsX + 10, boundsY + 30 + 2, 120, 50);
    self.weight.frame=fr;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
