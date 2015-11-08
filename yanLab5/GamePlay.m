//
//  GamePlay.m
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import "GamePlay.h"
#import "ShipPlacing.h"
#import "ShootBoard.h"

@interface GamePlay ()

@property (strong, nonatomic) IBOutlet UIButton *resumeButton;
@property (strong, nonatomic) IBOutlet UIImageView *background;
@property (strong, nonatomic) IBOutlet UITextField *nameField1;
@property (strong, nonatomic) IBOutlet UITextField *nameField2;
@property (strong, nonatomic) IBOutlet UISegmentedControl *teamSelect1;
@property (strong, nonatomic) IBOutlet UISegmentedControl *teamSelect2;
@end

@implementation GamePlay

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.isViewLoaded) {
        //hide keyboard
        [self.nameField1 resignFirstResponder];
        [self.nameField2 resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)changeTeam:(UISegmentedControl *)sender {
    _refOptions.isHumanTeam = (self.teamSelect1.selectedSegmentIndex==0?YES:NO);
    if (_refOptions.isHumanTeam) {
        self.teamSelect2.selectedSegmentIndex = 1;
    }else if(!_refOptions.isHumanTeam){
        self.teamSelect2.selectedSegmentIndex = 0;
    }
}
- (IBAction)changeTeam2:(UISegmentedControl *)sender {
    if (self.teamSelect1.selectedSegmentIndex ==1) {
        self.teamSelect1.selectedSegmentIndex = 0;
        
    }else if(self.teamSelect1.selectedSegmentIndex==0){
        self.teamSelect1.selectedSegmentIndex = 1;
    }
    
}
- (IBAction)endEditName1:(UITextField *)sender {
    [self.nameField1 resignFirstResponder];
}

- (IBAction)endEditName2:(UITextField *)sender {
    [self.nameField2 resignFirstResponder];
}


- (IBAction)clickedbutton1:(UIButton *)sender {
    [_refGame startWithHasComputer:YES hasNetwork:NO gridWidth:10 firstMove:arc4random_uniform(2) + 1];
    
    UIViewController *next = [self createNextViewController];
    if (next != nil) {
        [self.navigationController pushViewController:next animated:YES];
    }

}

- (IBAction)clickedbutton2:(UIButton *)sender {
    [_refGame startWithHasComputer:NO hasNetwork:NO gridWidth:10 firstMove:arc4random_uniform(2) + 1];
    
    UIViewController *next = [self createNextViewController];
    if (next != nil) {
        [self.navigationController pushViewController:next animated:YES];
    }

}


- (UIViewController *)createNextViewController {
    UIViewController *next = nil;
    
    NSInteger who = [_refGame whoShouldPlace];
    if (who != 0 && who == [_refGame computerPlayer]) {
        for (NSInteger i = 0; i < [_refGame numShipsForPlayer:who]; ++i) {
            ship_t ship = [_refGame randomShipForPlayer:who atIndex:i];
            [_refGame setShip:ship forPlayer:who atIndex:i];
        }
        [_refGame finishPlacingForPlayer:who];
        who = [_refGame whoShouldPlace];
    }
        
    if (who != 0) {
        ShipPlacing *con = [[ShipPlacing alloc] initWithRefOptions:_refOptions refGame:_refGame];
        con.parent = self;
        next = con;
    }
    else {
        ShootBoard *con = [[ShootBoard alloc] initWithRefOptions:_refOptions refGame:_refGame];
        con.parent = self;
        next = con;
    }
    
    return next;
}

- (IBAction)clickedbutton:(UIButton *)sender {
    self.nameField1.text=@"Angela";
    self.teamSelect1.selectedSegmentIndex =0;
    self.teamSelect2.selectedSegmentIndex = 1;
    self.nameField2.text=@"Jack";
    _refOptions.isHumanTeam=YES;

}


- (void)doInitWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame {
    self.title = @"BATTLESHIP";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    _refOptions = refOptions;
    _refGame = refGame;
}

- (id)initWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame {
        if (self) {
        [self doInitWithRefOptions:refOptions refGame:refGame];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self.background setFrame:CGRectMake(16, 20, 734, 1008)];
//    self.background.image = [UIImage imageNamed:@"baseSetbackground.jpg"];
//    [self.view addSubview:self.background];
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
