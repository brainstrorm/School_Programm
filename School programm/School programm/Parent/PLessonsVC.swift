//
//  LessonsVC.swift
//  School programm
//
//  Created by Nikola on 23/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit

class PLessonsVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    var date: String = ""
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var lessonsForThisDate: [PLesson] = []
    
    var pupil: PPupil = PPupil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lessonsForThisDate = pupil.getSortedLessonsBy(date: date)
        titleLabel.text = date
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonsForThisDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = lessonsForThisDate[indexPath.row].name
        return cell!
    }
}
