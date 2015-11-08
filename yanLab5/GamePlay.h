//
//  GamePlay.h
//  yanLab5
//
//  Created by Labuser on 11/3/15.
//  Copyright (c) 2015 wustl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerOption.h"
#import "GameLogic.h"

@interface GamePlay : UIViewController{
    PlayerOption *_refOptions;
    GameLogic *_refGame;
    
}
- (id)initWithRefOptions:(PlayerOption *)refOptions refGame:(GameLogic *)refGame;
- (UIViewController *)createNextViewController;

@end
