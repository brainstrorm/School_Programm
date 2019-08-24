//
//  ScannerVC.swift
//  School programm
//
//  Created by Nikola on 25/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import FirebaseFirestore

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    
    @IBOutlet weak var backBtn: UIButton!
    var video = AVCaptureVideoPreviewLayer()
    
    //Creating session
    let session = AVCaptureSession()
    
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Define capture devcie
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        }
        catch
        {
            showCNMessage(superView: self.view, msg: "Ошибка сканирования", isTableView: false)
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        self.view.bringSubviewToFront(backBtn)
        
        session.startRunning()
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0
        {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if object.type == AVMetadataObject.ObjectType.qr
                {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    session.stopRunning()
                    showActivityIndetificator(superView: self.view, isTableView: false)
                    
                    if explainQRCode(string: object.stringValue!).type == scanType.урок{
                        
                        connectToTheLesson(lesson: explainQRCode(string: object.stringValue!).id)
                        
                    }else if explainQRCode(string: object.stringValue!).type == scanType.группа{
                        
                        if Pupil.pupil.group != ""{
                            
                            let alert = UIAlertController(title: "Вы уже состоите в группе", message: "После подключения к новой группе вам нужно будет переавторизоваться", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Подключить", style: .default, handler: { (action) in
                                self.connectToTheGroup(group: explainQRCode(string: object.stringValue!).id, isNewGroup: false)
                            }))
                            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }else{
                            connectToTheGroup(group: explainQRCode(string: object.stringValue!).id, isNewGroup: true)
                        }
                        
                    }
                }
            }
        }
    }
    
    
    
    
    func connectToTheGroup(group: String, isNewGroup: Bool){
        showActivityIndetificator(superView: self.view, isTableView: false)
        db.collection("users").document(Pupil.pupil.userId!).updateData(["group": group]) { (error) in
            hideActivityIndetificator()
            if error != nil{
                showCNMessage(superView: self.view, msg: "Ошибка подключения к группе", isTableView: false)
                return
            }
            
            Pupil.pupil.group = group
            
            showCNMessage(superView: self.view, msg: "Вы успешно подключены к новой группе", isTableView: false)
            
            if !isNewGroup{
                logOut()
            }
        }
    }
    
    
    func connectToTheLesson(lesson: String){
        showActivityIndetificator(superView: self.view, isTableView: false)
        db.collection("lessons").document(lesson).updateData([Pupil.pupil.userId!: Status.present]) { (error) in
            hideActivityIndetificator()
            if error != nil{
                showCNMessage(superView: self.view, msg: "Ошибка подключения к уроку", isTableView: false)
                return
            }
            
            // refresh Main
            showCNMessage(superView: self.view, msg: "Приветствую на уроке", isTableView: false)
        }
    }
    
}
