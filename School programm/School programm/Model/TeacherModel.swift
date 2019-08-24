//
//  TeacherModel.swift
//  School programm
//
//  Created by Nikola on 24/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit



class Teacher: User{
    
    private static let _instance = Teacher()
    static var teacher: Teacher {
        return _instance
    }
    private var defaults = UserDefaults.standard

    
}


struct Group {
    var id: String = ""
    var name: String = ""
    
    var lessons: [TLesson] = []
    var pupils: [TPupil] = []
    
    init(group: [String: Any], id: String) {
        self.id = id
        self.name = group["name"] as? String ?? ""
    }
    
    init() {
    }
}

struct TLesson{
    var id: String = ""
    var name: String = ""
    var date: String = ""
    var number: Int = 0
    
    init(lesson: [String: Any], id: String) {
        self.id = id
        self.name = lesson["name"] as? String ?? ""
        self.date = lesson["date"] as? String ?? ""
    }
    
    init(name: String) {
        self.name = name
    }
    
    init() {
    }
}

struct TPupil{
    var id: String = ""
    var fullName: String = ""
    var bill: Int = 0
    
    // Эта переменная используется только в уроке. Вне его она пуста
    var status: String = ""
    
    
    
    init(pupil: [String: Any], id: String) {
        self.id = id
        let name = pupil["name"] as? String ?? ""
        let pathronimic = pupil["pathronimic"] as? String ?? ""
        self.fullName = name + " " + pathronimic
        self.bill = pupil["bill"] as? Int ?? 0
    }
}


