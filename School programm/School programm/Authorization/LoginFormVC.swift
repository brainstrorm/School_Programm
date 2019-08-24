//
//  LoginFormVC.swift
//  School programm
//
//  Created by Nikola on 22/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class LoginFormVC: UIViewController {
    
    
    
    @IBOutlet weak var email: UITextField!{
        didSet{
            self.email.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.8666666667, blue: 0.2, alpha: 1)
            self.email.layer.borderWidth = 1
            self.email.layer.cornerRadius = 10
            self.email.applyPadding()
        }
    }
    
    @IBOutlet weak var password: UITextField!{
        didSet{
            self.password.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.8666666667, blue: 0.2, alpha: 1)
            self.password.layer.borderWidth = 1
            self.password.layer.cornerRadius = 10
            self.password.applyPadding()
        }
    }
    @IBOutlet weak var enterBtn: UIButton!{
        didSet{
            self.enterBtn.layer.cornerRadius = 10
        }
    }

    @IBOutlet weak var label: UILabel!
    
    let db = Firestore.firestore()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Закрытие клавиятуры при нажатии на экран или свайпе вниз
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDown.direction = .down
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeDown)
        
        
        label.text = "Авторизация"
    }
    
    
    @IBAction func forgotAction(_ sender: Any) {
        
        if !email.text!.contains("@"){
            showCNMessage(superView: self.view, msg: "Введите корректно эл. почту", isTableView: false)
        }
        
        forgotPassword(email: email.text!)
    }
    
    @IBAction func enterAction(_ sender: Any) {
        login()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    // MARK: Firebase
    
    
    func login() {
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        Auth.auth().signIn(withEmail: email!.text!, password: password!.text!) {user, error in
            
            hideActivityIndetificator()
            
            if error != nil {
                guard let message = error?.localizedDescription else {return}
                showCNMessage(superView: self.view, msg: message, isTableView: false)
                return
            }
            
            guard let userId = user?.user.uid else{
                showCNMessage(superView: self.view, msg: "Ошибка userId", isTableView: false)
                return
            }
            
            // get data from firebase
            self.db.collection("users").document(userId).getDocument{ (document, error) in
                
                if error != nil{
                    guard let message = error?.localizedDescription else {return}
                    showCNMessage(superView: self.view, msg: message, isTableView: false)
                    return
                }
                
                // message
                showCNMessage(superView: self.view, msg: "Успешно авторизованы", isTableView: false)
                
                // save data to phone
                User.root.firebaseInit(document: document)
                
                // move to view controller
                loginToRole(roleType: User.root.role!)
                
            }
        }
    }
    

    
    func forgotPassword(email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil{
                showCNMessage(superView: self.view, msg: "На вашу почту отправлена ссылка для восстановления пароля", isTableView: false)
            }else{
                showCNMessage(superView: self.view, msg: error!.localizedDescription, isTableView: false)
            }
        }
    }
}



