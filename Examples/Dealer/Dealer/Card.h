//
//  Card.h
//  Dealer
//
//  Created by Jun on 1/20/15.
//  Copyright (c) 2015 eje Inc. All rights reserved.
//

@import UIKit;


typedef NS_ENUM(NSUInteger, CardType) {
    CardTypeClub    = 0,
    CardTypeDiamond = 1,
    CardTypeHeart   = 2,
    CardTypeSpade   = 3
};

typedef NS_ENUM(NSUInteger, CardNumber) {
    CardNumberAce   = 1,
    CardNumberTwo   = 2,
    CardNumberThree = 3,
    CardNumberFour  = 4,
    CardNumberFive  = 5,
    CardNumberSix   = 6,
    CardNumberSeven = 7,
    CardNumberEight = 8,
    CardNumberNine  = 9,
    CardNumberTen   = 10,
    CardNumberJack  = 11,
    CardNumberQueen = 12,
    CardNumberKing  = 13
};


@interface Card : NSObject <NSCoding, NSCopying>

- (instancetype)initWithType:(CardType)type number:(CardNumber)number;

@property (nonatomic, readonly) CardType type;
@property (nonatomic, readonly) CardNumber number;

+ (NSArray *)deck;

@end
