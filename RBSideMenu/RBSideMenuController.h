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

- (void)presentLeftMenuViewController;
@end

@protocol RBSideMenuDelegate <NSObject>
@optional

- (void)sideMenu:(RBSideMenuController *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(RBSideMenuController *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(RBSideMenuController *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(RBSideMenuController *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController;

@end

FOUNDATION_EXPORT NSString * const RBSideMenuWillShowMenuViewController;
FOUNDATION_EXPORT NSString * const RBSideMenuDidShowMenuViewController;
FOUNDATION_EXPORT NSString * const RBSideMenuWillHideMenuViewController;
FOUNDATION_EXPORT NSString * const RBSideMenuDidHideMenuViewController;


@interface RBSideMenuController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, readwrite, nonatomic) UIViewController *contentViewController;
@property (strong, readwrite, nonatomic) UIViewController *leftMenuViewController;
@property (weak, readwrite, nonatomic) id<RBSideMenuDelegate> delegate;


@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;//视差动画时长
@property (assign, readwrite, nonatomic)  BOOL interactivePopGestureRecognizerEnabled;//全屏Pop手势是否可用
@property (assign, readwrite, nonatomic)  BOOL fadeMenuView;
@property (assign, readwrite, nonatomic)  BOOL bouncesHorizontally;

@property (assign, readwrite, nonatomic)  CGFloat parallaxMenuMinimumRelativeValue;
@property (assign, readwrite, nonatomic)  CGFloat parallaxMenuMaximumRelativeValue;
@property (assign, readwrite, nonatomic)  CGFloat parallaxContentMinimumRelativeValue;
@property (assign, readwrite, nonatomic)  CGFloat parallaxContentMaximumRelativeValue;

@property (assign, readwrite, nonatomic) BOOL panFromEdge;
@property (assign, readwrite, nonatomic) NSUInteger panMinimumOpenThreshold;

@property (assign, readwrite, nonatomic)  CGFloat contentViewInLandscapeOffsetCenterX;
@property (assign, readwrite, nonatomic)  CGFloat contentViewInPortraitOffsetCenterX;
@property (strong, readwrite, nonatomic) UIImage *backgroundImage;
@property (assign, readwrite, nonatomic) UIStatusBarStyle menuPreferredStatusBarStyle;
@property (assign, readwrite, nonatomic)  BOOL menuPrefersStatusBarHidden;


- (id)initWithContentViewController:(UIViewController *)contentViewController
             leftMenuViewController:(UIViewController *)leftMenuViewController;
- (void)presentLeftMenuViewController;
- (void)hideMenuViewController;
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;
@end
