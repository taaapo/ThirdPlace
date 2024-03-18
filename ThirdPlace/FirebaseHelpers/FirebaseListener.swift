//
//  FirebaseListener.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/16.
//

import Foundation
import Firebase

class FirebaseListener {
    
    //1つしか初期化できないようにする＝このクラスを呼ぶときはstaticな変数sharedから呼ぶため、必然的に1つしかインスタンスを作れない
    static let shared = FirebaseListener()
    
    private init() {}
    
     //MARK: - FUser
    func downloadCUrrentUserFromFirebase(userId: String, email: String) {
        
        FirebaseReference(.User).document(userId).getDocument { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                let user = FUser(_dictionary: snapshot.data() as! NSDictionary)
                print("created user")
                user.saveUserLocaly()
                
                user.getUserAvatarFromFirestore { (didSet) in
                    
                }
                
            } else {
                //first login
                print("first login")
                if let user = userDefaults.object(forKey: kCURRENTUSER) {
                    FUser(_dictionary: user as! NSDictionary).saveUserToFireStore()
                }
                
            }
        }
    }
    
    
}
