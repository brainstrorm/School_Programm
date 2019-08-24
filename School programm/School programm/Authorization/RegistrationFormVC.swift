//
//  RegistrationFormVC.swift
//  School programm
//
//  Created by Nikola on 22/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class RegistrationFormVC: UIViewController {
    
    
    @IBOutlet weak var name: UITextField!{
        didSet{
            self.name.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.8666666667, blue: 0.2, alpha: 1)
            self.name.layer.borderWidth = 1
            self.name.layer.cornerRadius = 10
            self.name.applyPadding()
        }
    }
    @IBOutlet weak var surname: UITextField!{
        didSet{
            self.surname.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.8666666667, blue: 0.2, alpha: 1)
            self.surname.layer.borderWidth = 1
            self.surname.layer.cornerRadius = 10
            self.surname.applyPadding()
        }
    }
    @IBOutlet weak var pathronimic: UITextField!{
        didSet{
            self.pathronimic.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.8666666667, blue: 0.2, alpha: 1)
            self.pathronimic.layer.borderWidth = 1
            self.pathronimic.layer.cornerRadius = 10
            self.pathronimic.applyPadding()
        }
    }
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
    @IBOutlet weak var repeatedPassword: UITextField!{
        didSet{
            self.repeatedPassword.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.8666666667, blue: 0.2, alpha: 1)
            self.repeatedPassword.layer.borderWidth = 1
            self.repeatedPassword.layer.cornerRadius = 10
            self.repeatedPassword.applyPadding()
        }
    }
    
    @IBOutlet weak var enterBtn: UIButton!{
        didSet{
            self.enterBtn.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var label: UILabel!
    
    
    let db = Firestore.firestore()
    
    var role = ""
    var russianRole = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Закрытие клавиятуры при нажатии на экран или свайпе вниз
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDown.direction = .down
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeDown)
        
        
        label.text = "Авторизация \(russianRole)"
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func enterAction(_ sender: Any) {
        
        
        if repeatedPassword.text != password.text{
            showCNMessage(superView: self.view, msg: "Не правильно ввели повторный пароль", isTableView: false)
        }
        
        if !email.text!.contains("@"){
            showCNMessage(superView: self.view, msg: "Не правильно ввели почту", isTableView: false)
        }
        
        
        if !(surname.text != "" && password.text != "" && name.text != "" && pathronimic.text != "" && repeatedPassword.text != "" && email.text != ""){
            
            showCNMessage(superView: self.view, msg: "Заполните все данные", isTableView: false)
        }
        
        
        registration()
    }
    
    
    // MARK: Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    
    
    
    
    func registration(){
        

        showActivityIndetificator(superView: self.view, isTableView: false) // включаем загрузочный индетификатор
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            
            hideActivityIndetificator()
            
            if error != nil{
                showCNMessage(superView: self.view, msg: error!.localizedDescription, isTableView: false)
                return
            }
            
            guard let userId = user?.user.uid else{
                showCNMessage(superView: self.view, msg: "Ошибка userId", isTableView: false)
                return
            }
            
            let userInformation: [String:String] = ["name": self.name.text!, "surname": self.surname.text!, "email": self.email.text!, "password": self.password.text!, "pathronimic": self.pathronimic.text!, "role": self.role, "userId": userId]
            
            
            self.db.collection("users").document(userId).setData(userInformation, completion: { (error) in
                
                if error != nil{
                    showCNMessage(superView: self.view, msg: error!.localizedDescription, isTableView: false)
                    return
                }
                
                showCNMessage(superView: self.view, msg: "Успешно зарегистрированы", isTableView: false)
                
                // init data to local base
                User.root.phoneInit(data: userInformation)
                
                // move to view controller
                loginToRole(roleType: User.root.role!)
            })
        }
    }
}
