//
//  CardView.m
//  Dealer
//
//  Created by Jun on 1/20/15.
//  Copyright (c) 2015 eje Inc. All rights reserved.
//

#import "CardView.h"


#pragma mark -
@interface CardView () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite) Card *card;

@property (nonatomic, readwrite) UIImageView *imageView;
@property (nonatomic, readwrite) UIView *fillView;
@property (nonatomic, readwrite) UIView *shadowView;

@property (nonatomic, readwrite) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, readwrite) UIDynamicAnimator *animator;
@property (nonatomic, readwrite) UIAttachmentBehavior *attachment;

@end


#pragma mark -
@implementation CardView

+ (NSString *)imageNameWithType:(CardType)type number:(CardNumber)number
{
    NSString *t = nil;
    switch (type) {
        case CardTypeClub:
            t = @"C";
            break;
        case CardTypeDiamond:
            t = @"D";
            break;
        case CardTypeHeart:
            t = @"H";
            break;
        case CardTypeSpade:
            t = @"S";
            break;
    }
    
    NSString *n = nil;
    switch (number) {
        case CardNumberAce:
            n = @"A";
            break;
        case CardNumberJack:
            n = @"J";
            break;
        case CardNumberKing:
            n = @"K";
            break;
        case CardNumberQueen:
            n = @"Q";
            break;
        default:
            n = [NSString stringWithFormat:@"%lu", (unsigned long)number];
            break;
    }
    
    return [NSString stringWithFormat:@"card-%@%@", n, t];
}

- (instancetype)initWithCard:(Card *)card
{
    self = [super initWithFrame:CGRectMake(0, 0, 178, 250)];
    if (!self) {
        return nil;
    }
    
    self.card = card;
    
    NSString *imageName = [[self class] imageNameWithType:card.type number:card.number];
    UIImage *image = [UIImage imageNamed:imageName];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:imageView];
    self.imageView = imageView;
    
    UIView *fillView = [[UIView alloc] initWithFrame:self.bounds];
    fillView.backgroundColor = [UIColor whiteColor];
    fillView.layer.cornerRadius = 10;
    fillView.layer.masksToBounds = YES;
    fillView.layer.shouldRasterize = YES;
    fillView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self insertSubview:fillView belowSubview:imageView];
    self.fillView = fillView;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:self.bounds];
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeZero;
    shadowView.layer.shadowOpacity = 0.5;
    shadowView.layer.shadowRadius = 2;
    shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:fillView.layer.cornerRadius].CGPath;
    [self insertSubview:shadowView belowSubview:fillView];
    self.shadowView = shadowView;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGestureRecognizer];
    self.panGestureRecognizer = panGestureRecognizer;
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:newSuperview];
    }
    else {
        self.animator = nil;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    
    if (state == UIGestureRecognizerStateBegan) {
        CGPoint pointInReference = [sender locationOfTouch:0 inView:self.animator.referenceView];
        CGPoint pointInView = [sender locationOfTouch:0 inView:self];
        
        UIOffset offset;
        offset.horizontal = pointInView.x - CGRectGetMidX(self.bounds);
        offset.vertical = pointInView.y - CGRectGetMidY(self.bounds);
        
        UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:self offsetFromCenter:offset attachedToAnchor:pointInReference];
        attachment.length = 0;
        attachment.action = ^{
            if (self.draggingHandler) {
                self.draggingHandler(self);
            }
        };
        self.attachment = attachment;
        [self.animator addBehavior:attachment];
    }
    else if (state == UIGestureRecognizerStateChanged) {
        self.attachment.anchorPoint = [sender locationOfTouch:0 inView:self.animator.referenceView];
    }
    else if (state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.attachment];
        self.attachment = nil;
    }
    else if (state == UIGestureRecognizerStateCancelled) {
        [self.animator removeBehavior:self.attachment];
        self.attachment = nil;
    }
}

@end
