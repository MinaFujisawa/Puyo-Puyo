//
//  GameManager.m
//  PuyoPuyo
//
//  Created by MINA FUJISAWA on 2017/09/11.
//  Copyright © 2017 MINA FUJISAWA. All rights reserved.
//

#import "GameManager.h"
#import "Puyo.h"

@interface GameManager() {
    NSTimer *timer;
    NSInteger count;
}

@end
NSInteger const MAX_X = 6;
NSInteger const SELECT_MAX_Y = 3;
NSInteger const MAIN_MAX_Y = 10;

@implementation GameManager
NSString * const empty = @"▫️";

- (instancetype)init
{
    self = [super init];
    if (self) {
        _curPuyo1 = [Puyo new];
        _curPuyo2 = [Puyo new];
        _nxtPuyo1 = [Puyo new];
        _nxtPuyo2 = [Puyo new];
        
        //set first Puyos to selectAreaPositions
        _selectAreaPositions = [NSMutableArray array];
        NSMutableArray *arrayX = [NSMutableArray array];
        
        for(int i = 0; i < MAX_X; i++){
            [arrayX addObject:(empty)];
        }
        for(int i = 0; i < SELECT_MAX_Y; i++){
            //            [_selectAreaPositions addObject:arrayX]; //why not workin?
            [_selectAreaPositions addObject:[NSMutableArray arrayWithObjects:empty,empty, empty, empty, empty ,empty,nil]];
        }
        
        [_curPuyo1 setCurrentPlace:@"0 2"];
        [_curPuyo2 setCurrentPlace:@"1 2"];
        self.selectAreaPositions[0][2] = [NSString stringWithFormat:@"%@", _curPuyo1.color];
        self.selectAreaPositions[1][2] = [NSString stringWithFormat:@"%@", _curPuyo2.color];
        
        //set mainAreaPositions
        _mainAreaPositions = [NSMutableArray array];
        for(int i = 0; i < MAIN_MAX_Y; i++){
            [_mainAreaPositions addObject:[NSMutableArray arrayWithObjects:empty,empty, empty, empty, empty ,empty,nil]];
        }
        
        //For timer
        [self setTimer];
    }
    return self;
}

- (void) move : (NSString*) command {
    //Get current place
    NSArray *place1 = [self.curPuyo1.currentPlace componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger x1 = [[place1 objectAtIndex:0] intValue];
    NSInteger y1 = [[place1 objectAtIndex:1] intValue];
    
    NSArray *place2 = [self.curPuyo2.currentPlace componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger x2 = [[place2 objectAtIndex:0] intValue];
    NSInteger y2 = [[place2 objectAtIndex:1] intValue];
    
    //Move
    if ([command isEqualToString:@"right"]) {
        self.selectAreaPositions[x1][y1 + 1] = [NSString stringWithFormat:@"%@", self.curPuyo1.color];
        self.selectAreaPositions[x2][y2 + 1] = [NSString stringWithFormat:@"%@", self.curPuyo2.color];
        [self.curPuyo1 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", x1, y1 + 1]];
        [self.curPuyo2 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", x2, y2 + 1]];
        [self remove:x1 :y1];
        [self remove:x2 :y2];
        
    } else if ([command isEqualToString:@"left"]){
        self.selectAreaPositions[x1][y1 - 1] = [NSString stringWithFormat:@"%@", self.curPuyo1.color];
        self.selectAreaPositions[x2][y2 - 1] = [NSString stringWithFormat:@"%@", self.curPuyo2.color];
        [self.curPuyo1 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", x1, y1 - 1]];
        [self.curPuyo2 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", x2, y2 - 1]];
        [self remove:x1 :y1];
        [self remove:x2 :y2];
        
    } else if ([command isEqualToString:@"drop"]){
        
    }
}

- (void)setTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(repeateMethod:)
                                            userInfo:nil
                                             repeats:YES];
    count = 0;
}


- (void)displayMain {
    [self repeateMethod:timer];
}
- (void)repeateMethod:(NSTimer *)timer{
    count += 1;
    NSLog(@"Hoge");
}


- (void) remove : (NSInteger)x : (NSInteger)y {
    self.selectAreaPositions[x][y] = empty;
}
- (void) newTern {
    
}
- (void) displayCondition {
    printf("\nーーーーーーーーー");
    [self displayArray:0]; //select area
    printf("\n===============");
    [self displayArray:1]; //main area
    printf("\nーーーーーーーーー");
    
}

- (void) displayArray : (NSInteger) areaType {
    NSMutableArray *array;
    if(areaType == 0){
        array = self.selectAreaPositions;
    } else if(areaType == 1){
        array = self.mainAreaPositions;
    }
    
    for(NSArray *arX in array){
        printf("\n|");
        for(NSString *puyoString in arX){
            printf("%s", [puyoString UTF8String]);
        }
        printf("|");
    }
}
@end
