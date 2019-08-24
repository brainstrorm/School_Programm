//
//  PupilsListVC.swift
//  School programm
//
//  Created by Nikola on 27/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PupilsListVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var jonyTitle: UILabel!
    
    var jtitle: String = ""
    var lessonId = ""
    var groupId: String = ""
    var pupils: [TPupil] = []
    
    
    var db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jonyTitle.text = jtitle
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        pupilsRefresher(group: groupId)
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pupils.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TCollectionViewCell
        
        let pupil = pupils[indexPath.row]
        
        cell.label.text = pupil.fullName
        print(pupil)
        cell.status.image = UIImage(named: pupil.status)
        cell.bill.text = pupil.bill.description
        
        cell.layer.borderColor = #colorLiteral(red: 0.4980392157, green: 0.8431372549, blue: 0.9843137255, alpha: 1)
        cell.layer.borderWidth = 3
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2-6, height: 86)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pupil = pupils[indexPath.row]
        showFirstInputDialog(pupil: pupil, indexPath: indexPath)
    }
    
    
    
    
    
    
    
    func showFirstInputDialog(pupil: TPupil, indexPath: IndexPath){
        
        let alert = UIAlertController(title: pupil.fullName, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Изменить статус присутствия", style: .default, handler: { (alert) in
            
            self.showSecondInputDialog(pupil: pupil, indexPath: indexPath)
            
        }))
        alert.addAction(UIAlertAction(title: "Изменить счет", style: .default, handler: { (alert) in
            
            self.showThirdInputDialog(pupil: pupil, indexPath: indexPath)
            
        }))
        alert.addAction(UIAlertAction(title: "Удалить ученика из группы", style: .default, handler: { (alert) in
            
            self.deletePupilFromGroup(pupil: pupil, indexPath: indexPath)
            
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    func showSecondInputDialog(pupil: TPupil, indexPath: IndexPath){
        let alert = UIAlertController(title: "Статус ученика на уроке", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Присутствует", style: .default, handler: { (alert) in
            
            self.setPupilStatus(pupil: pupil, indexPath: indexPath, status: Status.present)

        }))
        alert.addAction(UIAlertAction(title: "Отсутствует", style: .default, handler: { (alert) in
            
            self.setPupilStatus(pupil: pupil, indexPath: indexPath, status: Status.notpresent)
            
        }))
        alert.addAction(UIAlertAction(title: "Отсутствует по уважительной причине", style: .default, handler: { (alert) in
            
            self.setPupilStatus(pupil: pupil, indexPath: indexPath, status: Status.respectfull)
            
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    func showThirdInputDialog(pupil: TPupil, indexPath: IndexPath){
        let alert = UIAlertController(title: "Введите сумму", message: nil, preferredStyle: .alert)
        
        
        alert.addTextField { (textField) in
            textField.placeholder = "сумма"
            textField.keyboardType = .numberPad
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Зачислить", style: .default, handler: { [weak alert] (_) in
            
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            let text = textField.text
            
            if text == ""{
                showCNMessage(superView: self.view, msg: "Введите значение", isTableView: false)
                return
            }
            
            self.changeCristalsCount(value: Int(text!)!, isMinus: false, pupil: pupil, indexPath: indexPath)
            
        }))
        alert.addAction(UIAlertAction(title: "Снять", style: .default, handler: { [weak alert] (_) in
            
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            let text = textField.text
            
            if text == ""{
                showCNMessage(superView: self.view, msg: "Введите значение", isTableView: false)
                return
            }
            
            self.changeCristalsCount(value: Int(text!)!, isMinus: true, pupil: pupil, indexPath: indexPath)
            
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    // MARK: Firebase
    
    
    func setPupilStatus(pupil: TPupil, indexPath: IndexPath, status: String){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let path = self.db.collection("lessons").document(self.lessonId)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        
            path.updateData([pupil.id : status]) { (error) in
            
            DispatchQueue.main.async {
                hideActivityIndetificator()
            }
            
            if error != nil{
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Ошибка скачивания учеников", isTableView: false)
                }
                return
            }
                
            self.pupils[indexPath.row].status = status
            
            DispatchQueue.main.async {
                showCNMessage(superView: self.view, msg: "Статус успешно обнавлен", isTableView: false)
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }
        }
        
    }
    
    
    
    
    
    func statusRefresher(){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        for pupil in pupils{
            
            let path = self.db.collection("lessons").document(self.lessonId)
            
            let queue = DispatchQueue.global(qos: .utility)
            queue.async{
                
                path.getDocument(completion: { (document, error) in
                    
                    if pupil.id == self.pupils.last?.id{
                        DispatchQueue.main.async {
                            hideActivityIndetificator()
                        }
                    }
                    
                    
                    if error != nil{
                        DispatchQueue.main.async {
                            showCNMessage(superView: self.view, msg: "Ошибка скачивания данных", isTableView: false)
                        }
                        return
                    }
                    
                    guard let data = document?.data() else {print("problem with data");return}
                    
                    var localpupil = pupil
                    localpupil.status = data[pupil.id] as? String ?? ""
                    self.savePupil(pupil: localpupil)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                })
                
                
            }
            
        }
        
    }
    
    
    

    
    func pupilsRefresher(group: String){
        
        let path = db.collection("users").whereField("group", isEqualTo: group).whereField("role", isEqualTo: Role.ученик)
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        
        path.getDocuments() { (querySnapshot, err) in
            
            DispatchQueue.main.async {
                hideActivityIndetificator()
            }
            
            if err != nil{
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Ошибка скачивания учеников", isTableView: false)
                }
                return
            }
            
            for document in querySnapshot!.documents {
                let pupil = TPupil(pupil: document.data(), id: document.documentID)
                self.savePupil(pupil: pupil)
            }
            
            self.statusRefresher()
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        }
    }
    
    
    
    
    func savePupil(pupil: TPupil){
        if let row = pupils.firstIndex(where: {$0.id == pupil.id}) {
            self.pupils[row] = pupil
        }else{
            self.pupils.append(pupil)
        }
    }
    
    
    
    
    
    
    
    
    func changeCristalsCount(value: Int, isMinus: Bool, pupil: TPupil, indexPath: IndexPath){
        
        var tpupil = pupil
        var bill = pupil.bill
        
        if isMinus{
            bill-=value
        }else{
            bill+=value
        }
        
        tpupil.bill = bill
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            
            
            self.db.collection("users").document(pupil.id).updateData(["bill": bill]) { (error) in
                
                DispatchQueue.main.async {
                    hideActivityIndetificator()
                }
                
                if error != nil{
                    DispatchQueue.main.async {
                        showCNMessage(superView: self.view, msg: "Ошибка изменения счета ученика: \(pupil.fullName)", isTableView: false)
                    }
                    return
                }
                
                
                self.savePupil(pupil: tpupil)
                
                
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                    showCNMessage(superView: self.view, msg: "Счет успешно изменен", isTableView: false)
                }
                
            }
            
            
        }
    }
    
    
    
    
    
    
    func deletePupilFromGroup(pupil: TPupil, indexPath: IndexPath){
       
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        
        self.db.collection("users").document(pupil.id).updateData(["group":FieldValue.delete()]) { (error) in
            
            DispatchQueue.main.async {
                hideActivityIndetificator()
            }
            
            if error != nil{
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Ошибка изменения счета ученика: \(pupil.fullName)", isTableView: false)
                }
                return
            }

            DispatchQueue.main.async {
                self.pupils.remove(at: indexPath.row)
                self.collectionView.reloadData()
                showCNMessage(superView: self.view, msg: "Ученик успешно удален", isTableView: false)
            }
            
        }
        }
        
    }
    
    
    
    
    
    
}
