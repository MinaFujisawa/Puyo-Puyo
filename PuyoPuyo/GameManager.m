//
//  GameManager.m
//  PuyoPuyo
//
//  Created by MINA FUJISAWA on 2017/09/11.
//  Copyright © 2017 MINA FUJISAWA. All rights reserved.
//

#import "GameManager.h"
#import "Puyo.h"
#import "ScoreKeeper.h"

@interface GameManager() {
    ScoreKeeper *sk;
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
        sk = [ScoreKeeper new];
        _curPuyo1 = [Puyo new];
        _curPuyo2 = [Puyo new];
        _nxtPuyo1 = [Puyo new];
        _nxtPuyo2 = [Puyo new];
        
        //For test
//                [_curPuyo1 setColor:@"❤️"];
//                [_curPuyo2 setColor:@"💛"];
//                [_nxtPuyo1 setColor:@"❤️"];
//                [_nxtPuyo2 setColor:@"💛"];
        
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
        [self displayCondition];
        
    } else if ([command isEqualToString:@"left"] && p1col != 0 && p2col != 0){
        [self removePuyoFromSelectArea:p1row :p1col];
        [self removePuyoFromSelectArea:p2row :p2col];
        self.selectAreaPositions[p1row][p1col - 1] = [NSString stringWithFormat:@"%@", self.curPuyo1.color];
        self.selectAreaPositions[p2row][p2col - 1] = [NSString stringWithFormat:@"%@", self.curPuyo2.color];
        [self.curPuyo1 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", p1row, p1col - 1]];
        [self.curPuyo2 setCurrentPlace:[NSString stringWithFormat:@"%ld %ld", p2row, p2col - 1]];
        [self displayCondition];
        
    } else if ([command isEqualToString:@"rotate"]){
        [self rotate:p1row :p1col :p2row :p2col];
        [self displayCondition];
    }
    
    //MARK: Drop
    else if ([command isEqualToString:@"drop"]){
        [self dropPear:p1row :p1col :p2row :p2col];
        
        do{
            //for remove match
            for(NSMutableSet *set in self.allMatchingList){
                if(set.count >= MIN_MATCH){
                    [self displayCondition];
                    [self removeMatch];
                    
                    [sk displayGotScore];
                    [sk displayTotalScore];
                    [sk resetNums];
                    break;
                }
            }
            
            //for combo
            [self findFloatingPuyo];
            if(self.floatingList.count > 0){
                sk.comboNum += 1;
                [sk resetNums];
                [self displayCondition];
                [self dropFroatingPuyo];
            }
        } while(self.floatingList.count != 0);
        
        [self newTern];
        [self displayCondition];
        [sk displayTotalScore];
        
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
    for(int row = MAIN_MAX_ROW-1; row >= 0; row--){
        if([self.mainAreaPositions[row][col] isEqualToString:empty]){
            self.mainAreaPositions[row][col] = puyo.color;
            
            self.matchingList = [NSMutableSet set];
            [self checkMatchWithRow:row :col];
            [self.allMatchingList addObject:self.matchingList];
            break;
        }
    }
}

- (void) dropFroatingPuyo {
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"intValue" ascending:YES];
    //[self.floatingList sortedArrayUsingDescriptors:@[sortDescriptor]];
    for(NSString *place in self.floatingList){
        NSArray *placeArray = [place componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSInteger row = [placeArray[0] integerValue];
        NSInteger col = [placeArray[1] integerValue];
        NSInteger newRow;
        for(newRow = MAIN_MAX_ROW-1; newRow >= 0; newRow--){
            if([self.mainAreaPositions[newRow][col] isEqualToString:empty]){
                self.mainAreaPositions[newRow][col] = self.mainAreaPositions[row][col];
                self.matchingList = [NSMutableSet set];
                self.mainAreaPositions[row][col] = empty;
                [self checkMatchWithRow:newRow :col];
                [self.allMatchingList addObject:self.matchingList];
                
                break;
            }
        }
    }
    [NSThread sleepForTimeInterval:1];
}

- (void) findFloatingPuyo {
    self.floatingList = [NSMutableArray array];
    self.heapTops = [NSMutableArray array];
    
    //Check heap
    for(int col = 0; col < MAX_COL; col++){
        NSInteger count = 0;
        for(int row = MAIN_MAX_ROW-1; row >= 0; row--){
            if(![self.mainAreaPositions[MAIN_MAX_ROW-1][col] isEqualToString:empty]
               && ![self.mainAreaPositions[row][col] isEqualToString:empty]){
                count += 1;
                if([self.mainAreaPositions[row-1][col] isEqualToString:empty]) break;
            }
        }
        [self.heapTops addObject:[NSNumber numberWithInteger:count]];
    }
    
    //Check floating
    for(int col = 0; col < MAX_COL; col++){
        int max = MAIN_MAX_ROW - [self.heapTops[col] intValue] -1;
        for(int row = max; row >= 0; row--){
            if(![self.mainAreaPositions[row][col] isEqualToString:empty]) {
                [self.floatingList addObject: [NSString stringWithFormat:@"%d %d", row, col]];
            }
        }
    }
}


//MARK:check matches
- (void) checkMatchWithRow : (NSInteger)row :(NSInteger)col {
    
    NSString* currentPuyo = self.mainAreaPositions[row][col];
    
    if(row != 0){
        if([self.mainAreaPositions[row-1][col] isEqualToString:currentPuyo]){
            //        NSLog(@"TOP [%ld][%ld]", row-1, col);
            if(![self.matchingList containsObject:[NSString stringWithFormat:@"%ld %ld", row-1, col]]){
                [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col]];
                [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row-1, col]];
                [self checkMatchWithRow:row-1 :col];
            }
        }
    }
    if(row != MAIN_MAX_ROW-1){
        if([self.mainAreaPositions[row+1][col] isEqualToString:currentPuyo]){
            //            NSLog(@"BOTTOM [%ld][%ld]", row+1, col);
            if(![self.matchingList containsObject:[NSString stringWithFormat:@"%ld %ld", row+1, col]]){
                [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col]];
                [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row+1, col]];
                [self checkMatchWithRow:row+1 :col];
            }
        }
    }
    if(col != MAX_COL-1){
        if([self.mainAreaPositions[row][col+1] isEqualToString:currentPuyo]){
            //            NSLog(@"RIGHT [%ld][%ld]", row, col+1);
            if(![self.matchingList containsObject:[NSString stringWithFormat:@"%ld %ld", row, col+1]]){
                [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col]];
                [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col+1]];
                [self checkMatchWithRow:row :col+1];
            }
        }
    }
    if(col != 0){
        if([self.mainAreaPositions[row][col-1] isEqualToString:currentPuyo]){
            //            NSLog(@"LEFT [%ld][%ld]", row, col-1);
            if(![self.matchingList containsObject:[NSString stringWithFormat:@"%ld %ld", row, col-1]]){
                [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col]];
                [self.matchingList addObject:[NSString stringWithFormat:@"%ld %ld", row, col-1]];
                [self checkMatchWithRow:row :col-1];
            }
        }
    }
}

