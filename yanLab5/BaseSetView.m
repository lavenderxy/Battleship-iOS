//
//  BaseSetView.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "BaseSetView.h"

@interface BaseSetView ()

@property (strong, nonatomic) IBOutlet UITextView *textView;
@end

@implementation BaseSetView



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 734, 1008)];
    background.image = [UIImage imageNamed:@"baseSetbackground.jpg"];
    [self.view addSubview:background];
    
    [self.view bringSubviewToFront:self.textView];

    
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

@end
