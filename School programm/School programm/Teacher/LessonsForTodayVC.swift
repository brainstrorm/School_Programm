//
//  LessonsForTodayVC.swift
//  School programm
//
//  Created by Nikola on 27/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore

class LessonsForTodayVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var jonyTitle: UILabel!
    
    
    var jtitle: String = ""
    var date: String = ""
    var groupId: String = ""
    
    var lessons: [TLesson] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        jonyTitle.text = jtitle
        date = Date.getTodayStringDate()
        
        lessonsRefresher(group: groupId)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = lessons[indexPath.row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "PupilsListVC", sender: indexPath.row)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TeacherQRVC"{
            let destinationVC = segue.destination as? TeacherQRVC
            destinationVC?.groupId = groupId
        }else if segue.identifier == "PupilsListVC"{
            let destinationVC = segue.destination as? PupilsListVC
            guard let row = sender as? Int else {return}
            destinationVC?.groupId = groupId
            destinationVC?.jtitle = lessons[row].name
            destinationVC?.lessonId = lessons[row].id
        }
    }
    
    
    
    
    
    
    
    func lessonsRefresher(group: String){
        
        let path = db.collection("lessons").whereField("group", isEqualTo: group)
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        
        path.getDocuments() { (querySnapshot, err) in
            
            hideActivityIndetificator()
            
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
                self.lessons = self.getSortedLessonsByDate(lessons: self.lessons, date: self.date)
                self.tableView.reloadData()
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
    
}
