//
//  ViewController.m
//  Dealer
//
//  Created by Jun on 1/20/15.
//  Copyright (c) 2015 eje Inc. All rights reserved.
//

#import "ViewController.h"
#import "Card.h"
#import "CardView.h"
#import "CardUpdate.h"


#pragma mark -
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) NSMutableArray *deck;
@property (nonatomic, strong) NSMutableArray *cardViews;
@property (nonatomic, strong) NSMutableDictionary *markerViews;

@property (nonatomic, strong) SCLScreen *lastTarget;
@property (nonatomic, strong) NSDate *lastDraggingDate;
@property (nonatomic, strong) NSMutableSet *targetsOfCurrentDragging;

@end


#pragma mark -
@implementation ViewController

#pragma mark UIResponder

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self resetCards];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.layoutManager.gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self resetCards];
    
    [self.sessionManager startPeerInvitationsWithServiceType:@"pinchdealer" errorHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:self.statusLabel duration:0.2 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                self.statusLabel.text = error.localizedDescription;
            } completion:nil];
        });
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.sessionManager stopPeerInviations];
}

#pragma mark ViewController

- (CardView *)viewForCard:(Card *)card
{
    NSUInteger index = [self.cardViews indexOfObjectPassingTest:^BOOL(CardView *view, NSUInteger idx, BOOL *stop) {
        return [view.card isEqual:card];
    }];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    return [self.cardViews objectAtIndex:index];
}

- (CardView *)insertNewCard
{
    NSMutableArray *deck = self.deck;
    if (!deck || deck.count == 0) {
        deck = [[Card deck] mutableCopy];
        self.deck = deck;
    }
    
    Card *card = [deck lastObject];
    [deck removeLastObject];
    
    UIView *container = self.view;

    CGPoint center = CGPointMake(CGRectGetMidX(container.bounds), CGRectGetMidY(container.bounds));
    CGFloat distance = 1000;
    CGFloat rotation = M_PI * 2 * ((CGFloat)arc4random() / UINT32_MAX);
    
    CGPoint fromPoint;
    fromPoint.x = center.x + distance * cos(rotation);
    fromPoint.y = center.y + distance * sin(rotation);
    
    CGPoint toPoint = center;
    toPoint.x += (CGFloat)(arc4random() % 100) - 50;
    toPoint.y += (CGFloat)(arc4random() % 100) - 50;
    
    CardView *view = [self insertCard:card];
    view.center = fromPoint;
    
    [self animateCard:card toPosition:toPoint rotation:rotation duration:0.5 completion:nil];
    
    return view;
}

