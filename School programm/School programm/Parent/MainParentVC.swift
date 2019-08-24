//
//  MyChildrenVC.swift
//  School programm
//
//  Created by Nikola on 24/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore


class MainParentVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            self.titleLabel.text = Parent.parent.name! + " " + Parent.parent.pathronimic!
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getChildrens()
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
    
    
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Parent.parent.childrens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let children = Parent.parent.childrens[indexPath.row]
        
        cell?.textLabel?.text = children.fullName
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let children = Parent.parent.childrens[indexPath.row]
        performSegue(withIdentifier: "PMainPupilVC", sender: children)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PMainPupilVC"{
            guard let children = sender as? PPupil else {return}
            let destinationVC = segue.destination as? PMainPupilVC
            destinationVC?.pupil = children
        }
    }
    
    
    // MARK: Firebase
    
    
    
    func getChildrens(){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = db.collection("users").whereField("parentId", isEqualTo: Parent.parent.userId!)
        
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
                    let children = PPupil(id: document.documentID, data: document.data())
                    Parent.parent.saveChildren(children: children)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
