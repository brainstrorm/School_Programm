//
//  ClassesVC.swift
//  School programm
//
//  Created by Nikola on 23/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore


class ClassesVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var jonyTitle: UILabel!
    
    var jtitle = ""
    
    let db = Firestore.firestore()
    
    var agroups: [AGroup] = []
    var teacherId: String = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jonyTitle.text = jtitle
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getGroups()
    }
    
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let group = agroups[indexPath.row]
        cell?.textLabel?.text = group.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
            let group = self.agroups[indexPath.row]
            self.performSegue(withIdentifier: "AdminPupilsVC", sender: group)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdminPupilsVC"{
            guard let group = sender as? AGroup else {return}
            let destinationVC = segue.destination as? AdminPupilsVC
            let pupils = group.pupils
            destinationVC?.apupils = pupils
            destinationVC?.jtitle = group.name
            destinationVC?.groupId = group.id
        }
    }
    
    
    // MARK: Firebase
    
    func getGroups(){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = self.db.collection("groups").whereField("teacherId", isEqualTo: teacherId)
        
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
                    let group = AGroup(id: document.documentID, data: document.data())
                    self.saveGroup(group: group)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    func saveGroup(group: AGroup){
        if let row = agroups.firstIndex(where: {$0.id == group.id}) {
            agroups[row] = group
        }else{
            agroups.append(group)
        }
    }
}
