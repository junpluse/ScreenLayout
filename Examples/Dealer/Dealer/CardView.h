//
//  CardView.h
//  Dealer
//
//  Created by Jun on 1/20/15.
//  Copyright (c) 2015 eje Inc. All rights reserved.
//

@import UIKit;

#import "Card.h"


@interface CardView : UIView

- (instancetype)initWithCard:(Card *)card;

@property (nonatomic, readonly) Card *card;

@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, copy) void(^draggingHandler)(CardView *view);

@end
