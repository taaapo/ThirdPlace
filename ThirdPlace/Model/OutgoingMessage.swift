//
//  OutgoingMessage.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/27.
//

import Foundation
import UIKit

class OutgoingMessage {
    
    var messageDictionary: [String : Any]
    
    //MARK: - Initializers
    init(message: Message, text: String, memberIds: [String]) {
        
        message.message = text
        
        messageDictionary = message.dictionary as! [String : Any]
    }
    
    class func send(chatId: String, text: String, memberIds: [String]) {
        
        let currentUser = FUser.currentUser()!
        
        let message = Message()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.objectId
        message.senderName = currentUser.username
        
        message.sentDate = Date()
        message.status = kSENT
        message.message = text

        
        if text != nil {
            let outgoingMessage = OutgoingMessage(message: message, text: text, memberIds: memberIds)
            outgoingMessage.sendMessage(chatRoomId: chatId, messageId: message.id, memberIds: memberIds)
        }
        
        print("Just before pushNotificationService")
        PushNotificationService.shared.sendPushNotificationTo(userIds: removeCurrentUserIdFrom(userIds: memberIds), body: message.message)
        
        FirebaseListener.shared.updateChats(chatRoomId: chatId, lastMessage: message.message)
    }
    
    
    func sendMessage(chatRoomId: String, messageId: String, memberIds: [String]) {
        
        for userId in memberIds {
            
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(messageId).setData(messageDictionary)
        }
    }

    
    class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {
        
        let values = [kSTATUS : kREAD] as [String : Any]
        
        for userId in memberIds {
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(withId).updateData(values)
        }
        
    }
}

