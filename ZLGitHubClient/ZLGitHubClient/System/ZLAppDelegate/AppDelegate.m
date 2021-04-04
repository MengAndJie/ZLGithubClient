//
//  AppDelegate.m
//  ZLGitHubClient
//
//  Created by zhumeng on 2018/12/27.
//  Copyright © 2018年 ZM. All rights reserved.
//

#import "AppDelegate.h"
#import "ZLGithubAPI.h"
#import "ZLBuglyManager.h"
#import "ZLSharedDataManager.h"

#import <JJException/JJException.h>
#ifdef DEBUG
#import <DoraemonKit/DoraemonManager.h>
#endif

#import <Analytics/SEGAnalytics.h>
#import <UserNotifications/UserNotifications.h>
#import <SYDCentralPivot/SYDCentralPivotCoreHeader.h>
#import <Firebase/Firebase.h>



@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

#pragma mark - UIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setUpJJException];
    
    [self setUpDoraemonKit];
    
   // [self registerPush];
    /**
     *
     *  初始化中间件
     **/
    /**
     *
     * 初始化工具模块
     **/
    [[ZLServiceManager sharedInstance] initManager];
    

    
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"SYDCenteralFactoryConfig" ofType:@"plist"];
    [[SYDCentralRouter sharedInstance] addConfigWithFilePath:configFilePath withBundle:[NSBundle mainBundle]];;
    
   
    [self setUpBugly];
    
    
    ZLLog_Info(@"中间件，工具模块初始化完毕");
    
    /**
     *
     *  添加监听
     **/
    
    [self addObserver];
    
    
    [self initUIConfig];
    
      /**
       *
       *  初始化window
       **/
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = [ZLSharedDataManager sharedInstance].currentUserInterfaceStyle;
    }
    [self.window setBackgroundColor:[UIColor colorNamed:@"ZLVCBackColor"]];
    [self.window makeKeyAndVisible];
    
    
    if([[ZLSharedDataManager sharedInstance] githubAccessToken].length == 0){
        // token为空，切到登陆界面
        [self switchToLoginController:NO];
    }
    else{
        // token不为空，跳到主界面
        [self switchToMainController:NO];
    }
    
     
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self removeObserver];
}


#pragma mark -

// 处理URL
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    [[ZLToolManager sharedInstance].zlurlNotifcaitonModule addURLFromOtherAppOrWidgetWithUrl:url];
    return YES;
}



#pragma mark - supported Interface Orientations

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (_allowRotation) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}


#pragma mark -

- (void) initUIConfig{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    if([ZLDeviceInfo isIpad]){
        self.allowRotation = YES;    // iPad 允许旋转
    }
    
    [ZLBaseUIConfig sharedInstance].navigationBarTitleColor = [UIColor colorNamed:@"ZLNavigationBarTitleColor"];
    [ZLBaseUIConfig sharedInstance].navigationBarBackgoundColor = [UIColor colorNamed:@"ZLNavigationBarBackColor"];
    
    [ZLBaseUIConfig sharedInstance].viewControllerBackgoundColor = [UIColor colorNamed:@"ZLVCBackColor"];
    
    [ZLBaseUIConfig sharedInstance].buttonTitleColor = [UIColor colorNamed:@"ZLBaseButtonTitleColor"];
    [ZLBaseUIConfig sharedInstance].buttonBorderWidth = 1 / ZLScreenScale;
    [ZLBaseUIConfig sharedInstance].buttonBackColor = [UIColor colorNamed:@"ZLBaseButtonBackColor"];
    [ZLBaseUIConfig sharedInstance].buttonBorderColor = [UIColor colorNamed:@"ZLBaseButtonBorderColor"];
    [ZLBaseUIConfig sharedInstance].buttonCornerRadius = 4.0;
    
    
}

- (void) switchToMainController:(BOOL) animated{
    void(^block)(void) = ^{
        UIViewController * rootViewController = [ZLUIRouter getMainViewController];
        [self.window setRootViewController:rootViewController];
    };
    
    if(animated){
        [UIView transitionWithView:self.window
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:block
                        completion:^(BOOL finished) {}];
    }else{
        block();
    }
}

- (void) switchToLoginController:(BOOL) animated{
    void(^block)(void) = ^{
        UIViewController * rootViewController = [[ZLLoginViewController alloc] init];
        [self.window setRootViewController:rootViewController];
    };
    
    if(animated){
        [UIView transitionWithView:self.window
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:block
                        completion:^(BOOL finished) {}];
    }else{
        block();
    }
}


#pragma mark -

- (void) addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGithubTokenInvalid) name:ZLGithubTokenInvalid_Notification object:nil];
}

- (void) removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZLGithubTokenInvalid_Notification object:nil];
}


#pragma mark -

- (void) onGithubTokenInvalid{
    if(![self.window.rootViewController isKindOfClass:[ZLLoginViewController class]]){
        [ZLToastView showMessage:@"Token is not valid,login please"];
        [self switchToLoginController:YES];
    }
}

#pragma mark - DoraemonKit

- (void) setUpDoraemonKit
{
    #ifdef DEBUG
           //默认
           [[DoraemonManager shareInstance] install];
           // 或者使用传入位置,解决遮挡关键区域,减少频繁移动
           [[DoraemonManager shareInstance] installWithStartingPosition:CGPointMake(66, 66)];
    
       #endif
}

#pragma mark - Bugly
- (void) setUpBugly
{
    [[ZLBuglyManager sharedManager] setUp];
    
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"JG7bUGHXiZnkWAJkYG9CCcyiUiLfo9iB"];

    // Enable this to record certain application events automatically!
    configuration.trackApplicationLifecycleEvents = YES;

    // Enable this to record screen views automatically!
    configuration.recordScreenViews = YES;

    [SEGAnalytics setupWithConfiguration:configuration];
    
    [FIRApp configure];
    
}

#pragma mark - JJException
- (void) setUpJJException
{
#ifndef DEBUG
    [JJException configExceptionCategory:JJExceptionGuardAll];
    [JJException startGuardException];
#endif
}


#pragma mark -

#pragma mark - Notification Push

//- (void)registerPush {
//    // Push组件基本功能配置
//
//   // [[UIApplication sharedApplication] registerForRemoteNotifications];
//
//    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
//    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if(granted)
//        {
//
//        }
//    }];
//}


//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
//
//    if (![deviceToken isKindOfClass:[NSData class]]) return;
//    const unsigned *tokenBytes = [deviceToken bytes];
//    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
//                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
//                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
//                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
//
//
//    NSLog(@"deviceToken: %@",hexToken);
//
//
//}
//
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//{
//   NSLog(@"register for remote notification failed :%@", error.localizedDescription);
//}


#pragma mark  UNUserNotificationCenterDelegate

////iOS10新增：处理前台收到通知的代理方法，在后台调用
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)) {
//    
//    /**
//     * 如果应用在前台，不显示通知
//     */
//    completionHandler(UNNotificationPresentationOptionNone);
//}
//
////iOS10新增：处理后台点击通知的代理方法
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
//    
//    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
//    {
//        // 如果点击的时远程推送
//    }
//    else
//    {
//        //应用处于后台时的本地推送接受
//    }
//    completionHandler();
//}
//
//// 后台静默推送/点击通知唤醒
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
// 
//}

 
@end
