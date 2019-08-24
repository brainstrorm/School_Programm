//
//  DaysVC.swift
//  School programm
//
//  Created by Nikola on 23/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit

class DaysVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var groupedLessons: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupedLessons = Pupil.pupil.getGroupedAndSortedDates()
    }
    
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedLessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = groupedLessons[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "LessonsVC", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    // Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "LessonsVC"{
            print("identifier ошибка")
            return
        }
        
        guard let row = sender as? Int else {
            print("row ошибка")
            return
        }
        
        let vc = segue.destination as! LessonsVC
        vc.date = groupedLessons[row]
    }
}
