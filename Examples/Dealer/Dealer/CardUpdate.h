//
//  CardUpdate.h
//  Dealer
//
//  Created by Jun on 1/21/15.
//  Copyright (c) 2015 eje Inc. All rights reserved.
//

#import "Card.h"


@interface CardUpdate : NSObject <NSCoding>

@property (nonatomic, strong) Card *card;

@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat rotation;

@property (nonatomic) BOOL hasPreviousValues;
@property (nonatomic) CGPoint previousPosition;
@property (nonatomic) CGFloat previousRotation;

@end
