//
//  File.swift
//  School programm
//
//  Created by Nikola on 22/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit


extension UITextField{
    
    func applyPadding(width: CGFloat? = 20){
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: width!, height: self.frame.size.height))
        self.leftView = leftView
        self.leftViewMode = .always
    }
}
