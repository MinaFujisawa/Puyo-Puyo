//
//  ScoreKeeper.m
//  PuyoPuyo
//
//  Created by MINA FUJISAWA on 2017/09/14.
//  Copyright © 2017 MINA FUJISAWA. All rights reserved.
//

#import "ScoreKeeper.h"

@implementation ScoreKeeper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _simulNums = [NSMutableArray array];
        _chainScoreList = [NSMutableDictionary dictionary];
        _chainNum = 0;
        _currentScore = 0;
        [_chainScoreList setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:1]];
        for(int i = 2; i < 9; i++){
            [_chainScoreList setObject:[NSNumber numberWithInt:pow(2,i+1)] forKey:[NSNumber numberWithInt:i]];
        }
        
        _simulScoreList = [NSMutableDictionary dictionary];
        for(int i = 5; i < 11; i++){
            [_simulScoreList setObject:[NSNumber numberWithInt:(i-3)] forKey:[NSNumber numberWithInt:i]];
        }
    }
    return self;
}

- (void) getScore {
    if([self getComboScore] == 0 && [self getSimulScore] == 0){
        printf("%ld x 10 x 1", self.puyoNum);
        self.currentScore = self.puyoNum * 10 * 1;
    }else{
        printf("%ld x 10 x (%ld + %ld)", self.puyoNum, [self getComboScore], [self getSimulScore]);
        self.currentScore = self.puyoNum * 10 * ([self getComboScore] + [self getSimulScore]);
    }
}

- (NSInteger) getComboScore{
    if(self.chainNum >= 9){
        return 999;
    } else{
        return [[self.chainScoreList objectForKey:[NSNumber numberWithInteger:self.chainNum]] integerValue];
    }
}

- (NSInteger) getSimulScore{
    NSInteger simulScore = 0;
    for(NSNumber *num in self.simulNums){
        NSInteger numIntg = [num integerValue];
        if(numIntg < 11) {
            simulScore += [[self.simulScoreList objectForKey:num] integerValue];
        } else {
            simulScore += 10;
        }
    }
    return simulScore;
}

- (void) resetNums {
    self.puyoNum = 0;
    [self.simulNums removeAllObjects];
}

//MARK: display
- (void) displayGotScore{
    printf("%ld CHAIN    ", (long)self.chainNum);
    [self getScore];
    printf(" = %ld\n", self.currentScore);
}

- (void) displayTotalScore{
    self.totalScore += self.currentScore;
    printf("TOTAL:%ld\n", (long)self.totalScore);
}

@end
