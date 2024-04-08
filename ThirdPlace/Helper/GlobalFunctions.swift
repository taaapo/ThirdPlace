//
//  GlobalFunctions.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/20.
//

import Foundation
import Firebase

//MARK: - Like
func saveLikeToUser(userId: String) {
    
    let like = LikeObject(id: UUID().uuidString, userId: FUser.currentId(), likedUserId: userId, date: Date())
    like.saveToFireStore()
    
    print(userId, "is userId")
    if let currentUser = FUser.currentUser() {
        
        if !didLikeUserWith(userId: userId) {
            
            currentUser.likedIdArray!.append(userId)
            
            currentUser.updateCurrentUserInFireStore(withValues: [kLIKEDIDARRAY: currentUser.likedIdArray!]) { (error) in
                
                print("updated current user with error ", error?.localizedDescription)
            }
        }
    }
}

func didLikeUserWith(userId: String) -> Bool {
    
    return FUser.currentUser()?.likedIdArray?.contains(userId) ?? false
}

//MARK: - Do Next
func saveNextToUser(userId: String) {
    
    let next = NextObject(id: UUID().uuidString, userId: FUser.currentId(), nextedUserId: userId, date: Date())
    next.saveToFireStore()
    
    print(userId, "is userId")
    if let currentUser = FUser.currentUser() {
        
        if !didNextUserWith(userId: userId) {
            
            currentUser.nextedIdArray!.append(userId)
            
            currentUser.updateCurrentUserInFireStore(withValues: [kNEXTEDIDARRAY: currentUser.nextedIdArray!]) { (error) in
                
                print("updated current user with error ", error?.localizedDescription)
            }
        }
    }
}

func didNextUserWith(userId: String) -> Bool {
    
    return FUser.currentUser()?.nextedIdArray?.contains(userId) ?? false
}

//MARK: - Starting chat
func startChat(user1: FUser, user2: FUser) -> String {
    
    let chatRoomId = chatRoomIdFrom(user1Id: user1.objectId, user2Id: user2.objectId)
    
//    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    createChatItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    return chatRoomId
}

func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    
    var chatRoomId = ""
    
    let value = user1Id.compare(user2Id).rawValue
    
    chatRoomId = value < 0 ? user1Id + user2Id : user2Id + user1Id
    
    return chatRoomId
}

func restartChat(chatRoomId: String, memberIds: [String]) {
    
    FirebaseListener.shared.downloadUsersFromFirebase(withIds: memberIds) { users in
        
        if users.count > 0 {
            createChatItems(chatRoomId: chatRoomId, users: users)
        }
    }
}

//MARK: - Chat
func createChatItems(chatRoomId: String, users: [FUser]) {
    
    var memberIdsToCreateChat: [String] = []
    
    for user in users {
        memberIdsToCreateChat.append(user.objectId)
    }
        
        FirebaseReference(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                memberIdsToCreateChat = removeMemberWhoHasChat(snapshot: snapshot, memberIds: memberIdsToCreateChat)
            }
            
            for userId in memberIdsToCreateChat {
                
                let senderUser = userId == FUser.currentId() ? FUser.currentUser()! : getReceiverFrom(users: users)
                
                let receiverUser = userId == FUser.currentId() ? getReceiverFrom(users: users) : FUser.currentUser()!
                
                let chatObject = Chat()
                
                chatObject.objectId = UUID().uuidString
                chatObject.chatRoomId = chatRoomId
                chatObject.senderId = senderUser.objectId
                chatObject.senderName = senderUser.username
                chatObject.receiverId = receiverUser.objectId
                chatObject.receiverName = receiverUser.username
                chatObject.date = Date()
                chatObject.memberIds = [senderUser.objectId, receiverUser.objectId]
                chatObject.lastMessage = ""
                chatObject.unreadCounter = 0
                chatObject.avatarLink = receiverUser.avatarLink
                chatObject.saveChatToFireStore()
            }
        }
}

func removeMemberWhoHasChat(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    
    var memberIdsToCreateRecent = memberIds
    
    for chatData in snapshot.documents {
        
        let currentChat = chatData.data() as Dictionary
        
        if let currentUserId = currentChat[kSENDERID] {
            
            if memberIdsToCreateRecent.contains(currentUserId as! String) {
                let index = memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!
                memberIdsToCreateRecent.remove(at: index)
            }
        }
    }
    return memberIdsToCreateRecent
}

func getReceiverFrom(users: [FUser]) -> FUser {
    
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: FUser.currentUser()!)!)
    
    return allUsers.first!
}