- (CardView *)insertCard:(Card *)card
{
    CardView *view = [[CardView alloc] initWithCard:card];
    
    [view.panGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [view addGestureRecognizer:tapGestureRecognizer];
    
    [self.cardViews addObject:view];
    [self.view addSubview:view];
    
    return view;
}

- (void)animateCard:(Card *)card toPosition:(CGPoint)position rotation:(CGFloat)rotation duration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion
{
    CardView *view = [self viewForCard:card];
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.95 initialSpringVelocity:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        view.center = position;
        view.transform = CGAffineTransformMakeRotation(rotation);
    } completion:^(BOOL finished) {
        [self removeCardsOutOfBounds];
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)removeCardsOutOfBounds
{
    CGRect bounds = CGRectInset(self.view.bounds, 0, 0);
    
    NSIndexSet *indexes = [self.cardViews indexesOfObjectsPassingTest:^BOOL(CardView *view, NSUInteger idx, BOOL *stop) {
        if (!CGRectIntersectsRect(bounds, view.frame)) {
            [UIView animateWithDuration:0.2 animations:^{
                view.alpha = 0.0;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
            return YES;
        }
        return NO;
    }];
    
    [self.cardViews removeObjectsAtIndexes:indexes];
}

- (void)sendCard:(Card *)card toScreen:(SCLScreen *)target
{
    CardView *cardView = [self viewForCard:card];
    if (!cardView) {
        return;
    }
    
    SCLScreen *mainScreen = [SCLScreen mainScreen];
    NSArray *connectedScreens = mainScreen.connectedScreens;
    if (![connectedScreens containsObject:target]) {
        return;
    }
    
    CGPoint centerOfTarget = CGPointMake(CGRectGetMidX(target.bounds), CGRectGetMidY(target.bounds));
    
    CGPoint fromPosition = cardView.center;
    CGFloat fromRotation = [[cardView.layer valueForKeyPath:@"transform.rotation.z"] doubleValue];
    
    CGPoint toPosition = [target convertPoint:centerOfTarget toCoordinateSpace:cardView.superview];
    toPosition.x += (CGFloat)(arc4random() % 100) - 50;
    toPosition.y += (CGFloat)(arc4random() % 100) - 50;
    CGFloat toRotation = M_PI * 2 * ((CGFloat)arc4random() / UINT32_MAX);
    
    CardUpdate *update = [[CardUpdate alloc] init];
    update.card = cardView.card;
    update.position = [mainScreen convertPoint:toPosition fromCoordinateSpace:self.view];
    update.rotation = [mainScreen convertAngle:toRotation fromCoordinateSpace:self.view];
    update.hasPreviousValues = YES;
    update.previousPosition = [mainScreen convertPoint:fromPosition fromCoordinateSpace:self.view];
    update.previousRotation = [mainScreen convertAngle:fromRotation fromCoordinateSpace:self.view];
    
    [self sendCardUpdate:update toScreens:connectedScreens withMode:MCSessionSendDataReliable];
    
    [self animateCard:cardView.card toPosition:toPosition rotation:toRotation duration:0.5 completion:nil];
}

- (void)sendCardUpdate:(CardUpdate *)update toScreens:(NSArray *)screens withMode:(MCSessionSendDataMode)mode
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:update];
    NSArray *peers = [screens valueForKeyPath:@"peerID"];
    [self.sessionManager.session sendData:data toPeers:peers withMode:mode error:nil];
}

- (void)handleCardUpdate:(CardUpdate *)update fromScreen:(SCLScreen *)screen
{
    CGPoint position = [screen convertPoint:update.position toCoordinateSpace:self.view];
    CGFloat rotation = [screen convertAngle:update.rotation toCoordinateSpace:self.view];
    
    CardView *view = [self viewForCard:update.card];
    if (!view) {
        view = [self insertCard:update.card];
        view.center = position;
        view.transform = CGAffineTransformMakeRotation(rotation);
    }
    
    if (update.hasPreviousValues) {
        CGPoint previousPosition = [screen convertPoint:update.previousPosition toCoordinateSpace:self.view];
        CGFloat previousRotation = [screen convertAngle:update.previousRotation toCoordinateSpace:self.view];
        view.center = previousPosition;
        view.transform = CGAffineTransformMakeRotation(previousRotation);
    }
    
    NSTimeInterval duration = update.hasPreviousValues ? 0.5 : 0.25;
    
    [self animateCard:update.card toPosition:position rotation:rotation duration:duration completion:nil];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        SCLScreen *mainScreen = [SCLScreen mainScreen];
        NSArray *connectedScreens = mainScreen.connectedScreens;
        if (connectedScreens.count < 1) {
            return;
        }
        
        NSUInteger index = [connectedScreens indexOfObject:self.lastTarget];
        if (index == NSNotFound || index >= connectedScreens.count - 1) {
            index = 0;
        }
        else {
            index++;
        }
        
        SCLScreen *target = [connectedScreens objectAtIndex:index];
        [self sendCard:[(CardView *)sender.view card] toScreen:target];
        self.lastTarget = target;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    CardView *view = (CardView *)sender.view;
    SCLScreen *mainScreen = [SCLScreen mainScreen];

    void(^updateScreens)(void) = ^{
        NSArray *targets = self.targetsOfCurrentDragging.allObjects;
        if (targets.count == 0) {
            return;
        }
        
        CGPoint position = view.center;
        CGFloat rotation = [[view.layer valueForKeyPath:@"transform.rotation.z"] doubleValue];
        
        CardUpdate *update = [[CardUpdate alloc] init];
        update.card = view.card;
        update.position = [mainScreen convertPoint:position fromCoordinateSpace:self.view];
        update.rotation = [mainScreen convertAngle:rotation fromCoordinateSpace:self.view];
        
        [self sendCardUpdate:update toScreens:self.targetsOfCurrentDragging.allObjects withMode:MCSessionSendDataUnreliable];
    };
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.targetsOfCurrentDragging = [[NSMutableSet alloc] init];
        self.lastDraggingDate = nil;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.lastDraggingDate && fabs(self.lastDraggingDate.timeIntervalSinceNow) < 0.1) {
            return;
        }
        self.lastDraggingDate = [NSDate date];
        
        CGRect viewFrame = [mainScreen convertRect:view.frame fromCoordinateSpace:view.superview];
        NSArray *screens = [mainScreen screensPassingTest:^BOOL(SCLScreen *screen, CGRect frame, BOOL *stop) {
            return CGRectIntersectsRect(frame, viewFrame);
        }];
        [self.targetsOfCurrentDragging addObjectsFromArray:screens];
        
        updateScreens();
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        SCLScreen *mainScreen = [SCLScreen mainScreen];
        
        CGPoint velocity = [sender velocityInView:self.view];
        CGFloat velocityDistance = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
        
        if (velocityDistance > 600) {
            CGPoint position = [sender locationInView:self.view];
            position = [mainScreen convertPoint:position fromCoordinateSpace:self.view];
            
            CGFloat velocityAngle = atan2(velocity.y, velocity.x);
            velocityAngle = [mainScreen convertAngle:velocityAngle fromCoordinateSpace:self.view];
            
            __block CGFloat minAngleDiff = M_PI_4;
            NSArray *screens = [mainScreen screensPassingTest:^BOOL(SCLScreen *screen, CGRect frame, BOOL *stop) {
                CGPoint frameCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
                CGFloat frameAngle = atan2(frameCenter.y - position.y, frameCenter.x - position.x);
                
                CGFloat angleDiff = velocityAngle - frameAngle;
                while (angleDiff > M_PI) {
                    angleDiff -= M_PI * 2;
                }
                while (angleDiff < -M_PI) {
                    angleDiff += M_PI * 2;
                }
                angleDiff = fabs(angleDiff);
                
                if (minAngleDiff > angleDiff) {
                    minAngleDiff = angleDiff;
                    return YES;
                }
                return NO;
            }];
            
            if (screens.count > 0) {
                NSUInteger index = [screens indexOfObject:self.lastTarget];
                if (index == NSNotFound || index >= screens.count - 1) {
                    index = 0;
                }
                else {
                    index++;
                }
                SCLScreen *target = [screens objectAtIndex:index];
                [self sendCard:view.card toScreen:target];
                self.lastTarget = target;
                
                sender.enabled = NO;
                sender.enabled = YES;
                return;
            }
        }
        
        updateScreens();
        
        [self removeCardsOutOfBounds];
    }
    else if (sender.state == UIGestureRecognizerStateCancelled) {
        [self removeCardsOutOfBounds];
    }
}

