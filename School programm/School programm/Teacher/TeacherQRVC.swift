//
//  TeacherQRVC.swift
//  School programm
//
//  Created by Nikola on 27/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit


class TeacherQRVC: UIViewController{
    
    @IBOutlet weak var qrImageView: UIImageView!
    
    var groupId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
        // Здесь вместо userid пишется idгруппы с концовкой 2
        DispatchQueue.main.async {
            self.qrImageView.image = generateQRCode(from: "\(self.groupId)2")
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

}