- (void) removeMatch {
    for(NSMutableSet *set in self.allMatchingList){
        NSArray *placeArray = [NSArray array];
        //        for(NSString *place in set){
        //            NSLog(@"matching %@",place);
        //        }
        NSInteger row, col;
        NSArray* matchArr = [set allObjects];
        if(matchArr.count >= MIN_MATCH){
            
            NSInteger simulNum = 0;
            for (NSString* place in matchArr) {
                placeArray = [place componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                row = [placeArray[0] integerValue];
                col = [placeArray[1] integerValue];
                if(![self.mainAreaPositions[row][col] isEqualToString:empty]){
                    sk.puyoNum += 1;
                    simulNum += 1;
                    self.mainAreaPositions[row][col] = empty;
                }
            }
            [sk.simulNums addObject:[NSNumber numberWithInteger:simulNum]];
        }
    }
    [self.allMatchingList removeAllObjects];
    [self.matchingList removeAllObjects];
    [NSThread sleepForTimeInterval:1];
}

//MARK: sets
- (void) newTern {
    [self.allMatchingList removeAllObjects];
    self.curPuyo1 = self.nxtPuyo1;
    self.curPuyo2 = self.nxtPuyo2;
    self.nxtPuyo1 = [Puyo new];
    self.nxtPuyo2 = [Puyo new];
    //For test
//        [_curPuyo1 setColor:@"❤️"];
//        [_curPuyo2 setColor:@"💛"];
//        [_nxtPuyo1 setColor:@"❤️"];
//        [_nxtPuyo2 setColor:@"💛"];
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

- (void) gameOver {
    for(int row = 0; row < MAIN_MAX_ROW; row++){
        for(int col = 0; col < MAX_COL; col++){
            if(![self.mainAreaPositions[row][col] isEqualToString:empty]){
                self.mainAreaPositions[row][col] = @"🖤";
            }
        }
    }
    [self displayCondition];
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
