//
//  RandomNumbers.h
//  Moody
//
//  Created by Daniel Eggert on 07/09/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomNumbers: NSObject

- (instancetype)initWithSeed:(uint32_t)seed;

- (uint64_t)uniformDistributedWithMax:(uint64_t)max;

@end
