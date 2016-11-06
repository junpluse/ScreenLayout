//
//  CardUpdate.m
//  Dealer
//
//  Created by Jun on 1/21/15.
//  Copyright (c) 2015 eje Inc. All rights reserved.
//

#import "CardUpdate.h"


#pragma mark -
@implementation CardUpdate

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.card = [aDecoder decodeObjectOfClass:[Card class] forKey:@"card"];
    self.position = [aDecoder decodeCGPointForKey:@"position"];
    self.rotation = [aDecoder decodeDoubleForKey:@"rotation"];
    self.hasPreviousValues = [aDecoder decodeBoolForKey:@"hasPreviousValues"];
    self.previousPosition = [aDecoder decodeCGPointForKey:@"previousPosition"];
    self.previousRotation = [aDecoder decodeDoubleForKey:@"previousRotation"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.card forKey:@"card"];
    [aCoder encodeCGPoint:self.position forKey:@"position"];
    [aCoder encodeDouble:self.rotation forKey:@"rotation"];
    [aCoder encodeBool:self.hasPreviousValues forKey:@"hasPreviousValues"];
    [aCoder encodeCGPoint:self.previousPosition forKey:@"previousPosition"];
    [aCoder encodeDouble:self.previousRotation forKey:@"previousRotation"];
}

@end
