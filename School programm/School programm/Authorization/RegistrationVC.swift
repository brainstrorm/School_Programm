//
//  RegistrationVC.swift
//  School programm
//
//  Created by Nikola on 22/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit

class RegistrationVC: UIViewController {
    
    
    @IBOutlet weak var TF1: UIButton!{
        didSet{
            self.TF1.layer.borderColor = #colorLiteral(red: 0, green: 0.631372549, blue: 0.9176470588, alpha: 1)
            self.TF1.layer.borderWidth = 1
            self.TF1.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var TF2: UIButton!{
        didSet{
            self.TF2.layer.borderColor = #colorLiteral(red: 0, green: 0.631372549, blue: 0.9176470588, alpha: 1)
            self.TF2.layer.borderWidth = 1
            self.TF2.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var TF3: UIButton!{
        didSet{
            self.TF3.layer.borderColor = #colorLiteral(red: 0, green: 0.631372549, blue: 0.9176470588, alpha: 1)
            self.TF3.layer.borderWidth = 1
            self.TF3.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var TF4: UIButton!{
        didSet{
            self.TF4.layer.borderColor = #colorLiteral(red: 0, green: 0.631372549, blue: 0.9176470588, alpha: 1)
            self.TF4.layer.borderWidth = 1
            self.TF4.layer.cornerRadius = 10
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as? RegistrationFormVC
        
        if segue.identifier == "1"{
            destinationVC?.role = Role.ученик
            destinationVC?.russianRole = russianRole.ученик
        }else if segue.identifier == "2"{
            destinationVC?.role = Role.преподаватель
            destinationVC?.russianRole = russianRole.преподаватель
        }else if segue.identifier == "3"{
            destinationVC?.role = Role.родитель
            destinationVC?.russianRole = russianRole.родитель
        }else{
            destinationVC?.role = Role.администратор
            destinationVC?.russianRole = russianRole.администратор
        }
    }
    
}

