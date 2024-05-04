//
//  FileStorage.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/05.
//

import Foundation
import FirebaseStorage
import UIKit
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        
        let imageData = image.jpegData(compressionQuality: 1)
        
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { metaData, error in
            
            task.removeAllObservers()
//            ProgressHUD.dismiss()
            
            if error != nil {
                print("error uploading image", error!.localizedDescription)
                return
            }
            
            storageRef.downloadURL { url, error in
                
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                
                print("we have uploaded image to", downloadUrl.absoluteString)
                completion(downloadUrl.absoluteString)
            }
        })
        
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
//            ProgressHUD.showProgress(CGFloat(progress))
        }
        
    }
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = ((imageUrl.components(separatedBy: "_").last!).components(separatedBy: "?").first)!.components(separatedBy: ".").first!
        
        if fileExistsAt(path: imageFileName) {
            
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: imageFileName)) {
                print("could generate img")
                completion(contentsOfFile)
                
            } else {
                
                print("couldnt generate imge from local image")
                completion(nil)
            }
        } else {
            
            if imageUrl != "" {
                
                let documentURL = URL(string: imageUrl)
                
                let downloadQueue = DispatchQueue(label: "downloadQueue")
                
                downloadQueue.async {
                    
                    let data = NSData(contentsOf: documentURL!)
                    
                    if data != nil {
                        print("data is not nil")
                        let imageToReturn = UIImage(data: data! as Data)
                        
                        FileStorage.saveImageLocally(imageData: data!, fileName: imageFileName)
                        
                        completion(imageToReturn)
                        
                    } else {
                        print("no image in database")
                        completion(nil)
                    }
                }
            } else {
                print("nil")
                completion(nil)
            }
        }
    }
    
    class func saveImageLocally(imageData: NSData, fileName: String) {
        
        var docURL = getDocumentsURL()
        
        docURL = docURL.appendingPathComponent(fileName, conformingTo: .image)
        imageData.write(to: docURL, atomically: true)
    }
}

func getDocumentsURL() -> URL {
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    print("documentURL is ", documentURL, " in getDocumentsURL")
    return documentURL!
}

func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
}

//正常に動いていれば下記は必要ない
//func fileExistsAtPath(path: String) -> Bool {
//    
//    var doesExist = false
//    
//    let filePath = fileInDocumentsDirectory(filename: path)
//    
//    if FileManager.default.fileExists(atPath: filePath) {
//        doesExist = true
//    } else {
//        doesExist = false
//    }
//    
//    return doesExist
//}

func fileExistsAt(path: String) -> Bool {
    
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(filename: path))
}
