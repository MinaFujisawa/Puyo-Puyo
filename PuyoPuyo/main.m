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
//        NSTimer *timer = gm.getTimer;
        
        NSLog(@"\n◆Command | J - Left | K - Right | L - Rotate | D - Drop\n");
        [gm displayCondition];
        while(![gm isGameOver]) {
            
            
            
            NSString* input = InputHandler.getString;
            if ([input isEqualToString:@"j"]) {
                [gm move:@"left"];
            } else if ([input isEqualToString:@"k"]) {
                [gm move:@"right"];
            } else if ([input isEqualToString:@"l"]) {
                [gm move:@"rotate"];
            } else if ([input isEqualToString:@"d"]) {
                [gm move:@"drop"];
            }else{
                printf("not valid");
            }
            
            [gm displayCondition];
//            [[NSRunLoop currentRunLoop] run];
        }
        
    }
    
    return 0;
}


