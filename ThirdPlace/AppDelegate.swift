//
//  AppDelegate.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/06.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        setupConfigurations()
        
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
    
}

