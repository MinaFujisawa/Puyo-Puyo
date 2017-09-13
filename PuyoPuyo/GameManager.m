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
    
}

@end

@implementation GameManager
NSInteger const MAX_COL = 6;
NSInteger const SELECT_MAX_ROW = 3;
NSInteger const MAIN_MAX_ROW = 8;
NSInteger const MIN_MATCH = 4;
NSString *const empty = @"▫️";


- (instancetype)init
{
    self = [super init];
    if (self) {
        _allMatchingList = [NSMutableArray array];
        _curPuyo1 = [Puyo new];
        _curPuyo2 = [Puyo new];
        _nxtPuyo1 = [Puyo new];
        _nxtPuyo2 = [Puyo new];
        
        //For test
        [_curPuyo1 setColor:@"❤️"];
        [_curPuyo2 setColor:@"💛"];
        [_nxtPuyo1 setColor:@"❤️"];
        [_nxtPuyo2 setColor:@"💛"];
        
        //set first Puyos to selectAreaPositions
        _selectAreaPositions = [NSMutableArray array];
        [self placeSelectAreaPuyo];
        
        //set mainAreaPositions
        _mainAreaPositions = [NSMutableArray array];
        for(int i = 0; i < MAIN_MAX_ROW; i++){
            [_mainAreaPositions addObject:[NSMutableArray arrayWithObjects:empty,empty, empty, empty, empty ,empty,nil]];
        }
        
    }
    return self;
}

//MARK:Operation
- (void) move : (NSString*) command {
    //Get current place
    NSArray *place1 = [self.curPuyo1.currentPlace componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger p1row = [[place1 objectAtIndex:0] intValue];
    NSInteger p1col = [[place1 objectAtIndex:1] intValue];
    
    NSArray *place2 = [self.curPuyo2.currentPlace componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger p2row = [[place2 objectAtIndex:0] intValue];
    NSInteger p2col = [[place2 objectAtIndex:1] intValue];
    
    //Move
    if ([command isEqualToString:@"right"] && p1col != MAX_COL-1 && p2col != MAX_COL-1) {
        [self removePuyoFromSelectArea:p1row :p1col];
        [self removePuyoFromSelectArea:p2row :p2col];
        self.selectAreaPositions[p1row][p1col + 1] = [NSString stringWithFormat:@"%@", self.curPuyo1.color];
        self.selectAreaPositions[p2row][p2col + 1] = [NSString stringWithFormat:@"%@", self.curPuyo2.color];
        [self.curPuyo1 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", p1row, p1col + 1]];
        [self.curPuyo2 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", p2row, p2col + 1]];
        
    } else if ([command isEqualToString:@"left"] && p1col != 0 && p2col != 0){
        [self removePuyoFromSelectArea:p1row :p1col];
        [self removePuyoFromSelectArea:p2row :p2col];
        self.selectAreaPositions[p1row][p1col - 1] = [NSString stringWithFormat:@"%@", self.curPuyo1.color];
        self.selectAreaPositions[p2row][p2col - 1] = [NSString stringWithFormat:@"%@", self.curPuyo2.color];
        [self.curPuyo1 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", p1row, p1col - 1]];
        [self.curPuyo2 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", p2row, p2col - 1]];
        
    } else if ([command isEqualToString:@"rotate"]){
        [self rotate:p1row :p1col :p2row :p2col];
    }
    
    else if ([command isEqualToString:@"drop"]){
        [self dropPear:p1row :p1col :p2row :p2col];
        for(NSMutableSet *set in self.allMatchingList){
            if(set.count >= MIN_MATCH){
                [self displayCondition];
                [self removeMatch];
                [NSThread sleepForTimeInterval:1];
                break;
            }
        }
        [self newTern];
    }
}


- (void) rotate : (NSInteger) p1row : (NSInteger) p1col : (NSInteger) p2row : (NSInteger) p2col {
    NSInteger newP2row = 0;
    NSInteger newP2col = 0;
    
    //to bottom
    if (p1col < p2col){
        newP2row = p2row + 1;
        newP2col = p2col - 1;
    }
    //to left
    else if (p1row < p2row){
        if (p1col != 0){
            newP2row = p2row - 1;
            newP2col = p2col - 1;
        } else{
            newP2row = p2row;
            newP2col = p2col;
        }
    }
    //to top
    else if (p2col < p1col){
        newP2row = p2row - 1;
        newP2col = p2col + 1;
    }
    //to right
    else if (p2row < p1row){
        if (p1col != MAX_COL-1){
            newP2row = p2row + 1;
            newP2col = p2col + 1;
        } else{
            newP2row = p2row;
            newP2col = p2col;
        }
    }
    
    [self removePuyoFromSelectArea:p2row :p2col];
    self.selectAreaPositions[newP2row][newP2col] = [NSString stringWithFormat:@"%@", self.curPuyo2.color];
    [self.curPuyo2 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", newP2row, newP2col]];
}

- (void) dropPear : (NSInteger) p1row : (NSInteger) p1col : (NSInteger) p2row : (NSInteger) p2col {
    NSInteger priority;
    (p1row > p2row) ? (priority = 1) : (priority = 2);
    
    if(priority == 1){
        [self drop:p1col puyoIndex:1];
        [self drop:p2col puyoIndex:2];
    } else if (priority == 2){
        [self drop:p2col puyoIndex:2];
        [self drop:p1col puyoIndex:1];
    }
}

- (void) drop : (NSInteger) col puyoIndex: (NSInteger) puyoIndex{
    Puyo *puyo;
    (puyoIndex == 1) ? (puyo = self.curPuyo1) : (puyo = self.curPuyo2);
    for(int i = MAIN_MAX_ROW-1; i >= 0; i--){
        if([self.mainAreaPositions[i][col] isEqualToString:empty]){
            self.mainAreaPositions[i][col] = puyo.color;
            
            self.matchingList = [NSMutableSet set];
            [self checkMatchWithRow:i :col exception:@""];
            [self.allMatchingList addObject:self.matchingList];
            
            NSLog(@"match count %ld", self.matchingList.count);
            for (NSString *place in self.matchingList) {
                NSLog(@"%@", place);
            }
            break;
        }
    }
}


//MARK:check matches
- (void) checkMatchWithRow : (NSInteger)row :(NSInteger)col exception:(NSString*) exception {
    
    NSString* currentPuyo = self.mainAreaPositions[row][col];
    
    if([self.mainAreaPositions[row-1][col] isEqualToString:currentPuyo]
       && ![exception isEqualToString:@"top"]){
        NSLog(@"TOP [%ld][%ld]", row-1, col);
        [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col]];
        [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row-1, col]];
        [self checkMatchWithRow:row-1 :col exception:@"bottom"];
    }
    if(row != MAIN_MAX_ROW-1){
        if([self.mainAreaPositions[row+1][col] isEqualToString:currentPuyo]
           && ![exception isEqualToString:@"bottom"]){
            NSLog(@"BOTTOM [%ld][%ld]", row+1, col);
            [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col]];
            [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row+1, col]];
            [self checkMatchWithRow:row+1 :col exception:@"top"];
        }
    }
    if(col != MAX_COL-1){
        if([self.mainAreaPositions[row][col+1] isEqualToString:currentPuyo]
           && ![exception isEqualToString:@"right"]){
            NSLog(@"RIGHT [%ld][%ld]", row, col+1);
            [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col]];
            [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col+1]];
            [self checkMatchWithRow:row :col+1 exception:@"left"];
        }
    }
    if(col != 0){
        if([self.mainAreaPositions[row][col-1] isEqualToString:currentPuyo]
           && ![exception isEqualToString:@"left"]){
            NSLog(@"LEFT [%ld][%ld]", row, col-1);
            [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col]];
            [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col-1]];
            [self checkMatchWithRow:row :col-1 exception:@"right"];
        }
    }
}

