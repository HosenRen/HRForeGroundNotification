//
//  HRForeGroundNotification.m
//  HRForeGroundNotification
//
//  Created by 任豪 on 16/5/5.
//  Copyright © 2016年 任豪. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "HRForeGroundNotification.h"



@implementation HRForeGroundNotification

@synthesize notificationLabel, notificationWindow;

@synthesize statusBarView;

@synthesize notificationStyle, notificationIsShowing;

- (HRForeGroundNotification *)init {
    self = [super init];
    if (self) {
        // set defaults

        self.notificationStyle = HRNotificationStyleNavigationBarNotification;
        self.notificationAnimationInStyle = HRNotificationAnimationStyleTop;
        self.notificationAnimationOutStyle = HRNotificationAnimationStyleTop;
        self.notificationAnimationType = HRNotificationAnimationTypeOverlay;
    }
    return self;
}

# pragma mark - dimensions

- (CGFloat)getStatusBarHeight {
    if (self.notificationLabelHeight > 0) {
        return self.notificationLabelHeight;
    }
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.width;
    }
    return statusBarHeight > 0 ? statusBarHeight : 20;
}

- (CGFloat)getStatusBarWidth {
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIScreen mainScreen].bounds.size.width;
    }
    return [UIScreen mainScreen].bounds.size.height;
}

- (CGRect)getNotificationLabelTopFrame {
    return CGRectMake(0, -1*[self getNotificationLabelHeight], [self getStatusBarWidth], [self getNotificationLabelHeight]);
}

- (CGRect)getNotificationLabelLeftFrame {
    return CGRectMake(-1*[self getStatusBarWidth], 0, [self getStatusBarWidth], [self getNotificationLabelHeight]);
}

- (CGRect)getNotificationLabelRightFrame {
    return CGRectMake([self getStatusBarWidth], 0, [self getStatusBarWidth], [self getNotificationLabelHeight]);
}

- (CGRect)getNotificationLabelBottomFrame {
    return CGRectMake(0, [self getNotificationLabelHeight], [self getStatusBarWidth], 0);
}

- (CGRect)getNotificationLabelFrame {
    return CGRectMake(0, 0, [self getStatusBarWidth], [self getNotificationLabelHeight]);
}

- (CGFloat)getNavigationBarHeight {
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ||
        UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 44.0f;
    }
    return 30.0f;
}

- (CGFloat)getNotificationLabelHeight {
    switch (self.notificationStyle) {
        case HRNotificationStyleStatusBarNotification:
            return [self getStatusBarHeight];
        case HRNotificationStyleNavigationBarNotification:
            return [self getStatusBarHeight] + [self getNavigationBarHeight];
        default:
            return [self getStatusBarHeight];
    }
}

# pragma mark - screen orientation change

- (void)screenOrientationChanged {
    self.notificationLabel.frame = [self getNotificationLabelFrame];
    self.statusBarView.hidden = YES;
}

# pragma mark - display helpers

- (void)createNotificationLabelWithTitle:(NSString *)title message:(NSString *)message
{
    self.notificationLabel = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 64)];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //  毛玻璃view 视图
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.frame=self.notificationLabel.frame;
    [self.notificationLabel addSubview:effectView];
    UILabel *notificationLabell=[[UILabel alloc]initWithFrame:CGRectMake(55, 12, SCREEN_WIDTH-60,60)];
    notificationLabell.numberOfLines = 2;
    notificationLabell.lineBreakMode=NSLineBreakByTruncatingTail;
    notificationLabell.text = message;
    notificationLabell.textAlignment = NSTextAlignmentLeft;
    notificationLabell.adjustsFontSizeToFitWidth = NO;
    notificationLabell.font = [UIFont systemFontOfSize:FONT_SIZE-1];
    //self.notificationLabel.backgroundColor = self.notificationLabelBackgroundColor;
    notificationLabell.textColor = [UIColor whiteColor];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(55, 10, SCREEN_WIDTH-70, 20)];
    titleLabel.numberOfLines = self.multiline ? 0 : 1;
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    //self.notificationLabel.backgroundColor = self.notificationLabelBackgroundColor;
    titleLabel.textColor = [UIColor whiteColor];
    UIImageView *iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 35, 35)];
    iconImageView.layer.masksToBounds=YES;
    iconImageView.layer.cornerRadius=5;
    iconImageView.image=[UIImage imageNamed:@"120.png"];
    [self.notificationLabel addSubview:iconImageView];
    [self.notificationLabel addSubview:notificationLabell];
    [self.notificationLabel addSubview:titleLabel];
    switch (self.notificationAnimationInStyle) {
        case HRNotificationAnimationStyleTop:
            self.notificationLabel.frame = [self getNotificationLabelTopFrame];
            break;
        case HRNotificationAnimationStyleBottom:
            self.notificationLabel.frame = [self getNotificationLabelBottomFrame];
            break;
        case HRNotificationAnimationStyleLeft:
            self.notificationLabel.frame = [self getNotificationLabelLeftFrame];
            break;
        case HRNotificationAnimationStyleRight:
            self.notificationLabel.frame = [self getNotificationLabelRightFrame];
            break;
            
    }
}

