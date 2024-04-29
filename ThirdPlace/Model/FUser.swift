//
//  FUser.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/13.
//

import Foundation
import Firebase
import UIKit

class FUser: Equatable {
    
    static func == (lhs: FUser, rhs: FUser) -> Bool {
        lhs.objectId == rhs.objectId
    }
    
    let objectId: String
    var email: String
    var username: String
    var personality: String
    var worry: String
    var imageFlag: Int
    var avatar: UIImage?
    var avatarLink: String
    var aboutMe: String
    
    var registeredDate = Date()
    var pushId: String?
    var premium = 0
    
    var likedIdArray: [String]?
    var nextedIdArray: [String]?
    
    var userDictionary: NSDictionary {
        
        return NSDictionary(objects:
                                [self.objectId,
                                 self.email,
                                 self.username,
                                 self.personality,
                                 self.worry,
                                 self.imageFlag,
                                 self.avatarLink,
                                 self.likedIdArray ?? [],
                                 self.nextedIdArray ?? [],
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
                                 kIMAGEFLAG as NSCopying,
                                 kAVATARLINK as NSCopying,
                                 kLIKEDIDARRAY as NSCopying,
                                 kNEXTEDIDARRAY as NSCopying,
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
        imageFlag = 0
        avatarLink = _avatarLink
        aboutMe = ""
        premium = 0
        likedIdArray = []
        nextedIdArray = []
    }
    
    init (_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as? String ?? ""
        email = _dictionary[kEMAIL] as? String ?? ""
        username = _dictionary[kUSERNAME] as? String ?? ""
        personality = _dictionary[kPERSONALITY] as? String ?? ""
        worry = _dictionary[kWORRY] as? String ?? ""
        imageFlag = _dictionary[kIMAGEFLAG] as? Int ?? 0
        avatarLink = _dictionary[kAVATARLINK] as? String ?? ""
        aboutMe = _dictionary[kABOUTME] as? String ?? ""
        premium = _dictionary[kPREMIUM] as? Int ?? 0
        likedIdArray = _dictionary[kLIKEDIDARRAY] as? [String]
        nextedIdArray = _dictionary[kNEXTEDIDARRAY] as? [String]
        
        avatar = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: self.objectId)) ?? UIImage(named: kPLACEHOLDERIMAGE)
    }
    
    //MARK: - Returning current user
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> FUser? {
            
            if Auth.auth().currentUser != nil {
                
                if let userDictionary = userDefaults.object(forKey: kCURRENTUSER) {
                    
                    return FUser(_dictionary: userDictionary as! NSDictionary)
                }
                print(userDefaults.object(forKey: kCURRENTUSER))
            }
        
        print("currentUser is nil")
        
        return nil
    }
    
    func getUserAvatarFromFirestore(completion: @escaping (_ didSet: Bool) -> Void) {
        
        FileStorage.downloadImage(imageUrl: self.avatarLink) { avatarImage in
            let image = avatarImage ?? UIImage(named: kPLACEHOLDERIMAGE)
            print("image is ", image)
            self.avatar = avatarImage ?? UIImage(named: kPLACEHOLDERIMAGE)
            print("avatar is ", self.avatar)
            
            completion(true)
        }
    }
    
