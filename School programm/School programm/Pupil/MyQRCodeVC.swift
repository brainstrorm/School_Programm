//
//  MyQRCode.swift
//  School programm
//
//  Created by Nikola on 23/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit

class MyQRCode: UIViewController{
    
    @IBOutlet weak var qrImageView: UIImageView!
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        qrImageView.image = generateQRCode(from: "\(User.root.userId!)3")
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
