//
//  main.m
//  PuyoPuyo
//
//  Created by MINA FUJISAWA on 2017/09/11.
//  Copyright © 2017 MINA FUJISAWA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameManager.h"
#import "InputHandler.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        GameManager* gm = [GameManager new];
        
        NSLog(@"\n◆Command\nJ : Left\nK : Right\nC : Rotate\nEnter : Conform");
        while(1) {
            [gm displaySelect];
            
            NSString* input = InputHandler.getString;
            if ([input isEqualToString:@"j"]) {
                [gm move:@"left"];
            } else if ([input isEqualToString:@"k"]) {
                [gm move:@"right"];
            } else if ([input isEqualToString:@"c"]) {
                [gm move:@"rotate"];
            } else{
                printf("not valid");
            }
        }
        
    }
    
    return 0;
}


