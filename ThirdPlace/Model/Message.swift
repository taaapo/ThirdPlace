//
//  Message.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/25.
//

import Foundation
import Firebase

class Message {
    
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var isIncoming = false
    var sentDate = Date()
    var message = ""
    var status = ""
    
    var dictionary: NSDictionary {
        
        return NSDictionary(objects: [self.id,
                                      self.chatRoomId,
                                      self.senderId,
                                      self.senderName,
                                      self.sentDate,
                                      self.message,
                                      self.status
        
        ],                   forKeys: [kOBJECTID as NSCopying,
                                       kCHATROOMID as NSCopying,
                                       kSENDERID as NSCopying,
                                       kSENDERNAME as NSCopying,
                                       kDATE as NSCopying,
                                       kMESSAGE as NSCopying,
                                       kSTATUS as NSCopying
        ])
    }
    
    
    init() { }
    
    init(dictionary: [String: Any]) {
        
        id = dictionary[kOBJECTID] as? String ?? ""
        chatRoomId = dictionary[kCHATROOMID] as? String ?? ""
        senderId = dictionary[kSENDERID] as? String ?? ""
        senderName = dictionary[kSENDERNAME] as? String ?? ""
        isIncoming = (dictionary[kSENDERID] as? String ?? "") != FUser.currentId()
        sentDate = (dictionary[kDATE] as? Timestamp)?.dateValue() ?? Date()
        message = dictionary[kMESSAGE] as? String ?? ""
        status = dictionary[kSTATUS] as? String ?? ""
    }
}


