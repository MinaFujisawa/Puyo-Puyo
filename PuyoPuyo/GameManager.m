//
//  GameManager.m
//  PuyoPuyo
//
//  Created by MINA FUJISAWA on 2017/09/11.
//  Copyright © 2017 MINA FUJISAWA. All rights reserved.
//

#import "GameManager.h"
#import "Puyo.h"

NSInteger const MAX_X = 6;
NSInteger const SELECT_MAX_Y = 3;
NSInteger const MAIN_MAX_Y = 12;

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
    }
}
- (void) remove : (NSInteger)x : (NSInteger)y {
    self.selectAreaPositions[x][y] = empty;
}
- (void) newTern {
    
}
- (void) displaySelect {
    for(NSArray *arX in self.selectAreaPositions){
        printf("\n|");
        for(NSString *puyoString in arX){
            printf("%s", [puyoString UTF8String]);
        }
        printf("|");
    }
    printf("\n===============\n");
}
@end
