//
//  PushNotifications.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/05/01.
//

import Foundation

class PushNotificationService {
    
    static let shared = PushNotificationService()
    
    private init() { }
    
    
    func sendPushNotificationTo(userIds: [String], body: String) {
        
        print("sendPushNotificationTo")
        
        FirebaseListener.shared.downloadUsersFromFirebase(withIds: userIds) { (users) in
            
            for user in users {
                print("after download users, user.pushId is ", user.pushId, ", user is", user)
                if let pushId = user.pushId {
                    print("pushId = user.pushId")
                    self.sendMessageToUser(to: pushId, title: FUser.currentUser()!.username, body: body)
                }
            }
        }
    }
    
    private func sendMessageToUser(to token: String, title: String, body: String) {
        
        print("sendMessageToUser")
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        
        //下記のままではバッジを表示できないため、改良が必要
        let paramString : [String : Any] = ["to" : token,
                                            "notification" :
                                                ["title" : title,
                                                 "body" : body,
                                                 "budge" : "1",
                                                 "sound" : "default"
                                                ]
                                            ]
        
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(kSERVERKEY)", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            
        }

        task.resume()
    }
    
}
