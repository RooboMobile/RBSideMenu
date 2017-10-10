//
//  RBSideMenuController.h
//  Pods
//
//  Created by baxiang on 2017/10/3.
//

#import <UIKit/UIKit.h>

@class RBSideMenuController;

@interface UIViewController (RBSideMenuController)

@property (strong, readonly, nonatomic) RBSideMenuController *sideMenuViewController;

// IB Action Helper methods

- (IBAction)presentLeftMenuViewController:(id)sender;
- (IBAction)presentRightMenuViewController:(id)sender;
@end

@protocol RBSideMenuDelegate <NSObject>
@optional
- (void)sideMenu:(RBSideMenuController *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)sideMenu:(RBSideMenuController *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(RBSideMenuController *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(RBSideMenuController *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(RBSideMenuController *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController;

@end

@interface RBSideMenuController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, readwrite, nonatomic) UIViewController *contentViewController;
@property (strong, readwrite, nonatomic) UIViewController *leftMenuViewController;
@property (strong, readwrite, nonatomic) UIViewController *rightMenuViewController;
@property (weak, readwrite, nonatomic) id<RBSideMenuDelegate> delegate;


@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;//视差动画时长
@property (assign, readwrite, nonatomic)  BOOL interactivePopGestureRecognizerEnabled;//全屏Pop手势是否可用
@property (assign, readwrite, nonatomic) CGAffineTransform menuViewControllerTransformation;
@property (assign, readwrite, nonatomic)  BOOL scaleContentView;
@property (assign, readwrite, nonatomic)  BOOL scaleBackgroundImageView;
@property (assign, readwrite, nonatomic)  BOOL scaleMenuView;
@property (assign, readwrite, nonatomic)  BOOL fadeMenuView;
@property (assign, readwrite, nonatomic)  BOOL parallaxEnabled;
@property (assign, readwrite, nonatomic)  BOOL bouncesHorizontally;

@property (assign, readwrite, nonatomic)  CGFloat parallaxMenuMinimumRelativeValue;
@property (assign, readwrite, nonatomic)  CGFloat parallaxMenuMaximumRelativeValue;
@property (assign, readwrite, nonatomic)  CGFloat parallaxContentMinimumRelativeValue;
@property (assign, readwrite, nonatomic)  CGFloat parallaxContentMaximumRelativeValue;

@property (assign, readwrite, nonatomic) BOOL panGestureEnabled;
@property (assign, readwrite, nonatomic) BOOL panFromEdge;
@property (assign, readwrite, nonatomic) NSUInteger panMinimumOpenThreshold;

@property (assign, readwrite, nonatomic)  BOOL contentViewShadowEnabled;
@property (strong, readwrite, nonatomic)  UIColor *contentViewShadowColor;
@property (assign, readwrite, nonatomic)  CGSize contentViewShadowOffset;
@property (assign, readwrite, nonatomic)  CGFloat contentViewShadowOpacity;
@property (assign, readwrite, nonatomic)  CGFloat contentViewShadowRadius;
@property (assign, readwrite, nonatomic)  CGFloat contentViewFadeOutAlpha;
@property (assign, readwrite, nonatomic)  CGFloat contentViewScaleValue;
@property (assign, readwrite, nonatomic)  CGFloat contentViewInLandscapeOffsetCenterX;
@property (assign, readwrite, nonatomic)  CGFloat contentViewInPortraitOffsetCenterX;
@property (strong, readwrite, nonatomic) UIImage *backgroundImage;
@property (assign, readwrite, nonatomic) UIStatusBarStyle menuPreferredStatusBarStyle;
@property (assign, readwrite, nonatomic)  BOOL menuPrefersStatusBarHidden;


- (id)initWithContentViewController:(UIViewController *)contentViewController
             leftMenuViewController:(UIViewController *)leftMenuViewController
            rightMenuViewController:(UIViewController *)rightMenuViewController;
- (void)presentLeftMenuViewController;
- (void)presentRightMenuViewController;
- (void)hideMenuViewController;
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;
@end
