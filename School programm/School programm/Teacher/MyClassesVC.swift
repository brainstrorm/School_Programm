//
//  MyClassesVC.swift
//  School programm
//
//  Created by Nikola on 27/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MyClassesVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var jonyTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var makeClassBtn: UIButton!
    
    
    var groups: [Group] = []
    
    
    let db = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.jonyTitle.text = Teacher.teacher.name! + " " + Teacher.teacher.pathronimic!
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.groupsRefresher()
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
    
    
    @IBAction func enterAction(_ sender: Any) {
        makeNewGroup()
    }
    

    
    
    // MARK: Table View 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let group = self.groups[indexPath.row]
        
        cell?.textLabel?.text = group.name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let kCellActionWidth: CGFloat = 65
        let kActionImageSize: CGFloat = 34
        
        let whitespace = whitespaceString(width: kCellActionWidth)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kCellActionWidth, height: 65))
        view.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: CGRect(x: (kCellActionWidth - kActionImageSize) / 2,
                                                  y: (65 - kActionImageSize) / 2,
                                                  width: kActionImageSize,
                                                  height: kActionImageSize))
        
        
        
        let editAction = UITableViewRowAction(style: .normal, title: whitespace) { (rowAction, indexPath) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "makeClass", sender: self.groups[indexPath.row])
            }
        }
        
        imageView.image = UIImage(named: "redact")
        view.addSubview(imageView)
        var image = view.image()
        
        editAction.backgroundColor = UIColor(patternImage: image)
        
        
        let deleteAction = UITableViewRowAction(style: .normal, title: whitespace) { (rowAction, indexPath) in
            
            DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Вы уверены, что хотите удалить класс?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { (alert) in
                self.deleteGroup(group: self.groups[indexPath.row], indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        
        
        // create a color from patter image and set the color as a background color of action
        imageView.image = UIImage(named: "delete")
        view.addSubview(imageView)
        image = view.image()

        
        deleteAction.backgroundColor = UIColor(patternImage: image)
        
        return [editAction,deleteAction]
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "LessonsForTodayVC", sender: indexPath.row)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "makeClass"{
            let destinationVC = segue.destination as? MakeClassVC

            guard let group = sender as? Group else {return}
            destinationVC?.jtitle = group.name
            destinationVC?.groupId = group.id
            destinationVC?.group = group
            
        }else if segue.identifier == "LessonsForTodayVC"{
            
            let destinationVC = segue.destination as? LessonsForTodayVC
            guard let row = sender as? Int else {return}
            let group = self.groups[row]
            destinationVC?.jtitle = group.name
            destinationVC?.groupId = group.id
            
        }
    }
    
    
    
    
    
    
    // MARK: Firebase
    
    func groupsRefresher(){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = db.collection("groups").whereField("teacherId", isEqualTo: Teacher.teacher.userId!)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            
        path.getDocuments() { (querySnapshot, err) in
            
            DispatchQueue.main.async {
                hideActivityIndetificator()
            }
            
            if err != nil{
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Ошибка скачивания групп", isTableView: false)
                }
                return
            }
            
            for document in querySnapshot!.documents {
                let group = Group(group: document.data(), id: document.documentID)
                self.saveGroup(group: group)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        }
    }
    

    
    
    func makeNewGroup(){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let randId = self.db.collection("groups").document().documentID
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            
            let groupData: [String: Any] = ["name": "Новая группа", "teacherFullName": "\(Teacher.teacher.name!) \(Teacher.teacher.pathronimic!)", "teacherId": Teacher.teacher.userId!]
            
            self.db.collection("groups").document(randId).setData(groupData, completion: { (error) in
                
                DispatchQueue.main.async {
                    hideActivityIndetificator()
                }
                
                if error != nil{
                    DispatchQueue.main.async {
                        showCNMessage(superView: self.view, msg: "Ошибка удаления группы", isTableView: false)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    let localgroup = Group(group: groupData, id: randId)
                    showCNMessage(superView: self.view, msg: "Новая группа успешно создана", isTableView: false)
                    self.performSegue(withIdentifier: "makeClass", sender: localgroup)
                }
                
            })
        }
    }
    
    
    
    func deleteGroup(group: Group, indexPath: IndexPath){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        
        self.db.collection("groups").document(group.id).delete { (error) in
            
            DispatchQueue.main.async {
                hideActivityIndetificator()
            }
            
            if error != nil{
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Ошибка удаления группы", isTableView: false)
                }
                return
            }
            
            self.groups.removeAll(where: { (gr) -> Bool in
                return gr.id == group.id
            })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        }
    }
    
    
    
    func saveGroup(group: Group){
        if let row = groups.firstIndex(where: {$0.id == group.id}) {
            groups[row] = group
        }else{
            groups.append(group)
        }
    }
    
}
