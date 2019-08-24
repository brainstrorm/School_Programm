//
//  AdministratorModel.swift
//  School programm
//
//  Created by Nikola on 24/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit



class Admin: User{
    
    private static let _instance = Admin()
    static var admin: Admin {
        return _instance
    }
    private var defaults = UserDefaults.standard
    
    var teachers: [ATeacher] = []
    
    
    func saveTeacher(teacher: ATeacher){
        if let row = self.teachers.firstIndex(where: {$0.id == teacher.id}) {
            teachers[row] = teacher
        }else{
            teachers.append(teacher)
        }
    }
}




struct ATeacher {
    var fullName: String = ""
    var id: String = ""
    
    var groups:[AGroup] = []
    
    
    init(){
        
    }
    
    
    // Данные которые скачиваются при первом экране
    init(id: String, data: [String: Any]) {
        self.id = id
        let name = data["name"] as? String ?? ""
        let pathronimic = data["pathronimic"] as? String ?? ""
        self.fullName = name + " " + pathronimic
    }
}


struct AGroup {
    var name: String = ""
    var id: String = ""
    
    var pupils:[APupil] = []
    
    init(){
        
    }
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["name"] as? String ?? ""
    }

}

struct APupil {
    var fullName: String = ""
    var id: String = ""
    var bill: Int = 0
    
    init(){
        
    }
    
    init(id: String, data: [String: Any]) {
        self.id = id
        let name = data["name"] as? String ?? ""
        let surname = data["surname"] as? String ?? ""
        let pathronimic = data["pathronimic"] as? String ?? ""
        self.fullName = name + " " + surname + " " + pathronimic
        self.bill = data["bill"] as? Int ?? 0
    }
}
