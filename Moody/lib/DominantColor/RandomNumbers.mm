//
//  RandomNumbers.m
//  Moody
//
//  Created by Daniel Eggert on 07/09/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

#import "RandomNumbers.h"

#import <random>
#import <algorithm>



@implementation RandomNumbers
{
    std::mt19937_64 engine;
}

- (instancetype)initWithSeed:(uint32_t)seed;
{
    self = [super init];
    if (self != nil) {
        engine.seed(seed);
    }
    return self;
}

- (uint64_t)uniformDistributedWithMax:(uint64_t)max;
{
    std::uniform_int_distribution<uint64_t> uniform_dist(0, max);
    return uniform_dist(engine);
}

@end
