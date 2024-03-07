//
//  FileStorage.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/05.
//

import Foundation
import FirebaseStorage
import UIKit

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        
        let imageData = image.jpegData(compressionQuality: 1)
        
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { metaData, error in
            
            task.removeAllObservers()
            
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
    }
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = ((imageUrl.components(separatedBy: "_").last!).components(separatedBy: "?").first)!.components(separatedBy: ".").first!
        
        if fileExistsAtPath(path: imageFileName) {
            
            print("we have local file")
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                
                print("couldnt generate imge from local image")
                completion(UIImage(named: kPLACEHOLDERIMAGE))
            }
        } else {
            //download
            
            if imageUrl != "" {
                
                let documentURL = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "downloadQueue")
                downloadQueue.async {
                    
                    let data = NSData(contentsOf: documentURL!)
                    
                    if data != nil {
                        
                        let imageToReturn = UIImage(data: data! as Data)
                        
                        FileStorage.saveImageLocally(imageData: data!, fileName: imageFileName)
                        
                        completion(imageToReturn)
                    } else {
                        
                        print("no image in database")
                        completion(nil)
                    }
                }
            } else {
                completion(UIImage(named: kPLACEHOLDERIMAGE))
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
    
    return documentURL!
}

func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename, conformingTo: .image)
    
    return fileURL.path
}

func fileExistsAtPath(path: String) -> Bool {
    
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(filename: path)
    
    if FileManager.default.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist
}
