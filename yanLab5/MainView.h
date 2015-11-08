//
//  MainView.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerOption.h"
#import "GameLogic.h"

@interface MainView : UIViewController{
    PlayerOption *_options;
    GameLogic *_game;
}

-(id)init;

@end