- (void)createNotificationWindow
{
    self.notificationWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.notificationWindow.backgroundColor = [UIColor clearColor];
    self.notificationWindow.userInteractionEnabled = NO;
    self.notificationWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.notificationWindow.windowLevel = UIWindowLevelStatusBar;
    self.notificationWindow.rootViewController = [UIViewController new];
    self.notificationWindow.rootViewController.view.bounds = [self getNotificationLabelFrame];
}

- (void)createStatusBarView
{
    self.statusBarView = [[UIView alloc] initWithFrame:[self getNotificationLabelFrame]];
    self.statusBarView.clipsToBounds = YES;
    if (self.notificationAnimationType == HRNotificationAnimationTypeReplace) {
        UIView *statusBarImageView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
        [self.statusBarView addSubview:statusBarImageView];
    }
    [self.notificationWindow.rootViewController.view addSubview:self.statusBarView];
    [self.notificationWindow.rootViewController.view sendSubviewToBack:self.statusBarView];
}

# pragma mark - frame changing

- (void)firstFrameChange
{
    self.notificationLabel.frame = [self getNotificationLabelFrame];
    switch (self.notificationAnimationInStyle) {
        case HRNotificationAnimationStyleTop:
            self.statusBarView.frame = [self getNotificationLabelBottomFrame];
            break;
        case HRNotificationAnimationStyleBottom:
            self.statusBarView.frame = [self getNotificationLabelTopFrame];
            break;
        case HRNotificationAnimationStyleLeft:
            self.statusBarView.frame = [self getNotificationLabelRightFrame];
            break;
        case HRNotificationAnimationStyleRight:
            self.statusBarView.frame = [self getNotificationLabelLeftFrame];
            break;
    }
}

- (void)secondFrameChange
{
    switch (self.notificationAnimationOutStyle) {
        case HRNotificationAnimationStyleTop:
            self.statusBarView.frame = [self getNotificationLabelBottomFrame];
            break;
        case HRNotificationAnimationStyleBottom:
            self.statusBarView.frame = [self getNotificationLabelTopFrame];
            self.notificationLabel.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
            self.notificationLabel.center = CGPointMake(self.notificationLabel.center.x, [self getNotificationLabelHeight]);
            break;
        case HRNotificationAnimationStyleLeft:
            self.statusBarView.frame = [self getNotificationLabelRightFrame];
            break;
        case HRNotificationAnimationStyleRight:
            self.statusBarView.frame = [self getNotificationLabelLeftFrame];
            break;
    }
}

- (void)thirdFrameChange
{
    self.statusBarView.frame = [self getNotificationLabelFrame];
    switch (self.notificationAnimationOutStyle) {
        case HRNotificationAnimationStyleTop:
            self.notificationLabel.frame = [self getNotificationLabelTopFrame];
            break;
        case HRNotificationAnimationStyleBottom:
            self.notificationLabel.transform = CGAffineTransformMakeScale(1.0f, 0.0f);
            break;
        case HRNotificationAnimationStyleLeft:
            self.notificationLabel.frame = [self getNotificationLabelLeftFrame];
            break;
        case HRNotificationAnimationStyleRight:
            self.notificationLabel.frame = [self getNotificationLabelRightFrame];
            break;
    }
}

# pragma mark - display notification

- (void)displayNotificationWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(void))completion
{
    if (!self.notificationIsShowing) {
        self.notificationIsShowing = YES;
        
        // create UIWindow
        [self createNotificationWindow];
        
        // create UILabel
        [self createNotificationLabelWithTitle:title message:message];
        
        // create status bar view
        [self createStatusBarView];
        
        // add label to window
        [self.notificationWindow.rootViewController.view addSubview:self.notificationLabel];
        [self.notificationWindow.rootViewController.view bringSubviewToFront:self.notificationLabel];
        [self.notificationWindow setHidden:NO];
        
        // checking for screen orientation change
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        // animate
        [UIView animateWithDuration:STATUS_BAR_ANIMATION_LENGTH animations:^{
            [self firstFrameChange];
        } completion:^(BOOL finished) {
            double delayInSeconds = 0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [completion invoke];
            });
        }];
    }
    
}

- (void)dismissNotification
{
    if (self.notificationIsShowing) {
        [self secondFrameChange];
        [UIView animateWithDuration:STATUS_BAR_ANIMATION_LENGTH animations:^{
            [self thirdFrameChange];
        } completion:^(BOOL finished) {
            [self.notificationLabel removeFromSuperview];
            [self.statusBarView removeFromSuperview];
            self.notificationWindow = nil;
            self.notificationIsShowing = NO;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        }];
    }
}

- (void)displayNotificationWithTitle:(NSString *)title message:(NSString *)message forDuration:(CGFloat)duration shake:(BOOL)shake alertSound:(BOOL) alert
{
    if(shake){  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);}
    if(alert){AudioServicesPlaySystemSound(1007);}
    [self displayNotificationWithTitle:title message:message completion:^{
        double delayInSeconds = duration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissNotification];
        });
    }];
}
@end