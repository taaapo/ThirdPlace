//
//  SceneDelegate.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/06.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    var isLogin: Bool = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let windowScene = scene as? UIWindowScene {
                
                self.authListener = Auth.auth().addStateDidChangeListener({ auth, user in
                    
                    Auth.auth().removeStateDidChangeListener(self.authListener!)
                    
                    if user != nil && userDefaults.object(forKey: kCURRENTUSER) != nil {
                        
                        let window = UIWindow(windowScene: windowScene)
                        window.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
                        self.window = window
                        window.makeKeyAndVisible()
                        
                    } else {
                        
                        let window = UIWindow(windowScene: windowScene)
                        window.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                        
                        self.window = window
                        window.makeKeyAndVisible()
                    }
                })
        }
        
        
        
//        goToInitialViewController()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    //MARK: - Go to Initial View Controller
    
    
    func checkIsLogin() {
        
        authListener = Auth.auth().addStateDidChangeListener({ auth, user in
            
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil && userDefaults.object(forKey: kCURRENTUSER) != nil {
                print("isLogin is true")
                self.isLogin = true
                
            }
        })
    }
        
    
    
    func goToInitialViewController() {
        
        authListener = Auth.auth().addStateDidChangeListener({ auth, user in
            
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil && userDefaults.object(forKey: kCURRENTUSER) != nil {
                print("MainView")
                
                DispatchQueue.main.async {
                    self.goToMainView()
                }
            } else {
                print("LoginView")
                
                DispatchQueue.main.sync {
                    self.goToLoginView()
                }
            }
        })
    }
    
    private func goToMainView() {
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        self.window?.rootViewController = mainView
    }
    
    private func goToLoginView() {
        
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        
        self.window?.rootViewController = loginView
    }

}

