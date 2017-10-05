//
//  ScoreKeeper.h
//  PuyoPuyo
//
//  Created by MINA FUJISAWA on 2017/09/14.
//  Copyright © 2017 MINA FUJISAWA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreKeeper : NSObject
@property NSInteger puyoNum;
@property NSInteger comboNum;
@property NSMutableArray* simulNums;
@property NSInteger totalScore;
@property NSMutableDictionary *comboScoreList;
@property NSMutableDictionary *simulScoreList;
- (void) displayGotScore;
- (void) displayTotalScore;
- (void) resetNums;
@end