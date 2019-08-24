//
//  Access.swift
//  School programm
//
//  Created by Nikola on 24/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit


// Константы для доступа к базе
enum Role {
    static let ученик = "pupil"
    static let преподаватель = "teacher"
    static let родитель = "parents"
    static let администратор = "administration"
}
enum russianRole {
    static let ученик = "ученик"
    static let преподаватель = "преподаватель"
    static let родитель = "родитель"
    static let администратор = "администратор"
}


enum scanType {
    static let группа = "group"
    static let урок = "lesson"
    static let ребенок = "pupil"
}

enum Status {
    static let present = "present"
    static let notpresent = "notpresent"
    static let respectfull = "respectfull"
}
