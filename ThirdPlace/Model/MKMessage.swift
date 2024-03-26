//
//  MKMessage.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/26.
//

import Foundation
import MessageKit

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mksender: MKSender
    var sender: SenderType { return mksender }
    
    var status: String
    
    
    init(message: Message) {
        self.messageId = message.id
        self.mksender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        self.sentDate = message.sentDate
        self.incoming = FUser.currentId() != mksender.senderId
    }
    
}
