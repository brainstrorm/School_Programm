//
//  MakeLessonsVC.swift
//  School programm
//
//  Created by Nikola on 27/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import FirebaseFirestore


class MakeLessonsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateOfLessons: UITextField!{
        didSet{
            self.dateOfLessons.isEnabled = true
        }
    }
    @IBOutlet weak var jonyTitle: UILabel!
    
    var date = ""
    var jtitle = ""
    var lessons: [TLesson] = []
    var group: Group = Group()
    var groupId: String = ""
    
    
    let db = Firestore.firestore()
    
    private let datePicker = UIDatePicker()
    private var doneBtnForPicker = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // создаем наблюдателя по открытию/закрытию клавиатуры
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWasShown(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWasHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        
        
        jonyTitle.text = jtitle
        dateOfLessons.text = date
        
        
        // Добавляем детектор касания
        tableView.keyboardDismissMode = .onDrag
        
        
        let tapDate = UITapGestureRecognizer(target: self, action: #selector(dateHasBeenTouched(tap:)))
        self.dateOfLessons.addGestureRecognizer(tapDate)
        
        setupDoneButton()
        setupPicker()
    }
    

    
    @IBAction func plusAction(_ sender: Any) {
        showInputDialog()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    // Кнопка поменть дату
    @IBAction func saveDay(_ sender: Any) {
        self.changeDateOfLessons(date: dateOfLessons.text!)
    }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Удалить все занятия на сегодня?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { (alert) in
                
                self.deleteLessons()
                
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = lessons[indexPath.row].name
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let kCellActionWidth: CGFloat = 65
        let kActionImageSize: CGFloat = 34
        
        let whitespace = whitespaceString(width: kCellActionWidth)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kCellActionWidth, height: 65))
        view.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: CGRect(x: (kCellActionWidth - kActionImageSize) / 2,
                                                  y: (65 - kActionImageSize) / 2,
                                                  width: kActionImageSize,
                                                  height: kActionImageSize))
        
        
        
        let deleteAction = UITableViewRowAction(style: .normal, title: whitespace) { (rowAction, indexPath) in
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Вы уверены, что хотите удалить урок?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { (alert) in
                    self.deleteOneLesson(lesson: self.lessons[indexPath.row], indexPath: indexPath)
                }))
                alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        
        
        // create a color from patter image and set the color as a background color of action
        var image = view.image()
        imageView.image = UIImage(named: "delete")
        view.addSubview(imageView)
        image = view.image()
        
        
        deleteAction.backgroundColor = UIColor(patternImage: image)
        
        return [deleteAction]
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    
    
    
    
    func showInputDialog(){
        
        DispatchQueue.main.async {
        
            let alert = UIAlertController(title: "Введите название предмета", message: nil, preferredStyle: .alert)
            
            
            alert.addTextField { (textField) in
                textField.placeholder = "Название предмета"
                textField.keyboardType = .default
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { [weak alert] (_) in
                
                let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                let text = textField.text
                
                if text == ""{
                    showCNMessage(superView: self.view, msg: "Введите значение", isTableView: false)
                    return
                }
                
                // Firebase action
                self.makeNewLesson(name: text!, date: self.dateOfLessons.text!)
                
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    
    
    
    // PickerView
    
    
    
    private func setupPicker()  {
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.minimumDate = Date()
        
        datePicker.addTarget(self, action: #selector(pickerChanged), for: UIControl.Event.primaryActionTriggered)
        datePicker.backgroundColor = UIColor.white
        datePicker.date = Date.calculateDate(from: dateOfLessons.text!)
        
        
        dateOfLessons.inputView = datePicker
    }
    
    
    private func setupDoneButton(){
        // Кнопка Готово для startпикера
        doneBtnForPicker = UIButton(frame: CGRect(x: 0, y: view.frame.size.height, width: self.view.bounds.size.width, height: 44))
        doneBtnForPicker.backgroundColor = #colorLiteral(red: 0.139916122, green: 0.4779110551, blue: 0.655868113, alpha: 1)
        doneBtnForPicker.setTitle("Готово", for: .normal)
        doneBtnForPicker.titleLabel?.font = UIFont(name: "Helvetica Neue Bold", size: 20)
        doneBtnForPicker.addTarget(self, action: #selector(closeKeybord), for: .touchUpInside)
        self.view.addSubview(doneBtnForPicker)
    }
    
    @objc private func dateHasBeenTouched(tap: UITapGestureRecognizer) {
        dateOfLessons.becomeFirstResponder()
    }
    
    @objc func closeKeybord(){
        view.endEditing(true)
    }
    
    @objc private func pickerChanged(sender: UIDatePicker) {
        dateOfLessons.text = Date.stringFromDate(from: sender.date)
    }
    
    
    
    // #MARK: Keyboard
    
    @objc private func keyboardWasShown(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.doneBtnForPicker.frame.origin.y = self.view.frame.size.height - notification.keyboardHeight() - 44
        }, completion: nil)
    }
    
    
    
    
    @objc private func keyboardWasHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.doneBtnForPicker.frame.origin.y = self.view.frame.size.height
        }, completion: nil)
    }
    
    
    
    // MARK Firebase
    
    
    
    func makeNewLesson(name: String, date: String){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let randId = self.db.collection("lessons").document().documentID
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            
            let lessonData: [String: Any] = ["name": name, "group": self.groupId, "date": date, "number": self.lessons.count]
            
            self.db.collection("lessons").document(randId).setData(lessonData, completion: { (error) in
                
                DispatchQueue.main.async {
                    hideActivityIndetificator()
                }
                
                if error != nil{
                    DispatchQueue.main.async {
                        showCNMessage(superView: self.view, msg: "Ошибка удаления данных", isTableView: false)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Новый урок успешно создан", isTableView: false)
                    let lesson = TLesson(lesson: lessonData, id: randId)
                    self.saveLesson(lesson: lesson)
                    self.tableView.reloadData()
                }
                
            })
        }
    }
    
    
    
    
    
    
    func changeDateOfLessons(date: String){
        
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        
        for lesson in lessons{
            
            let queue = DispatchQueue.global(qos: .utility)
            queue.async{
                
                self.db.collection("lessons").document(lesson.id).updateData(["date": date], completion: { (error) in

                    if lesson.id == self.lessons.last?.id{
                        DispatchQueue.main.async {
                            hideActivityIndetificator()
                        }
                    }
                    
                    if error != nil{
                        DispatchQueue.main.async {
                            showCNMessage(superView: self.view, msg: "Ошибка загрузки данных", isTableView: false)
                        }
                        return
                    }
                    
                    
                    if lesson.id == self.lessons.last?.id{
                        DispatchQueue.main.async {
                            showCNMessage(superView: self.view, msg: "Дата успешно изменена", isTableView: false)
                            self.jonyTitle.text = date
                        }
                    }
                    
                })
            }
            
        }
        
        
    }
    
    
    
    
    func deleteOneLesson(lesson: TLesson, indexPath: IndexPath){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            
            self.db.collection("lessons").document(lesson.id).delete { (error) in
                
                DispatchQueue.main.async {
                    hideActivityIndetificator()
                }
                
                if error != nil{
                    DispatchQueue.main.async {
                        showCNMessage(superView: self.view, msg: "Ошибка удаления уроков", isTableView: false)
                    }
                    return
                }
                
                
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Урок успешно удален", isTableView: false)
                    self.lessons.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    
    
    func deleteLessons(){
        
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        
        for lesson in lessons{
            
            let queue = DispatchQueue.global(qos: .utility)
            queue.async{
                
                self.db.collection("lessons").document(lesson.id).delete { (error) in
                    
                    if lesson.id == self.lessons.last?.id{
                        DispatchQueue.main.async {
                            hideActivityIndetificator()
                        }
                    }
                    
                    if error != nil{
                        DispatchQueue.main.async {
                            showCNMessage(superView: self.view, msg: "Ошибка удаления уроков", isTableView: false)
                        }
                        return
                    }
                    
                    
                    if lesson.id == self.lessons.last?.id{
                        DispatchQueue.main.async {
                            showCNMessage(superView: self.view, msg: "Уроки успешно удалены", isTableView: false)
                            self.lessons.removeAll()
                            self.tableView.reloadData()
                        }
                    }
 
                }
            }
            
        }
    }
        
    
    func saveLesson(lesson: TLesson){
        if let row = lessons.firstIndex(where: {$0.id == lesson.id}) {
            self.lessons[row] = lesson
        }else{
            self.lessons.append(lesson)
        }
    }

    
    func deleteLesson(lesson: TLesson, groupId: String){
        if let row2 = lessons.firstIndex(where: {$0.id == lesson.id}) {
            lessons.remove(at: row2)
        }
    }
    
}







extension NSNotification{
    func keyboardHeight() -> CGFloat{
        let info = self.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        return keyboardFrame.height
    }
}
