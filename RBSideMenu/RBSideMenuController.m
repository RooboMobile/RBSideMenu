//
//  RBSideMenuController.m
//  Pods
//
//  Created by baxiang on 2017/10/3.
//

#import "RBSideMenuController.h"

@implementation UIViewController (RBSideMenuController)

- (RBSideMenuController *)sideMenuViewController
{
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[RBSideMenuController class]]) {
            return (RBSideMenuController *)iter;
        } else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }
    return nil;
}


- (void)presentLeftMenuViewController
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)presentRightMenuViewController
{
    [self.sideMenuViewController presentRightMenuViewController];
}

@end

NSString * const RBSideMenuWillShowMenuViewController = @"kRBSideMenuWillShowMenuViewController";
NSString * const RBSideMenuDidShowMenuViewController = @"kRBSideMenuDidShowMenuViewController";
NSString * const RBSideMenuWillHideMenuViewController = @"kRBSideMenuWillHideMenuViewController";
NSString * const RBSideMenuDidHideMenuViewController = @"kRBSideMenuDidHideMenuViewController";

@interface RBSideMenuController ()
@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (strong, readwrite, nonatomic) UIView *menuViewContainer;
@property (strong, readwrite, nonatomic) UIView *contentViewContainer;
@property (strong, readwrite, nonatomic) UIButton *contentButton;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;
@property (assign, readwrite, nonatomic) BOOL didNotifyDelegate;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) BOOL leftMenuVisible;
@end

@implementation RBSideMenuController
- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _menuViewContainer = [[UIView alloc] init];
    _contentViewContainer = [[UIView alloc] init];
    _animationDuration = 0.35f;
    _interactivePopGestureRecognizerEnabled = YES;
    _fadeMenuView = YES;
    _parallaxMenuMinimumRelativeValue = -15;
    _parallaxMenuMaximumRelativeValue = 15;
    _parallaxContentMinimumRelativeValue = -25;
    _parallaxContentMaximumRelativeValue = 25;
    _bouncesHorizontally = NO;
    _panFromEdge = NO;
    _panMinimumOpenThreshold = 60.0;
    _contentViewInLandscapeOffsetCenterX = 30.f;
    _contentViewInPortraitOffsetCenterX  = ([UIScreen mainScreen].bounds.size.width/2)-50;
}
#pragma mark -
#pragma mark Public methods
- (id)initWithContentViewController:(UIViewController *)contentViewController leftMenuViewController:(UIViewController *)leftMenuViewController
{
    self = [self init];
    if (self) {
        _contentViewController = contentViewController;
        _leftMenuViewController = leftMenuViewController;
    }
    return self;
}

- (void)presentLeftMenuViewController
{
    [self presentMenuViewContainerWithMenuViewController:self.leftMenuViewController];
    [self showLeftMenuViewController];
}


- (void)hideMenuViewController
{
    [self hideMenuViewControllerAnimated:YES];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (_contentViewController == contentViewController)
    {
        return;
    }
    
    if (!animated) {
        [self setContentViewController:contentViewController];
    } else {
        [self addChildViewController:contentViewController];
        contentViewController.view.alpha = 0;
        contentViewController.view.frame = self.contentViewContainer.bounds;
        [self.contentViewContainer addSubview:contentViewController.view];
        [UIView animateWithDuration:self.animationDuration animations:^{
            contentViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [self hideViewController:self.contentViewController];
            [contentViewController didMoveToParentViewController:self];
            _contentViewController = contentViewController;
            [self statusBarNeedsAppearanceUpdate];
        }];
    }
}

#pragma mark View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = self.backgroundImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView;
    });
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.leftMenuViewController) {
        [self addChildViewController:self.leftMenuViewController];
        self.leftMenuViewController.view.frame = self.view.bounds;
        self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.leftMenuViewController.view];
        [self.leftMenuViewController didMoveToParentViewController:self];
    }
    self.contentViewContainer.frame = self.view.bounds;
    self.contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    self.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
   
    
    self.view.multipleTouchEnabled = NO;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
}

#pragma mark -
#pragma mark Private methods

- (void)presentMenuViewContainerWithMenuViewController:(UIViewController *)menuViewController
{
    self.menuViewContainer.transform = CGAffineTransformIdentity;
    
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RBSideMenuWillShowMenuViewController object:nil];
    if ([self.delegate conformsToProtocol:@protocol(RBSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:menuViewController];
    }
}

- (void)hideViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)addContentButton
{
    if (self.contentButton.superview)
        return;
    
    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewContainer.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewContainer addSubview:self.contentButton];
}

- (void)statusBarNeedsAppearanceUpdate
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

