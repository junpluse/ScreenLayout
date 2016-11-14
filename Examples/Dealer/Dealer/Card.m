//
//  Card.m
//  Dealer
//
//  Created by Jun on 1/20/15.
//  Copyright (c) 2015 eje Inc. All rights reserved.
//

#import "Card.h"


#pragma mark -
@interface Card ()

@property (nonatomic, readwrite) NSUUID *identifier;
@property (nonatomic, readwrite) CardType type;
@property (nonatomic, readwrite) CardNumber number;

@end


#pragma mark -
@implementation Card

+ (NSArray *)deck
{
    NSMutableArray *deck = [[NSMutableArray alloc] init];
    
    for (NSUInteger type = 0; type < 4; type++) {
        for (NSUInteger number = 1; number <= 13; number++) {
            Card *card = [[Card alloc] initWithType:type number:number];
            [deck addObject:card];
        }
    }
    
    for (NSUInteger i = 0; i < deck.count; i++) {
        NSInteger remainingCount = deck.count - i;
        NSInteger j = i + arc4random_uniform((u_int32_t)remainingCount);
        [deck exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    
    return [deck copy];
}

- (instancetype)initWithType:(CardType)type number:(CardNumber)number
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.identifier = [NSUUID UUID];
    self.type = type;
    self.number = number;
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        Card *card = object;
        return [self.identifier isEqual:card.identifier];
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p; type=%lu; number=%lu>", NSStringFromClass([self class]), self, (unsigned long)self.type, (unsigned long)self.number];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    self.type = [aDecoder decodeIntegerForKey:@"type"];
    self.number = [aDecoder decodeIntegerForKey:@"number"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeInteger:self.number forKey:@"number"];
}

@end