    //MARK: - Login
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool, _ userDefaultsObjecForCurrentUser: Any?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            
            if error == nil {
                
                if authDataResult!.user.isEmailVerified {
                    
                    DispatchQueue.main.async{
                        FirebaseListener.shared.downloadCurrentUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                    }
                        
                        print("just before completion in loginUserWith")
                        completion(error, true, userDefaults.object(forKey: kCURRENTUSER))
                        
                } else {
                    print("Email not verified")
                    completion(error, false, nil)
                }
            }else {
                completion(error, false, nil)
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
                    
                    user.saveUserLocally()
                }
            }
        }
    }
    
    //MARK: - Edit User Email/Password
    func updateUserEmail(beforeEmail: String, password: String, newEmail: String, completion: @escaping (_ error: Error?) -> Void) {
        
        let credential = EmailAuthProvider.credential(withEmail: beforeEmail, password: password)
        
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { authDataResult, error in
            completion(error)
        })
        
        //メールを変更し、変更前メールに変更したことを伝える認証用メールを送る
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { error in
            
            //認証用メールを送る
            FUser.resendVerificationEmail { error in
                completion(error)
            }
            completion(error)
        })
    }
    
    //MARK: - Resend Links
    
    class func resendVerificationEmail(completion: @escaping (_ error: Error?) -> Void) {
     
        Auth.auth().currentUser?.reload(completion: { error in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                
                completion(error)
            })
        })
    }
    
    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
     
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                
                completion(error)
            }
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
    
    //MARK: - Logout user
    class func logOutCurrentUser(completion: @escaping(_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
    //MARK: - Save user funcs
    func saveUserLocally() {
        
        userDefaults.setValue(self.userDictionary as! [String : Any], forKey: kCURRENTUSER)
//        userDefaults.synchronize()
        print("save user locally")
    }
    
    func saveUserToFireStore() {
        
        FirebaseReference(.User).document(self.objectId).setData(self.userDictionary as! [String : Any]) { error in
            
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    //MARK: - Update User funcs
    func updateCurrentUserInFireStore(withValues: [String : Any], completion: @escaping (_ error: Error?) -> Void) {
        
        if let dictionary = userDefaults.object(forKey: kCURRENTUSER) {
            
            let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
            userObject.setValuesForKeys(withValues)
            
            FirebaseReference(.User).document(FUser.currentId()).updateData(withValues) {
                error in
                
                completion(error)
                if error == nil {
                    FUser(_dictionary: userObject).saveUserLocally()
                }
            }
        }
    }
    
//    下記の関数はいらないかも
//    func updateCurrentUseraInFireStore(withValues: [String : Any], completion: @escaping (_ error: Error?) -> Void) {
//        
//        if let dictionary = userDefaults.object(forKey: kCURRENTUSER) {
//            
//            let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
//            userObject.setValuesForKeys(withValues)
//            
//            FirebaseReference(.User).document(FUser.currentId()).updateData(withValues) { error in
//                
//                completion(error)
//                if error == nil {
//                    FUser(_dictionary: userObject).saveUserLocally()
//                }
//            }
//        }
//    }
    
//    //MARK: - Delete User funcs
//    func deleteUserFromFireStore(withField: String) async {
//        
//        do {
//
//            try await FirebaseReference(.User).document(FUser.currentId()).updateData(["capital": FieldValue.delete()])
//            
//          print("Document successfully updated")
//        } catch {
//            
//          print("Error updating document: \(error)")
//        }
//    }
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

//MARK: - Options of Personalities and Worries

var personalities: [String] = []
var worries : [String] = []

private func appendPersonalitiesList() {
    personalities.append("人懐っこい後輩タイプ")
    personalities.append("面倒見の良い先輩タイプ")
    personalities.append("誰とでもフラットな同期タイプ")
    personalities.append("みんなをまとめる部長タイプ")
    personalities.append("陰の立役者マネージャータイプ")
    //personalities.append("世話焼きな保護者タイプ")
    personalities.append("1人が好きなオオカミタイプ")
    personalities.append("みんなの癒しペットタイプ")
}

private func appendWorriesList() {
    worries.append("健康、美容、容姿")
    worries.append("将来、夢、キャリア")
    worries.append("人間関係、恋愛、結婚")
    worries.append("お金")
    worries.append("その他")
    worries.append("悩みはない")
}

//MARK: - Create Users
func createUsers() {
    
    appendPersonalitiesList()
    appendWorriesList()
    
    let names = ["めるる", "アッシュ", "ゾロ", "リボン", "竜巻"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<5 {
        
        let id = UUID().uuidString
        
        let fileDirectory = "Avatars/_" + id + ".jpg"
        
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { avatarLink in
            
            let user = FUser(_objectId: id, _email: "user\(userIndex)@mail.com", _username: names[i], _personality: personalities[userIndex], _worry: worries[userIndex], _avatarLink: avatarLink ?? "")
            
            userIndex += 1
            user.saveUserToFireStore()
        }
        
        imageIndex += 1
        
        if imageIndex == 6 {
            imageIndex = 1
        }
    }
}