- (void) removeMatch {
    for(NSMutableSet *set in self.allMatchingList){
        NSArray *placeArray = [NSArray array];
        NSInteger row, col;
        NSArray* matchArr = [set allObjects];
        if(matchArr.count >= MIN_MATCH){
            for (NSString* place in matchArr) {
                placeArray = [place componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                row = [placeArray[0] integerValue];
                col = [placeArray[1] integerValue];
                self.mainAreaPositions[row][col] = empty;
            }
        }
    }
}

//MARK: sets
- (void) newTern {
    [self.allMatchingList removeAllObjects];
    self.curPuyo1 = self.nxtPuyo1;
    self.curPuyo2 = self.nxtPuyo2;
    self.nxtPuyo1 = [Puyo new];
    self.nxtPuyo2 = [Puyo new];
    //For test
    [_curPuyo1 setColor:@"❤️"];
    [_curPuyo2 setColor:@"💛"];
    [_nxtPuyo1 setColor:@"❤️"];
    [_nxtPuyo2 setColor:@"💛"];
    [self placeSelectAreaPuyo];
    
}

- (BOOL) isGameOver {
    BOOL isGameOver = NO;
    for (int col = 0; col < MAX_COL; col++ ){
        if(![self.mainAreaPositions[0][col] isEqualToString:empty]) {
            isGameOver = YES;
            break;
        }
    }
    return isGameOver;
}

- (void) placeSelectAreaPuyo {
    [self resetSelectArea];
    
    [self.curPuyo1 setCurrentPlace:@"1 2"];
    [self.curPuyo2 setCurrentPlace:@"1 3"];
    
    self.selectAreaPositions[1][2] = [NSString stringWithFormat:@"%@", self.curPuyo1.color];
    self.selectAreaPositions[1][3] = [NSString stringWithFormat:@"%@", self.curPuyo2.color];
}

- (void) resetSelectArea {
    [self.selectAreaPositions removeAllObjects];
    //    NSMutableArray *arrayX = [NSMutableArray array];
    //
    //    for(int i = 0; i < MAX_X; i++){
    //        [arrayX addObject:(empty)];
    //    }
    for(int i = 0; i < SELECT_MAX_ROW; i++){
        //            [_selectAreaPositions addObject:arrayX]; //why not workin?
        [self.selectAreaPositions addObject:[NSMutableArray arrayWithObjects:empty,empty, empty, empty, empty ,empty,nil]];
    }
}


- (void) removePuyoFromSelectArea : (NSInteger)x : (NSInteger)y {
    self.selectAreaPositions[x][y] = empty;
}


//MARK:display
- (void) displayCondition {
    [self displayNext];
    printf("\n＿＿＿＿＿＿＿＿＿");
    [self displayArray:0]; //select area
    printf("\n===============");
    [self displayArray:1]; //main area
    printf("\n￣￣￣￣￣￣￣￣￣\n");
    
}

- (void) displayNext {
    printf("NEXT : %s%s", [self.nxtPuyo1.color UTF8String], [self.nxtPuyo2.color UTF8String]);
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
