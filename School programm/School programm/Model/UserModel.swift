//
//  UserModel.swift
//  School programm
//
//  Created by Nikola on 24/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore

class User{
    
    
    private static let _instance = User()
    static var root: User {
        return _instance
    }
    private var defaults = UserDefaults.standard
    
    
    var role: String?{
        get {
            var role = ""
            if defaults.value(forKey: "role") != nil{
                role = defaults.value(forKey: "role") as? String ?? ""
            }
            return role
        }
        set {
            defaults.setValue(newValue, forKey: "role")
        }
    }
    
    
    
    var userId: String?{
        get {
            var userId = ""
            if defaults.value(forKey: "userId") != nil{
                userId = defaults.value(forKey: "userId") as? String ?? ""
            }
            return userId
        }
        set {
            defaults.setValue(newValue, forKey: "userId")
        }
    }
    
    var email: String?{
        get {
            var email = ""
            if defaults.value(forKey: "email") != nil{
                email = defaults.value(forKey: "email") as? String ?? ""
            }
            return email
        }
        set {
            defaults.setValue(newValue, forKey: "email")
        }
    }
    
    
    var password: String?{
        get {
            var password = ""
            if defaults.value(forKey: "password") != nil{
                password = defaults.value(forKey: "password") as? String ?? ""
            }
            return password
        }
        set {
            defaults.setValue(newValue, forKey: "password")
        }
    }
    
    
    var pathronimic: String?{
        get {
            var pathronimic = ""
            if defaults.value(forKey: "pathronimic") != nil{
                pathronimic = defaults.value(forKey: "pathronimic") as? String ?? ""
            }
            return pathronimic
        }
        set {
            defaults.setValue(newValue, forKey: "pathronimic")
        }
    }
    
    var name: String?{
        get {
            var name = ""
            if defaults.value(forKey: "name") != nil{
                name = defaults.value(forKey: "name") as? String ?? ""
            }
            return name
        }
        set {
            defaults.setValue(newValue, forKey: "name")
        }
    }
    
    var surname: String?{
        get {
            var surname = ""
            if defaults.value(forKey: "surname") != nil{
                surname = defaults.value(forKey: "surname") as? String ?? ""
            }
            return surname
        }
        set {
            defaults.setValue(newValue, forKey: "surname")
        }
    }
    
    
    
    
    
    
    
    
    
    
    // Method
    

    
    func firebaseInit(document: DocumentSnapshot?){
        
        if let document = document, document.exists{
            
            guard let data = document.data() else{
                return
            }
            
            phoneInit(data: data)
        }
    }
    
    func phoneInit(data: [String: Any]){

        self.role = data["role"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.surname = data["name"] as? String ?? ""
        self.pathronimic = data["pathronimic"] as? String ?? ""
        self.password = data["password"] as? String ?? ""
        self.userId = data["userId"] as? String ?? ""
        
        
        
        if self.role == Role.ученик{
            Pupil.pupil.group = data["group"] as? String ?? ""
        }else if self.role == Role.преподаватель{
            
        }else if self.role == Role.родитель{
            
        }else if self.role == Role.администратор{
            
        }
    }
}
