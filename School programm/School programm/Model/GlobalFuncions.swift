//
//  GlobalFuncions.swift
//  School programm
//
//  Created by Nikola on 24/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase





func logOut(){
    try! Auth.auth().signOut()
    
    // Удаляем все данные
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
    
    
    Pupil.pupil.lessons.removeAll()
    Parent.parent.childrens.removeAll()
    Admin.admin.teachers.removeAll()
    
    let viewController: UIViewController = UIStoryboard(name: "Authorization", bundle: nil).instantiateViewController(withIdentifier: "LoginFormVC") as UIViewController
    
    viewController.view.frame = UIScreen.main.bounds
    
    let appDelegate = UIApplication.shared.delegate
    appDelegate?.window??.rootViewController = viewController
}




func loginToRole(roleType: String){
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
 
    if roleType == Role.ученик{
        appDelegate.switchToPupilMainView()
    }else if roleType == Role.преподаватель{
        appDelegate.switchToTeacherMainView()
    }else if roleType == Role.родитель{
        appDelegate.switchToParentMainView()
    }else if roleType == Role.администратор{
        appDelegate.switchToAdminMainView()
    }
}




func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        
        if let output = filter.outputImage?.transformed(by: transform) {
            return UIImage(ciImage: output)
        }
    }
    
    return nil
}



func explainQRCode(string: String) -> (type: String, id: String){
    
    var text = string
    var type = scanType.группа
    
    let sim = text.popLast()
    
    if sim == "1"{
        type = scanType.урок
    }else if sim == "2"{
        type = scanType.группа
    }else if sim == "3"{
        type = scanType.ребенок
    }
    
    return (type, text)
}



extension UIView{
    
    func image() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}



func whitespaceString(font: UIFont = UIFont.systemFont(ofSize: 15), width: CGFloat) -> String {
    let kPadding: CGFloat = 20
    let mutable = NSMutableString(string: "")
    let attribute = [NSAttributedString.Key.font: font]
    while mutable.size(withAttributes: attribute).width < width - (2 * kPadding) {
        mutable.append(" ")
    }
    return mutable as String
}
