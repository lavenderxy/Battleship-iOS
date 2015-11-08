//
//  MainView.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "MainView.h"
#import "BaseSetView.h"
#import "GamePlay.h"

@interface MainView ()

@end

@implementation MainView

- (void)doInit {
    self.title = @"Home";
    _options = [[PlayerOption alloc] init];
    [_options loadDefaults];
    [_options saveDefaults];
    _game = [[GameLogic alloc] init];
}

- (id)init {
    if (self) {
        [self doInit];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 734, 600)];
    background.image = [UIImage imageNamed:@"battleship.jpg"];
    [self.view addSubview:background];
    
    UIImageView *background1 = [[UIImageView alloc] initWithFrame:CGRectMake(16, 340, 734, 1008)];
    background1.image = [UIImage imageNamed:@"battleship_ship.jpg"];
    background1.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:background1];
    
    //*******add choose board for player****************/
    UIView *modeView = [[UIView alloc]initWithFrame:CGRectMake(100, 50, 550, 400)];
    modeView.backgroundColor = [UIColor blackColor];
    modeView.alpha = 0.5;
    modeView.layer.cornerRadius = 50.0;
    [self.view addSubview:modeView];
    
    /*********add button to select mode*****************/
    
    //1-player button
    CGRect buttonFrame1 = CGRectMake(150, 50, 250, 80);
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button1 setTitle:@"Game Start" forState:UIControlStateNormal];
    [button1 setBackgroundColor:[UIColor clearColor]];
    //button1.clipsToBounds = YES;
    [button1 setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [button1 setFrame:buttonFrame1];
    button1.titleLabel.font = [UIFont systemFontOfSize:40.0];
    [button1 addTarget:self action:@selector(button1Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [modeView addSubview:button1];
    [modeView bringSubviewToFront:button1];
    
    //2-player button
    CGRect buttonFrame2 = CGRectMake(150, 140, 250, 80);
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setTitle:@"Introduction" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor clearColor]];
    [button2 setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [button2 setFrame:buttonFrame2];
    button2.titleLabel.font = [UIFont systemFontOfSize:40.0];
    [button2 addTarget:self action:@selector(button2Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [modeView addSubview:button2];
    [modeView bringSubviewToFront:button2];
    
    
}

-(void) button1Clicked:(id)sender{
    GamePlay *con = [[GamePlay alloc] initWithRefOptions:_options refGame:_game];
    [self.navigationController pushViewController:con animated:YES];
    
}

-(void) button2Clicked:(id)sender{
    BaseSetView *con = [[BaseSetView alloc] init];
    [self.navigationController pushViewController:con animated:YES];
    
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

