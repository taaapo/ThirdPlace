//
//  FUser.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/13.
//

import Foundation
import Firebase

class FUser: Equatable {
    
    static func == (lhs: FUser, rhs: FUser) -> Bool {
        lhs.objectId == rhs.objectId
    }
    
    let objectId: String
    var email: String
    var username: String
    var personality: String
    var worry: String
    var avatarLink: String
    var aboutMe: String
    
    var registeredDate = Date()
    var pushId: String?
    var premium = 0
    
    var userDictionary: NSDictionary {
        
        return NSDictionary(objects:
                                [self.objectId,
                                 self.email,
                                 self.username,
                                 self.personality,
                                 self.worry,
                                 self.avatarLink,
                                 self.aboutMe,
                                 self.registeredDate,
                                 self.pushId ?? "",
                                 self.premium],
                            forKeys:
                                [kOBJECTID as NSCopying,
                                 kEMAIL as NSCopying,
                                 kUSERNAME as NSCopying,
                                 kPERSONALITY as NSCopying,
                                 kWORRY as NSCopying,
                                 kAVATARLINK as NSCopying,
                                 kABOUTME as NSCopying,
                                 kREGISTEREDDATE as NSCopying,
                                 kPUSHID as NSCopying,
                                 kPREMIUM as NSCopying])
    }
    
    //MARK: - Inits
    init(_objectId: String, _email: String, _username: String, _personality: String, _worry: String, _avatarLink: String = "") {
        
        objectId = _objectId
        email = _email
        username = _username
        personality = _personality
        worry = _worry
        avatarLink = _avatarLink
        aboutMe = ""
        premium = 0
    }
    
    //MARK: - Login
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            
            if error == nil {
                
                if authDataResult!.user.isEmailVerified {
                    
                    //check if user exists in FB
                    completion(error, true)
                } else {
                    print("Email not verified")
                    completion(error, false)
                }
            }else {
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register
    class func registerUserWith(email: String, password: String, username: String, personality: String, worry: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authData, error in
            
            completion(error)
            
            if error == nil {
                
                authData!.user.sendEmailVerification { error in
                    print("auth email verification sent", error?.localizedDescription)
                }
                
                if authData?.user != nil {
                    
                    let user = FUser(_objectId: authData!.user.uid, _email: email, _username: username, _personality: personality, _worry: worry)
                    
                    user.saveUserlocaly()
                }
            }
        }
    }
    
    func saveUserlocaly() {
        
        userDefault.setValue(self.userDictionary as! [String : Any], forKey: kCURRENTUSER)
        userDefault.synchronize()
    }
    
}


//MARK: - Translate Error Code *Refer to the URL below
//https://stackoverflow.com/questions/48255312/firebase-authentication-error-in-other-languages
//AuthErrorCode List below
//https://firebase.google.com/docs/reference/admin/java/reference/com/google/firebase/auth/AuthErrorCode
extension AuthErrorCode.Code {
    var description: String? {
        switch self {
        case .emailAlreadyInUse:
            return "このメールアドレスはすでに使われています。"
        case .userDisabled:
            return "このアカウントは無効になっています"
        case .operationNotAllowed:
            return "操作できませんa"
        case .invalidEmail:
            return "メールアドレスの形式が違います"
        case .invalidCredential:
            return "メールアドレスが登録されていません\nもしくはパスワードが違います"
        case .wrongPassword:
            return "パスワードが違います"
        case .userNotFound:
            return "アカウントが見つかりません"
        case .networkError:
            return "サーバーへ接続できません"
        case .weakPassword:
            return "パスワードは6文字以上で入力してください"
        case .missingEmail:
            return "メールアドレスの登録が必要です"
//        case .internalError:
//            return "内部エラーが発生しています"
        case .invalidCustomToken:
            return "無効なカスタムトークンです"
//        case .tooManyRequests:
//            return "すでに多くのリクエストがサーバーに送信されています"
        default:
            return "エラーが起きました\nメールアドレス・パスワードを再度ご確認ください"
        }
    }
}

public extension Error {
    
    var localizedDescription: String {
        
        let error = self as NSError
        if error.domain == AuthErrorDomain {
            if let code = AuthErrorCode.Code(rawValue: error.code) {
                if let errorString = code.description {
                    return errorString
                }
            }
        }
        
        return error.localizedDescription
    }
}
