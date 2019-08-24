//
//  MakeClassVC.swift
//  School programm
//
//  Created by Nikola on 27/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MakeClassVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
  
    @IBOutlet weak var jonyTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var classNameTF: UITextField!
    
    // Для передачи данных
    var jtitle: String = ""
    var group: Group = Group()
    var groupId = ""
    
    // Для отображения данных
    var groupedDates: [String] = []
    var lessons: [TLesson] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jonyTitle.text = jtitle
        
        self.classNameTF.text = group.name
        
        // Добавляем детектор касания
       tableView.keyboardDismissMode = .onDrag
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        lessonsRefresher(group: groupId)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        groupedDates.removeAll()
        lessons.removeAll()
        group.lessons.removeAll()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func plusAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "MakeLessonsVC", sender: 99999)
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        updateData()
    }
    
    
    @objc func closeKeybord(){
        view.endEditing(true)
    }
    
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupedDates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = groupedDates[indexPath.row]
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "MakeLessonsVC", sender: indexPath.row)
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MakeLessonsVC"{
            guard let row = sender as? Int else {return}
            let destinationVC = segue.destination as? MakeLessonsVC
            
            if row == 99999{
                destinationVC?.date = Date.getTodayStringDate()
                destinationVC?.groupId = groupId
                destinationVC?.jtitle = "Новый день"
                destinationVC?.lessons = []
            }else{
                let date = groupedDates[row]
                destinationVC?.date = date
                destinationVC?.groupId = groupId
                destinationVC?.jtitle = date
                destinationVC?.lessons = getSortedLessonsByDate(lessons: lessons, date: date)
            }

        }
    }
    
    
    
    

    
    
    
    func lessonsRefresher(group: String){
        
        let path = db.collection("lessons").whereField("group", isEqualTo: group)
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        path.getDocuments() { (querySnapshot, err) in
            
            DispatchQueue.main.async {
                hideActivityIndetificator()
            }
            
            if err != nil{
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Ошибка скачивания уроков", isTableView: false)
                }
                return
            }
            
            for document in querySnapshot!.documents {
                let lesson = TLesson(lesson: document.data(), id: document.documentID)
                self.saveLesson(lesson: lesson)
            }
            
            DispatchQueue.main.async {
                self.groupedDates = self.getGroupedAndSortedDates()
                self.tableView.reloadData()
            }
        }
        }
    }
    
    
    
    
    
    
    
    func updateData(){
        
        let updatingData: [String: Any] = ["name": classNameTF.text!]
        showActivityIndetificator(superView: self.view, isTableView: false)
        let path = db.collection("groups").document(self.groupId)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        
            path.updateData(updatingData) { (error) in
                
                DispatchQueue.main.async {
                    hideActivityIndetificator()
                }
                
                if error != nil{
                    DispatchQueue.main.async {
                        showCNMessage(superView: self.view, msg: "Ошибка загрузки данных", isTableView: false)
                    }
                    return
                }
                
                
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Название успешно изменено", isTableView: false)
                    self.dismiss(animated: false, completion: nil)
                }
                
            }
            
        }
    }
    

    func saveLesson(lesson: TLesson){
        if let row = lessons.firstIndex(where: {$0.id == lesson.id}) {
            self.lessons[row] = lesson
        }else{
            self.lessons.append(lesson)
        }
    }
    
    
    func getSortedLessonsByDate(lessons: [TLesson], date: String) -> [TLesson]{
        
        // Группировка
        var groupedLessons: [TLesson] = []
        
        for lesson in lessons{
            if lesson.date == date{
                groupedLessons.append(lesson)
            }
        }
        
        // Сортировка
        groupedLessons.sort { (value1, value2) -> Bool in
            return value1.number < value2.number
        }
        
        return groupedLessons
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
    
    
    
    func getSortedLessonsByDate(group: Group, date: String) -> [TLesson]{
        
        // Группировка
        var groupedLessons: [TLesson] = []
        
        for lesson in group.lessons{
            if lesson.date == date{
                groupedLessons.append(lesson)
            }
        }
        
        // Сортировка
        groupedLessons.sort { (value1, value2) -> Bool in
            return value1.number < value2.number
        }
        
        return groupedLessons
    }
    
}
