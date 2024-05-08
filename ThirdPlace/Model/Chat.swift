//
//  Chat.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/22.
//

import Foundation
import UIKit
import Firebase

class Chat {
    
    var objectId = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
    var avatar: UIImage?
    
    var dictionary: NSDictionary {
        
        return NSDictionary(objects: [self.objectId,
                                      self.chatRoomId,
                                      self.senderId,
                                      self.senderName,
                                      self.receiverId,
                                      self.receiverName,
                                      self.date,
                                      self.memberIds,
                                      self.lastMessage,
                                      self.unreadCounter,
                                      self.avatarLink
        ],
                            forKeys: [kOBJECTID as NSCopying,
                                      kCHATROOMID as NSCopying,
                                      kSENDERID as NSCopying,
                                      kSENDERNAME as NSCopying,
                                      kRECEIVERID as NSCopying,
                                      kRECEIVERNAME as NSCopying,
                                      kDATE as NSCopying,
                                      kMEMBERIDS as NSCopying,
                                      kLASTMESSAGE as NSCopying,
                                      kUNREADCOUNTER as NSCopying,
                                      kAVATARLINK as NSCopying
                            ])
    }
    
    
    init() { }
    
    init(_ chatDocument: Dictionary<String, Any>) {
        
        objectId = chatDocument[kOBJECTID] as? String ?? ""
        chatRoomId = chatDocument[kCHATROOMID] as? String ?? ""
        senderId = chatDocument[kSENDERID] as? String ?? ""
        senderName = chatDocument[kSENDERNAME] as? String ?? ""
        receiverId = chatDocument[kRECEIVERID] as? String ?? ""
        receiverName = chatDocument[kRECEIVERNAME] as? String ?? ""
        date = (chatDocument[kDATE] as? Timestamp)?.dateValue() ?? Date()
        memberIds = chatDocument[kMEMBERIDS] as? [String] ?? [""]
        lastMessage = chatDocument[kLASTMESSAGE] as? String ?? ""
        unreadCounter = chatDocument[kUNREADCOUNTER] as? Int ?? 0
        avatarLink = chatDocument[kAVATARLINK] as? String ?? ""
        
    }
    
    //MARK: - Saving
    func saveChatToFireStore() {
        FirebaseReference(.Chat).document(self.objectId).setData(self.dictionary as! [String : Any])
    }
    
    func deleteChat() {
        FirebaseReference(.Chat).document(self.objectId).delete()
    }
}