- (void)resetCards
{
    [self.cardViews enumerateObjectsUsingBlock:^(CardView *view, NSUInteger idx, BOOL *stop) {
        CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        CGFloat distance = 1000;
        CGFloat rotation = M_PI * 2 * ((CGFloat)arc4random() / UINT32_MAX);
        
        CGPoint position;
        position.x = center.x + distance * cos(rotation);
        position.y = center.y + distance * sin(rotation);
        
        [UIView animateWithDuration:0.3 animations:^{
            view.center = position;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }];
    
    self.cardViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 13; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self insertNewCard];
        });
    }
}

- (void)updateStatusLabel
{
    NSString *text = nil;
    
    NSUInteger numberOfConnectedPeers = self.sessionManager.session.connectedPeers.count;
    NSUInteger numberOfConnectedScreens = [SCLScreen mainScreen].connectedScreens.count;
    
    if (numberOfConnectedPeers == 0) {
        text = @"finding screens…";
    }
    else {
        text = [NSString stringWithFormat:@"%lu of %lu screens connected", (unsigned long)numberOfConnectedScreens, (unsigned long)numberOfConnectedPeers];
    }
    
    [UIView transitionWithView:self.statusLabel duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        self.statusLabel.text = text;
    } completion:nil];
}

- (void)updateMarkerViews
{
    static const CGFloat markerWidth = 10;
    CGRect bounds = self.view.bounds;
    CGFloat minX = CGRectGetMinX(bounds);
    CGFloat maxX = CGRectGetMaxX(bounds);
    CGFloat minY = CGRectGetMinY(bounds);
    CGFloat maxY = CGRectGetMaxY(bounds);
    
    SCLScreen *mainScreen = [SCLScreen mainScreen];
    
    [mainScreen enumerateScreensUsingBlock:^(SCLScreen *screen, CGRect frame, BOOL *stop) {
        frame = [mainScreen convertRect:frame toCoordinateSpace:self.view];
        
        UIView *view = [self.markerViews objectForKey:screen];
        if (!view) {
            view = [[UIView alloc] initWithFrame:frame];
            view.backgroundColor = self.statusLabel.textColor;
            view.layer.shadowColor = self.statusLabel.shadowColor.CGColor;
            view.layer.shadowOffset = CGSizeZero;
            view.layer.shadowOpacity = 1;
            view.layer.shadowRadius = 1;
            [self.view insertSubview:view aboveSubview:self.statusLabel];
            
            if (!self.markerViews) {
                self.markerViews = [[NSMutableDictionary alloc] init];
            }
            [self.markerViews setObject:view forKey:screen];
        }
        
        CGRect markerFrame = frame;
        if (CGRectGetMaxX(frame) < minX) {
            markerFrame.origin.x = minX;
            markerFrame.size.width = markerWidth;
        }
        else if (CGRectGetMaxY(frame) < minY) {
            markerFrame.origin.y = minY;
            markerFrame.size.height = markerWidth;
        }
        else if (CGRectGetMinX(frame) > maxX) {
            markerFrame.origin.x = maxX - markerWidth;
            markerFrame.size.width = markerWidth;
        }
        else if (CGRectGetMinY(frame) > maxY) {
            markerFrame.origin.y = maxY - markerWidth;
            markerFrame.size.height = markerWidth;
        }
        
        if (!CGRectEqualToRect(view.frame, markerFrame)) {
            view.frame = frame;
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:0 animations:^{
                view.frame = markerFrame;
            } completion:nil];
        }
    }];
    
    NSSet *connectedScreens = [NSSet setWithArray:mainScreen.connectedScreens];
    NSSet *screensToRemove = [self.markerViews keysOfEntriesPassingTest:^BOOL(SCLScreen *screen, id obj, BOOL *stop) {
        return ![connectedScreens containsObject:screen];
    }];
    [screensToRemove enumerateObjectsUsingBlock:^(SCLScreen *screen, BOOL *stop) {
        UIView *view = [self.markerViews objectForKey:screen];
        [self.markerViews removeObjectForKey:screen];
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }];
}

#pragma mark MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    [self updateStatusLabel];
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    @try {
        CardUpdate *update = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([update isKindOfClass:[CardUpdate class]]) {
            SCLScreen *sender = [self.sessionManager screenForPeer:peerID];
            [self handleCardUpdate:update fromScreen:sender];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

#pragma mark SCLLayoutObserving

- (void)layoutDidChangeForScreens:(NSArray *)updatedScreens
{
    [self updateStatusLabel];
    
    SCLScreen *mainScreen = [SCLScreen mainScreen];
    if ([updatedScreens containsObject:mainScreen]) {
        [self updateMarkerViews];
    }
}

@end
