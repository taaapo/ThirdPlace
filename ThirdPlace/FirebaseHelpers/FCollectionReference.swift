//
//  FCollectionReference.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/16.
//

import Foundation
import Firebase

enum FCollectionReference: String {
    case User
    case Like
    case Chat
    case Messages
    case Typing
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}
