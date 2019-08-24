//
//  MainAdministratorVC.swift
//  School programm
//
//  Created by Nikola on 23/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore


class MainAdministratorVC: UIViewController, UITableViewDelegate, UITableViewDataSource{


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var jonyTitle: UILabel!{
        didSet{
            self.jonyTitle.text = Admin.admin.name! + " " + Admin.admin.pathronimic!
        }
    }
    
    let db = Firestore.firestore()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getTeachers()
    }
    
    
    
    @IBAction func logoutAction(_ sender: Any) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Выйти из аккаунта?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Выйти", style: .default, handler: { (action) in
                logOut()
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Admin.admin.teachers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let teacher = Admin.admin.teachers[indexPath.row]
        cell?.textLabel?.text = teacher.fullName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
            let teacher = Admin.admin.teachers[indexPath.row]
            self.performSegue(withIdentifier: "ClassesVC", sender: teacher)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClassesVC"{
            guard let teacher = sender as? ATeacher else {return}
            let destinationVC = segue.destination as? ClassesVC
            destinationVC?.agroups = teacher.groups
            destinationVC?.jtitle = teacher.fullName
            destinationVC?.teacherId = teacher.id
        }
    }
    
    
    // MARK: Firebase
    
    
    func getTeachers(){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = self.db.collection("users").whereField("role", isEqualTo: Role.преподаватель)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            
            path.getDocuments() { (querySnapshot, err) in
                
                DispatchQueue.main.async {
                    hideActivityIndetificator()
                }
                
                if err != nil{
                    DispatchQueue.main.async {
                        showCNMessage(superView: self.view, msg: "Ошибка скачивания данных", isTableView: false)
                    }
                    return
                }
                
                for document in querySnapshot!.documents {
                    let teacher = ATeacher(id: document.documentID, data: document.data())
                    Admin.admin.saveTeacher(teacher: teacher)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
