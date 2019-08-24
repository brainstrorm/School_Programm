//
//  ActivityInditificator.swift
//  Quarta Panel
//
//  Created by Nikola on 12/06/2019.
//  Copyright © 2019 serbionare. All rights reserved.
//

import UIKit

private var activityView:UIView!

func showActivityIndetificator(superView : UIView, isTableView: Bool){
    
    if (activityView?.superview) != nil{
        return
    }
    
    
    var yPosition: CGFloat = 0.0
    var xPosition: CGFloat = 0.0
    
    let size:CGFloat = 100
    
    var activityViewMinusYPosition: CGFloat = size
    
    if isTableView == false {
        activityViewMinusYPosition = size/2
    }
    
    activityView = UIView(frame: CGRect(x: superView.frame.size.width/2-size/2, y: superView.frame.size.height/2-activityViewMinusYPosition, width: size, height: size))
    activityView.backgroundColor = .white
    
    activityView.layer.cornerRadius = 20
    activityView.clipsToBounds = true
    
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = activityView.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    yPosition = size/2 - activityIndicatorView.frame.size.width/2
    xPosition = size/2 - activityIndicatorView.frame.size.width/2
    
    activityIndicatorView.frame.origin = CGPoint(x: xPosition, y: yPosition)
    activityIndicatorView.color = .white
    activityIndicatorView.startAnimating()
    
    activityView.addSubview(blurEffectView)
    activityView.addSubview(activityIndicatorView)
    superView.addSubview(activityView)
}

func hideActivityIndetificator(){
    if (activityView?.superview) == nil{
        return
    }
    
    activityView.removeFromSuperview()
}
