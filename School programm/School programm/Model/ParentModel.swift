//
//  ParentModel.swift
//  School programm
//
//  Created by Nikola on 24/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit



class Parent: User{
    
    private static let _instance = Parent()
    static var parent: Parent {
        return _instance
    }
    private var defaults = UserDefaults.standard
    
    
    var childrens: [PPupil] = []
    
    
    func saveChildren(children: PPupil){
        if let row = childrens.firstIndex(where: {$0.id == children.id}) {
            childrens[row] = children
        }else{
            childrens.append(children)
        }
    }

}



struct PPupil {
    
    var fullName: String = ""
    var id: String = ""
    
    
    var group: String = ""
    var groupName: String = ""
    var teacherFullName: String = ""
    var bill: Int = 0
    
    
    var lessons: [PLesson] = []
    
    
    init(){
        
    }
    
    
    // Данные которые скачиваются при первом экране
    init(id: String, data: [String: Any]) {
        self.id = id
        let name = data["name"] as? String ?? ""
        let pathronimic = data["pathronimic"] as? String ?? ""
        self.fullName = name + " " + pathronimic
        self.group = data["group"] as? String ?? ""
    }
    
    
    
    
    
    mutating func saveLesson(lesson: PLesson){
        if let row = lessons.firstIndex(where: {$0.id == lesson.id}) {
            lessons[row] = lesson
        }else{
            lessons.append(lesson)
        }
    }
    
    
    mutating func getSortedLessonsBy(date: String) -> [PLesson]{
        var les: [PLesson] = []
        
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



struct PLesson{
    var id: String = ""
    var date: String = ""
    var name: String = ""
    var number: Int = 0
    var status: String = ""
    
    init(lesson: [String: Any], id: String, pupilId: String) {
        
        self.id = id
        self.date = lesson["date"] as? String ?? ""
        self.name = lesson["name"] as? String ?? ""
        self.number = lesson["number"] as? Int ?? 0
        self.status = lesson[pupilId] as? String ?? ""
    }
    
}
