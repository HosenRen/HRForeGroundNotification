//
//  HRForeGroundNotification.h
//  HRForeGroundNotification
//
//  Created by 任豪 on 16/5/5.
//  Copyright © 2016年 任豪. All rights reserved.
//

#import<UIKit/UIKit.h>
#define STATUS_BAR_ANIMATION_LENGTH 0.25f
#define FONT_SIZE 12.0f
#define PADDING 10.0f
#define SCROLL_SPEED 40.0f
#define SCROLL_DELAY 1.0f
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
@interface HRForeGroundNotification : NSObject

typedef NS_ENUM(NSInteger, HRNotificationStyle) {
    HRNotificationStyleStatusBarNotification,
    HRNotificationStyleNavigationBarNotification
};

typedef NS_ENUM(NSInteger, HRNotificationAnimationStyle) {
    HRNotificationAnimationStyleTop,
    HRNotificationAnimationStyleBottom,
    HRNotificationAnimationStyleLeft,
    HRNotificationAnimationStyleRight
};

typedef NS_ENUM(NSInteger, HRNotificationAnimationType) {
    HRNotificationAnimationTypeReplace,
    HRNotificationAnimationTypeOverlay
};

@property (strong, nonatomic) UIView *notificationLabel;
@property (assign, nonatomic) CGFloat notificationLabelHeight;
@property (assign, nonatomic) BOOL multiline;

@property (strong, nonatomic) UIView *statusBarView;

@property (nonatomic) HRNotificationAnimationStyle notificationStyle;
@property (nonatomic) HRNotificationAnimationStyle notificationAnimationInStyle;
@property (nonatomic) HRNotificationAnimationStyle notificationAnimationOutStyle;
@property (nonatomic) HRNotificationAnimationType notificationAnimationType;
@property (nonatomic) BOOL notificationIsShowing;

@property (strong, nonatomic) UIWindow *notificationWindow;

- (void)displayNotificationWithTitle:(NSString *)title message:(NSString *)message forDuration:(CGFloat)duration shake:(BOOL)shake alertSound:(BOOL) alert;
- (void)displayNotificationWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(void))completion;
- (void)dismissNotification;

@end
