//
//  GameManager.h
//  PuyoPuyo
//
//  Created by MINA FUJISAWA on 2017/09/11.
//  Copyright © 2017 MINA FUJISAWA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Puyo.h"


//typedef struct {
//    const char* contents[MAX_X][SELECT_MAX_Y];
//} SelectAreaArray;

@interface GameManager : NSObject
@property Puyo* curPuyo1;
@property Puyo* curPuyo2;
@property Puyo* nxtPuyo1;
@property Puyo* nxtPuyo2;
@property (nonatomic)NSMutableArray* selectAreaPositions;
@property NSMutableArray* mainAreaPositions;
- (void) move : (NSString*) command;
- (void) displayCondition;
- (BOOL) isGameOver;

@end
