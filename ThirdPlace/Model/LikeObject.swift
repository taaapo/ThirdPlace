//
//  LikeObject.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/31.
//

import Foundation

struct LikeObject {
    
    let id: String
    let userId: String
    let likedUserId: String
    let date: Date
    
    var dictionary: [String : Any] {
        return [kOBJECTID : id, kUSERID : userId, kLIKEDUSERID : likedUserId, kDATE : date]
    }
    
    func saveToFireStore() {
        
        FirebaseReference(.Like).document(self.id).setData(self.dictionary)
    }
}