- (void)hideMenuViewControllerAnimated:(BOOL)animated
{
    UIViewController *visibleMenuViewController =  self.leftMenuViewController;
    [visibleMenuViewController beginAppearanceTransition:NO animated:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:RBSideMenuWillHideMenuViewController object:nil];
    if ([self.delegate conformsToProtocol:@protocol(RBSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController: self.leftMenuViewController];
    }
    
    self.visible = NO;
    self.leftMenuVisible = NO;
    [self.contentButton removeFromSuperview];
    
    __typeof (self) __weak weakSelf = self;
    void (^animationBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.contentViewContainer.transform = CGAffineTransformIdentity;
        strongSelf.contentViewContainer.frame = strongSelf.view.bounds;
        
        strongSelf.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
        strongSelf.contentViewContainer.alpha = 1;
    };
    void (^completionBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [visibleMenuViewController endAppearanceTransition];
        if (!strongSelf.visible){
            [[NSNotificationCenter defaultCenter] postNotificationName:RBSideMenuDidHideMenuViewController object:nil];
            if ([strongSelf.delegate conformsToProtocol:@protocol(RBSideMenuDelegate)] && [strongSelf.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
                  [strongSelf.delegate sideMenu:strongSelf didHideMenuViewController: strongSelf.leftMenuViewController];
            }
        }
    };
    
    if (animated) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:self.animationDuration animations:^{
            animationBlock();
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            completionBlock();
        }];
    } else {
        animationBlock();
        completionBlock();
    }
    [self statusBarNeedsAppearanceUpdate];
}


- (void)showLeftMenuViewController
{
    if (!self.leftMenuViewController) {
        return;
    }
    [self.leftMenuViewController beginAppearanceTransition:YES animated:YES];
    self.leftMenuViewController.view.hidden = NO;
    [self.view.window endEditing:YES];
    [self addContentButton];
   
    [self resetContentViewScale];
    
    [UIView animateWithDuration:self.animationDuration animations:^{        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetWidth(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
        } else {
            self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetHeight(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
        }
        
        self.menuViewContainer.alpha = !self.fadeMenuView ?: 1.0f;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
    
        
    } completion:^(BOOL finished) {
        [self.leftMenuViewController endAppearanceTransition];
        
        if (!self.visible){
            [[NSNotificationCenter defaultCenter] postNotificationName:RBSideMenuDidShowMenuViewController object:nil];
            if([self.delegate conformsToProtocol:@protocol(RBSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
                [self.delegate sideMenu:self didShowMenuViewController:self.leftMenuViewController];
            }
        }
        self.visible = YES;
        self.leftMenuVisible = YES;
    }];
    
    [self statusBarNeedsAppearanceUpdate];
}
- (void)resetContentViewScale
{
    CGAffineTransform t = self.contentViewContainer.transform;
    CGFloat scale = sqrt(t.a * t.a + t.c * t.c);
    CGRect frame = self.contentViewContainer.frame;
    self.contentViewContainer.transform = CGAffineTransformIdentity;
    self.contentViewContainer.transform = CGAffineTransformMakeScale(scale, scale);
    self.contentViewContainer.frame = frame;
}
#pragma mark -
#pragma mark Status Bar Appearance Management

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    
   statusBarStyle = self.visible ? self.menuPreferredStatusBarStyle : self.contentViewController.preferredStatusBarStyle;
   if (self.contentViewContainer.frame.origin.y > 10) {
           statusBarStyle = self.menuPreferredStatusBarStyle;
       } else {
           statusBarStyle = self.contentViewController.preferredStatusBarStyle;
     }
    
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;
   
                       statusBarHidden = self.visible ? self.menuPrefersStatusBarHidden : self.contentViewController.prefersStatusBarHidden;
                       if (self.contentViewContainer.frame.origin.y > 10) {
                           statusBarHidden = self.menuPrefersStatusBarHidden;
                       } else {
                           statusBarHidden = self.contentViewController.prefersStatusBarHidden;
                       }
   
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
   
                       statusBarAnimation = self.visible ? self.leftMenuViewController.preferredStatusBarUpdateAnimation : self.contentViewController.preferredStatusBarUpdateAnimation;
                       if (self.contentViewContainer.frame.origin.y > 10) {
                           statusBarAnimation = self.leftMenuViewController.preferredStatusBarUpdateAnimation;
                       } else {
                           statusBarAnimation = self.contentViewController.preferredStatusBarUpdateAnimation;
                       }
    return statusBarAnimation;
}

#pragma mark -
#pragma mark Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (self.backgroundImageView)
        self.backgroundImageView.image = backgroundImage;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        return;
    }
    [self hideViewController:_contentViewController];
    _contentViewController = contentViewController;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
}

