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
    func downloadCurrentUserFromFirebase(userId: String, email: String) {
        
        FirebaseReference(.User).document(userId).getDocument { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                let user = FUser(_dictionary: snapshot.data() as! NSDictionary)
                print("created user")
                user.saveUserLocally()
                
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
    
    func downloadUsersFromFirebase(isInitialLoad: Bool, limit: Int, lastDocumentSnapshot: DocumentSnapshot?, completion: @escaping (_ users: [FUser], _ snapshot: DocumentSnapshot?) -> Void) {
        
        var query: Query!
        var users: [FUser] = []
        
        if isInitialLoad {
            //ToDo: 下記のorderを最新のログイン順等にしたい
            query = FirebaseReference(.User).order(by: kREGISTEREDDATE, descending: false).limit(to: limit)
            print("first \(limit) users loading")
            
        } else {
            
            if lastDocumentSnapshot != nil {
                
                //ToDo: 下記のorderを最新のログイン順等にしたい
                query = FirebaseReference(.User).order(by: kREGISTEREDDATE, descending: false).limit(to: limit).start(atDocument: lastDocumentSnapshot!)
                print("next \(limit) user loading")
                
            } else {
                print("last snapshot is nil")
            }
        }
        
        if query != nil {
            
            query.getDocuments { snapShot, error in
                
                guard let snapshot = snapShot else { return }
                
                if !snapshot.isEmpty {
                    print("snapshot.documents is ", snapshot.documents.count)
                    for userData in snapshot.documents {
                        
                        let userObject = userData.data() as NSDictionary
                        
                        print("likedIdArray: ", FUser.currentUser()?.likedIdArray?.contains(userObject[kOBJECTID] as! String))
                        print("nextedIdArray: ", FUser.currentUser()?.nextedIdArray?.contains(userObject[kOBJECTID] as! String))
                        print("userObject is currentUser: ", FUser.currentId() != userObject[kOBJECTID] as! String)
                        
                        if !(FUser.currentUser()?.likedIdArray?.contains(userObject[kOBJECTID] as! String) ?? false)
                            && !(FUser.currentUser()?.nextedIdArray?.contains(userObject[kOBJECTID] as! String) ?? false)
                            && (FUser.currentId() != userObject[kOBJECTID] as! String) {
                            
                            print("line 84")
                            users.append(FUser(_dictionary: userObject))
                        }
                        
                        //上記を加える場合、下記はコメントアウト
//                        users.append(FUser(_dictionary: userObject))
                    }
                    
                    completion(users, snapshot.documents.last!)
                    
                } else {
                    print("no more users to fetch")
                    completion(users, nil)
                }
                
            }
        } else {
            completion(users, nil)
        }
    }
    
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ users: [FUser]) -> Void) {
        
        var usersArray: [FUser] = []
        var counter = 0
        
        for userId in withIds {
            
            
            FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    
                    usersArray.append(FUser(_dictionary: snapshot.data()! as NSDictionary))
                    counter += 1
                    
                    if counter == withIds.count {
                        
                        completion(usersArray)
                    }
                    
                } else {
                    completion(usersArray)
                }
            }
        }
    }
    
    //MARK: - Likes
    func downloadUserLikes(completion: @escaping (_ likedUserIds: [String]) -> Void) {
        
        FirebaseReference(.Like).whereField(kUSERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in
            
            var allLikedIds: [String] = []
            
            guard let snapshot = snapshot else {
                completion(allLikedIds)
                return
            }
            
            if !snapshot.isEmpty {
                
                for likeDictionary in snapshot.documents {
                    
                    allLikedIds.append(likeDictionary[kLIKEDUSERID] as? String ?? "")
                }
                
                completion(allLikedIds)
            } else {
                print("No likes found")
                completion(allLikedIds)
            }
        }
    }

    
    //MARK: - Chats
    func downloadChatsFromFireStore(completion: @escaping (_ allChats: [Chat]) -> Void) {
        
        FirebaseReference(.Chat).whereField(kSENDERID, isEqualTo: FUser.currentId()).addSnapshotListener { (querySnapshot, error) in
            
            var chats: [Chat] = []
            
            guard let snapshot = querySnapshot else { return }
            
            if !snapshot.isEmpty {
                
                for chatDocument in snapshot.documents {
                    
                    if chatDocument[kLASTMESSAGE] as! String != "" && chatDocument[kCHATROOMID] != nil && chatDocument[kOBJECTID] != nil {
                        
                        chats.append(Chat(chatDocument.data()))
                    }
                }
                
                chats.sort(by: { $0.date > $1.date })
                completion(chats)
                
            } else {
                completion(chats)
            }
        }
    }
    
    func updateChats(chatRoomId: String, lastMessage: String) {
        
        FirebaseReference(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for chat in snapshot.documents {
                    
                    let latestChat = Chat(chat.data())
                    
                    self.updateChatItem(latestChat: latestChat, lastMessage: lastMessage)
                }
            }
        }
    }
    
    private func updateChatItem(latestChat: Chat, lastMessage: String) {
        
        if latestChat.senderId != FUser.currentId() {
            latestChat.unreadCounter += 1
        }
        
        let values = [kLASTMESSAGE : lastMessage, kUNREADCOUNTER: latestChat.unreadCounter, kDATE : Date()] as [String: Any]
        
        
        FirebaseReference(.Chat).document(latestChat.objectId).updateData(values) { (error) in
            print("error updating recent ", error)
        }
    }
    
    func resetUnreadCounter(chatRoomId: String) {
        
        FirebaseReference(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                if let chatData = snapshot.documents.first?.data() {
                    let chat = Chat(chatData)
                    self.clearUnreadCounter(chat: chat)
                }
            }
        }
    }
    
    func clearUnreadCounter(chat: Chat) {
        
        let values = [kUNREADCOUNTER : 0] as [String : Any]
        
        FirebaseReference(.Chat).document(chat.objectId).updateData(values) { (error) in
            
            print("Reset recent counter", error)
        }
    }
    
}
