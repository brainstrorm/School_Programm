//
//  AdminPupilsVC.swift
//  School programm
//
//  Created by Nikola on 23/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AdminPupilsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    
    @IBOutlet weak var jonyTitle: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var apupils: [APupil] = []
    var groupId: String = ""
    var jtitle = ""
    
    let db = Firestore.firestore()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        jonyTitle.text = jtitle
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self)
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
        return apupils.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ACollectionViewCell

        let pupil = apupils[indexPath.row]

        cell.labelName.text = pupil.fullName
        cell.labelBill.text = pupil.bill.description

        cell.labelBill.layer.cornerRadius = 4
        
        cell.layer.borderColor = #colorLiteral(red: 0.4980392157, green: 0.8431372549, blue: 0.9843137255, alpha: 1)
        cell.layer.borderWidth = 3

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionViewLayout.collectionView!.frame.size.width/2-6, height: 70)
    }


    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pupil = apupils[indexPath.row]
        showInputDialog(pupil: pupil, indexPath: indexPath)
    }
    
    
    
    

    
    func showInputDialog(pupil: APupil, indexPath: IndexPath){
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

    func pupilsRefresher(group: String){

        let path = db.collection("users").whereField("group", isEqualTo: group)

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
                    let pupil = APupil(id: document.documentID, data: document.data())
                    self.savePupil(pupil: pupil)
                    print("save")
                }

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }

    
    
    func savePupil(pupil: APupil){
        if let row = apupils.firstIndex(where: {$0.id == pupil.id}) {
            apupils[row] = pupil
        }else{
            apupils.append(pupil)
        }
    }
    
    
    
    
    
    func changeCristalsCount(value: Int, isMinus: Bool, pupil: APupil, indexPath: IndexPath){
        
        var apupil = pupil
        var bill = pupil.bill
        
        if isMinus{
            bill-=value
        }else{
            bill+=value
        }
        
        apupil.bill = bill
        
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
            
            
            self.savePupil(pupil: apupil)
            
            
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
                showCNMessage(superView: self.view, msg: "Счет успешно изменен", isTableView: false)
            }
            
        }
        
            
        }
    }
    
    
    
}
