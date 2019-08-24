//
//  FlatModel.swift
//  Quarta Panel
//
//  Created by Nikola on 10/04/2019.
//  Copyright © 2019 serbionare. All rights reserved.
//

import UIKit
import FirebaseFirestore


class Pupil: User{
    
    private static let _instance = Pupil()
    static var pupil: Pupil {
        return _instance
    }
    private var defaults = UserDefaults.standard


    var group: String?{
        get {
            var group = ""
            if defaults.value(forKey: "group") != nil{
                group = defaults.value(forKey: "group") as? String ?? ""
            }
            return group
        }
        set {
            defaults.setValue(newValue, forKey: "group")
        }
    }
    var groupName: String?{
        get {
            var groupName = ""
            if defaults.value(forKey: "groupName") != nil{
                groupName = defaults.value(forKey: "groupName") as? String ?? ""
            }
            return groupName
        }
        set {
            defaults.setValue(newValue, forKey: "groupName")
        }
    }
    var teacherFullName: String?{
        get {
            var teacherFullName = ""
            if defaults.value(forKey: "teacherFullName") != nil{
                teacherFullName = defaults.value(forKey: "teacherFullName") as? String ?? ""
            }
            return teacherFullName
        }
        set {
            defaults.setValue(newValue, forKey: "teacherFullName")
        }
    }
    var bill: Int?{
        get {
            var bill = 0
            if defaults.value(forKey: "bill") != nil{
                bill = defaults.value(forKey: "bill") as? Int ?? 0
            }
            return bill
        }
        set {
            defaults.setValue(newValue, forKey: "bill")
        }
    }
    
    
    
    // class part
    var lessons: [Lesson] = []

    
    func saveLesson(lesson: Lesson){
        if let row = lessons.firstIndex(where: {$0.id == lesson.id}) {
            lessons[row] = lesson
        }else{
            lessons.append(lesson)
        }
    }
    
    
    func getSortedLessonsBy(date: String) -> [Lesson]{
        var les: [Lesson] = []
        
        // Фильтруем по дате
        lessons.forEach { (lesson) in
            if lesson.date == date{
                les.append(lesson)
            }
        }
        
        // Сортируем по номеру урока
        lessons.sort { (lesson1, lesson2) -> Bool in
            return lesson1.number < lesson2.number
        }
        
        return les
    }
    
    
    func getGroupedAndSortedDates() -> [String]{
        
        // Группировка
        
        var groupedLessons: [String] = []
        
        for lesson in lessons{
            if !groupedLessons.contains(lesson.date){
                groupedLessons.append(lesson.date)
            }
        }

        // Сортировка
        groupedLessons.sort { (value1, value2) -> Bool in
            let date1 = Date.calculateDate(from: value1)
            let date2 = Date.calculateDate(from: value2)
            return date1 < date2
        }
        
        return groupedLessons
    }
}


struct Lesson{
    var id: String = ""
    var date: String = ""
    var name: String = ""
    var number: Int = 0
    var status: String = ""
    
    init(lesson: [String: Any], id: String) {
        
        self.id = id
        self.date = lesson["date"] as? String ?? ""
        self.name = lesson["name"] as? String ?? ""
        self.number = lesson["number"] as? Int ?? 0
        self.status = lesson[Pupil.pupil.userId!] as? String ?? ""
    }
}

