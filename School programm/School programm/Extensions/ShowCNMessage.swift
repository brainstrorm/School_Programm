//
//  ShowCNMessage.swift
//  Quarta Panel
//
//  Created by Nikola on 12/06/2019.
//  Copyright © 2019 serbionare. All rights reserved.
//

import UIKit


func showCNMessage(superView : UIView, msg : String, isTableView: Bool){
    
    
    // Время отображения сообщения
    var alertTimeInterval: TimeInterval = 0.6
    
    
    // Высота сообщения
    var alertHeight: CGFloat = 40
    
    
    // Проверька на монобровь
    var hasMonobrow = false
    
    switch UIDevice.modelName {
    case "iPhone X":
        hasMonobrow = true
    case "iPhone XS":
        hasMonobrow = true
    case "iPhone XS Max":
        hasMonobrow = true
    case "iPhone XR":
        hasMonobrow = true
    default:
        hasMonobrow = false
    }
    
    
    // Провекра на TableView потому что отображене происходит ниже 
    if hasMonobrow && !isTableView{
        alertHeight = 70
        alertTimeInterval = 0.8
    }
    
    
    
    let alertView = UIView(frame: CGRect(x: 0, y: -alertHeight, width: superView.frame.size.width, height: alertHeight))
    alertView.backgroundColor = greenColor
    
    
    let alertLabel = UILabel(frame: CGRect(x: 0, y: alertHeight-40, width: superView.frame.size.width, height: 40))
    alertLabel.backgroundColor = .clear
    alertLabel.textColor = .white
    alertLabel.text = msg
    alertLabel.textAlignment = NSTextAlignment.center
    alertLabel.numberOfLines = 0
    alertLabel.minimumScaleFactor = 0.5
    alertLabel.adjustsFontSizeToFitWidth = true
    
    
    alertView.addSubview(alertLabel)
    superView.addSubview(alertView)
    superView.bringSubviewToFront(alertView)
    
    
    // Плавное отображение сообщения
    UIView.animate(withDuration: alertTimeInterval, delay: 0.0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
        
        alertView.frame.origin.y = 20
        
    }, completion: { (true) in
        
        UIView.animate(withDuration: alertTimeInterval, delay: 2, usingSpringWithDamping: 0.55, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            alertView.frame.origin.y = -alertHeight
            
        }, completion: { (true) in
            alertView.removeFromSuperview()
        })
        
    })
    
}

