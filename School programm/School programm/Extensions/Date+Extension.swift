//
//  ChackDate.swift
//  Quarta Panel
//
//  Created by Nikola on 12/06/2019.
//  Copyright © 2019 serbionare. All rights reserved.
//

import UIKit


extension Date {

    static func calculateDate(from date: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let calculateDate = formatter.date(from: date) ?? Date()
        return calculateDate
    }
    
    
    static func stringFromDate(from date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        return formatter.string(from: date)
    }
    
    static func getTodayStringDate() -> String{
        let currentDate = Date()
        return stringFromDate(from: currentDate)
    }
}

