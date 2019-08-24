//
//  MainPupilVC.swift
//  School programm
//
//  Created by Nikola on 23/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore


class MainPupilVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bill: UILabel!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var enterBtn: UIButton!{
        didSet{
            self.enterBtn.isEnabled = false
        }
    }
    @IBOutlet weak var grayBackground: UIView!{
        didSet{
            self.grayBackground.layer.cornerRadius = 20
        }
    }
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // present basic data
        presentData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        billRefresher()
        groupRefresher()
        LessonsRefresher()
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Выйти из аккаунта?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Выйти", style: .default, handler: { (action) in
            logOut()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    
    
    func presentData(){
        self.titleLabel.text = Pupil.pupil.name! + " " + Pupil.pupil.pathronimic!
        self.className.text = "класс: " + Pupil.pupil.groupName!
        self.teacherName.text = "преподаватель: " + Pupil.pupil.teacherFullName!
        self.bill.text = Pupil.pupil.bill!.description
    }
    
    
    
    
    // MARK TABLE View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stringDate = Date.getTodayStringDate()
        return Pupil.pupil.getSortedLessonsBy(date: stringDate).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MainPupilTableViewCell

        let stringDate = Date.getTodayStringDate()
        let sortedLess = Pupil.pupil.getSortedLessonsBy(date: stringDate)
        
        let lesson = sortedLess[indexPath.row]
        
        cell.title.text = lesson.name
        
        cell.statusImageView.image = UIImage(named: lesson.status)
        
        return cell
    }
    
    
    
    
    
    
    
    // MARK: Firebase
    
    
    @objc func billRefresher(){
        
        let path = db.collection("users").document(User.root.userId!)
        
        path.getDocument { (document, error) in
            
            
            if error != nil{
                showCNMessage(superView: self.view, msg: error!.localizedDescription, isTableView: false)
                return
            }
            
            if let document = document, document.exists{
                
                guard let data = document.data() else{
                    showCNMessage(superView: self.view, msg: "Ошибка обновления счета", isTableView: false)
                    return
                }
                
                showCNMessage(superView: self.view, msg: "Данные успешно обновлены", isTableView: false)
                
                Pupil.pupil.bill = data["bill"] as? Int ?? 0
                self.presentData()
            }
            
        }
    }
    
    
    
    @objc func groupRefresher(){
        
        
        if Pupil.pupil.group == ""{
            return
        }
        
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = db.collection("groups").document(Pupil.pupil.group!)
        
        path.getDocument { (document, error) in
            
            hideActivityIndetificator()
            
            if error != nil{
                showCNMessage(superView: self.view, msg: error!.localizedDescription, isTableView: false)
                return
            }
            
            if let document = document, document.exists{
                
                guard let data = document.data() else{
                    return
                }
                
                Pupil.pupil.groupName = data["name"] as? String ?? "нет"
                Pupil.pupil.teacherFullName = data["teacherFullName"] as? String ?? "нет"
                
                self.presentData()
            }
            
        }
    }
    
    
    @objc func LessonsRefresher(){
        
        
        if Pupil.pupil.group == ""{
            return
        }
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = db.collection("lessons").whereField("group", isEqualTo: Pupil.pupil.group!)
        
        path.getDocuments() { (querySnapshot, err) in
            
            hideActivityIndetificator()
            
            if err != nil{
                showCNMessage(superView: self.view, msg: "Ошибка скачивания уроков", isTableView: false)
                return
            }

            for document in querySnapshot!.documents {
                let lesson = Lesson(lesson: document.data(), id: document.documentID)
                Pupil.pupil.saveLesson(lesson: lesson)
            }
            
            self.enterBtn.isEnabled = true
            self.presentData()
            self.tableView.reloadData()
        }
    }

}