- (void)setLeftMenuViewController:(UIViewController *)leftMenuViewController
{
    if (!_leftMenuViewController) {
        _leftMenuViewController = leftMenuViewController;
        return;
    }
    [self hideViewController:_leftMenuViewController];
    _leftMenuViewController = leftMenuViewController;
    
    [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame = self.view.bounds;
    self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.leftMenuViewController.view];
    [self.leftMenuViewController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.contentViewContainer];
}


#pragma mark -
#pragma mark Pan gesture recognizer (Private)

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
   
    
    CGPoint point = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.originalPoint = CGPointMake(self.contentViewContainer.center.x - CGRectGetWidth(self.contentViewContainer.bounds) / 2.0,
                                         self.contentViewContainer.center.y - CGRectGetHeight(self.contentViewContainer.bounds) / 2.0);
        self.menuViewContainer.transform = CGAffineTransformIdentity;
      
        self.menuViewContainer.frame = self.view.bounds;
        [self addContentButton];
        [self.view.window endEditing:YES];
        self.didNotifyDelegate = NO;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat delta = 0;
        if (self.visible) {
            delta = self.originalPoint.x != 0 ? (point.x + self.originalPoint.x) / self.originalPoint.x : 0;
        } else {
            delta = point.x / self.view.frame.size.width;
        }
        delta = MIN(fabs(delta), 1.6);
        
        CGFloat contentViewScale = 1;
        
        CGFloat backgroundViewScale = 1.7f - (0.7f * delta);
        CGFloat menuViewScale = 1.5f - (0.5f * delta);
        
        if (!self.bouncesHorizontally) {
            contentViewScale = 1.0;
            backgroundViewScale = MAX(backgroundViewScale, 1.0);
            menuViewScale = MAX(menuViewScale, 1.0);
        }
        
        self.menuViewContainer.alpha = !self.fadeMenuView ?: delta;
        self.contentViewContainer.alpha = 1;
        
    
        if (!self.bouncesHorizontally && self.visible) {
            if (self.contentViewContainer.frame.origin.x > self.contentViewContainer.frame.size.width / 2.0)
                point.x = MIN(0.0, point.x);
            
            if (self.contentViewContainer.frame.origin.x < -(self.contentViewContainer.frame.size.width / 2.0))
                point.x = MAX(0.0, point.x);
        }
        
        // Limit size
        //
        if (point.x < 0) {
            point.x = MAX(point.x, -[UIScreen mainScreen].bounds.size.height);
        } else {
            point.x = MIN(point.x, [UIScreen mainScreen].bounds.size.height);
        }
        [recognizer setTranslation:point inView:self.view];
        
        if (!self.didNotifyDelegate) {
            if (point.x > 0&&!self.visible) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RBSideMenuWillShowMenuViewController object:nil];
                if ([self.delegate conformsToProtocol:@protocol(RBSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    [self.delegate sideMenu:self willShowMenuViewController:self.leftMenuViewController];
                }
            }
            self.didNotifyDelegate = YES;
        }
        
        
        self.contentViewContainer.transform = CGAffineTransformMakeScale(contentViewScale, contentViewScale);
        self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, point.x, 0);
    
        
        self.leftMenuViewController.view.hidden = self.contentViewContainer.frame.origin.x < 0;
    
//        if (!self.leftMenuViewController && self.contentViewContainer.frame.origin.x > 0) {
//            self.contentViewContainer.transform = CGAffineTransformIdentity;
//            self.contentViewContainer.frame = self.view.bounds;
//            self.visible = NO;
//            self.leftMenuVisible = NO;
//        }
        if (self.contentViewContainer.frame.origin.x < 0) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
          
        }
        
        
        [self statusBarNeedsAppearanceUpdate];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.didNotifyDelegate = NO;
        if (self.panMinimumOpenThreshold > 0 && (
                                                 (self.contentViewContainer.frame.origin.x < 0 && self.contentViewContainer.frame.origin.x > -((NSInteger)self.panMinimumOpenThreshold)) ||
                                                 (self.contentViewContainer.frame.origin.x > 0 && self.contentViewContainer.frame.origin.x < self.panMinimumOpenThreshold))
            ) {
            [self hideMenuViewController];
        }
        else if (self.contentViewContainer.frame.origin.x == 0) {
            [self hideMenuViewControllerAnimated:NO];
        }
        else {
            if ([recognizer velocityInView:self.view].x > 0) {
                if (self.contentViewContainer.frame.origin.x < 0) {
                    [self hideMenuViewController];
                } else {
                    if (self.leftMenuViewController) {
                        [self showLeftMenuViewController];
                    }
                }
            } else {
                   [self hideMenuViewController];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if (self.interactivePopGestureRecognizerEnabled && [self.contentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
        if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
            return NO;
        }
    }
    if (self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.x < 20.0 || point.x > self.view.frame.size.width - 20.0) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}


@end
