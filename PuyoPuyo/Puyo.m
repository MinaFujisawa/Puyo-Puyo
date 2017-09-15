//
//  Puyo.m
//  PuyoPuyo
//
//  Created by MINA FUJISAWA on 2017/09/11.
//  Copyright © 2017 MINA FUJISAWA. All rights reserved.
//

#import "Puyo.h"



@implementation Puyo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _colorList = [NSArray arrayWithObjects:@"❤️", @"💛", @"💚",@"💙", @"💜", nil];
        NSUInteger num = arc4random_uniform(3);
        _color = [_colorList objectAtIndex:num];
    }
    return self;
}

@end
