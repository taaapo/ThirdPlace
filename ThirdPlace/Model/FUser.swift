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
    
    init (_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as? String ?? ""
        email = _dictionary[kEMAIL] as? String ?? ""
        username = _dictionary[kUSERNAME] as? String ?? ""
        personality = _dictionary[kPERSONALITY] as? String ?? ""
        worry = _dictionary[kWORRY] as? String ?? ""
        avatarLink = _dictionary[kAVATARLINK] as? String ?? ""
        aboutMe = _dictionary[kABOUTME] as? String ?? ""
        premium = _dictionary[kPREMIUM] as? Int ?? 0
    }
    
    //MARK: - Login
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            
            if error == nil {
                
                if authDataResult!.user.isEmailVerified {
                    
                    FirebaseListener.shared.downloadCUrrentUserFromFirebase(userId: authDataResult!.user.uid, email: email)
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
    
    //MARK: - Resend Links
    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
     
        //Auth.auth().currentUser?.reload(completion: { error in
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                
                completion(error)
            }
        //})
    }
    
    //パスワード忘れた際のメアドが登録されたものかどうかをチェックする関数が必要、もしくはメール列挙保護を無効にすれば大丈夫かも
    // After asking the user for their email.
//    class func checkExistFor(email: String) {
//        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
//            // This returns the same array as fetchProviders(forEmail:completion:) but for email
//            // provider identified by 'password' string, signInMethods would contain 2
//            // different strings:
//            // 'emailLink' if the user previously signed in with an email/link
//            // 'password' if the user has a password.
//            // A user could have both.
//            if (error) {
//                // Handle error case.
//            }
//            if (!signInMethods.contains(EmailPasswordAuthSignInMethod)) {
//                // User can sign in with email/password.
//            }
//            if (!signInMethods.contains(EmailLinkAuthSignInMethod)) {
//                // User can sign in with email/link.
//            }
//        }
//    }
    
    //MARK: - Save user funcs
    func saveUserlocaly() {
        
        userDefaults.setValue(self.userDictionary as! [String : Any], forKey: kCURRENTUSER)
        userDefaults.synchronize()
    }
    
    func saveUserToFireStore() {
        
        FirebaseReference(.User).document(self.objectId).setData(self.userDictionary as! [String : Any]) { error in
            
            if error != nil {
                print(error!.localizedDescription)
            }
        }
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
            return "このアカウントは無効になっています。"
        case .operationNotAllowed:
            return "操作できません。"
        case .invalidEmail:
            return "メールアドレスの形式が違います。"
        case .invalidCredential:
            return "メールアドレスが登録されていません。もしくはパスワードが違います。"
        case .wrongPassword:
            return "パスワードが違います。"
        case .userNotFound:
            return "アカウントが見つかりません。"
        case .networkError:
            return "サーバーへ接続できません。"
        case .weakPassword:
            return "パスワードは6文字以上で入力してください。"
        case .missingEmail:
            return "メールアドレスの登録が必要です。"
//        case .internalError:
//            return "内部エラーが発生しています。"
        case .invalidCustomToken:
            return "無効なカスタムトークンです。"
//        case .tooManyRequests:
//            return "すでに多くのリクエストがサーバーに送信されています。"
        default:
            return "エラーが起きました。しばらくしてから再度お試しください。"
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
