//
//  AppDelegate.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/06.
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //AdMobの設定
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //リリースの際は下記をコメントアウト
        //デバッグトークンの検索方法は以下URL参照
        //https://github.com/firebase/firebase-ios-sdk/issues/9547#issuecomment-1097424478
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        //初回起動時、プッシュ通知の許可ダイアログを表示させる。表示タイミングに関してはもう少し考慮が必要
        //https://qiita.com/rockname/items/4a092e39e571ddd19c5b
        requestPushNotificationPermission()
        
        setupConfigurations()
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    //MARK: - UIConfiguration
    private func setupConfigurations() {
        
        UITabBar.appearance().shadowImage = UIImage()
        //UITabBar.appearance().backgroundImage = UIImage(named: "プロフィール画面背景")
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().tintColor = UIColor().primaryGray()
        //UITabBar.appearance().tintColor = UIColor(red: 253/255, green: 87/255, blue: 86/255, alpha: 1)
        
        UITabBar.appearance().scrollEdgeAppearance?.shadowImage = UIImage()
        //UITabBar.appearance().scrollEdgeAppearance?.backgroundImage = UIImage(named: "プロフィール画面背景")
        UITabBar.appearance().scrollEdgeAppearance?.backgroundColor = UIColor.clear
    }
    
    //MARK: - Push notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("unable to register for remote notifications", error.localizedDescription)
    }
    
    private func requestPushNotificationPermission() {
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
    }
    
    private func updateUserPushId(newPushId: String) {
        
        if let user = FUser.currentUser() {
            user.pushId = newPushId
            user.saveUserLocally()
            user.updateCurrentUserInFireStore(withValues: [kPUSHID : newPushId]) { (error) in
                print("updated user push id with error ", error?.localizedDescription)
            }
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("user push id is ", fcmToken)
        updateUserPushId(newPushId: fcmToken ?? "")
    }
    
}
