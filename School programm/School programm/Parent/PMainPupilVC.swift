//
//  MainPupilVC.swift
//  School programm
//
//  Created by Nikola on 23/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore


class PMainPupilVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bill: UILabel!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var pupil: PPupil = PPupil()
    
    
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
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    func presentData(){
        self.titleLabel.text = pupil.fullName
        self.className.text = "класс: " + pupil.groupName
        self.teacherName.text = "преподаватель: " + pupil.teacherFullName
        self.bill.text = pupil.bill.description
    }
    
    
    
    
    // MARK TABLE View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stringDate = Date.getTodayStringDate()
        return pupil.getSortedLessonsBy(date: stringDate).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PMainPupilTableViewCell

        let stringDate = Date.getTodayStringDate()
        let sortedLess = pupil.getSortedLessonsBy(date: stringDate)
        
        let lesson = sortedLess[indexPath.row]
        
        cell.title.text = lesson.name

        cell.statusImageView.image = UIImage(named: lesson.status)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "PDaysVC", sender: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "PDaysVC"{
            print("identifier ошибка")
            return
        }

        let vc = segue.destination as! PDaysVC
        vc.pupil = pupil
    }
    
    
    // MARK: Firebase
    
    
    @objc func billRefresher(){
        
        let path = db.collection("users").document(pupil.id)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        
        path.getDocument { (document, error) in
            
            if error != nil{
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: error!.localizedDescription, isTableView: false)
                }
                return
            }
            
            if let document = document, document.exists{
                
                guard let data = document.data() else{
                    DispatchQueue.main.async {
                        showCNMessage(superView: self.view, msg: "Ошибка обновления счета", isTableView: false)
                    }
                    return
                }
                
                
                self.pupil.bill = data["bill"] as? Int ?? 0
                
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Данные успешно обновлены", isTableView: false)
                    self.presentData()
                }
            }
            
        }
        }
    }
    
    
    
    @objc func groupRefresher(){
        
        
        if pupil.group == ""{
            return
        }
        
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = db.collection("groups").document(pupil.group)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        path.getDocument { (document, error) in
            DispatchQueue.main.async {
            hideActivityIndetificator()
            }
            
            if error != nil{
                showCNMessage(superView: self.view, msg: error!.localizedDescription, isTableView: false)
                return
            }
            
            if let document = document, document.exists{
                
                guard let data = document.data() else{
                    return
                }
                DispatchQueue.main.async {
                self.pupil.groupName = data["name"] as? String ?? "нет"
                self.pupil.teacherFullName = data["teacherFullName"] as? String ?? "нет"
                
                self.presentData()
                }
            }
            
        }
        }
    }
    
    
    @objc func LessonsRefresher(){
        
        if pupil.group == ""{
            return
        }
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = db.collection("lessons").whereField("group", isEqualTo: pupil.group)
        
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
                let lesson = PLesson(lesson: document.data(), id: document.documentID, pupilId: self.pupil.id)
                self.pupil.saveLesson(lesson: lesson)
            }
            
            DispatchQueue.main.async {
            self.enterBtn.isEnabled = true
            self.presentData()
            self.tableView.reloadData()
            }
        }
            
        }
    }

}







