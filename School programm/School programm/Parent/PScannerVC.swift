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

class PScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    
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
                    
                    if explainQRCode(string: object.stringValue!).type == scanType.ребенок{
                        
                        let alert = UIAlertController(title: "Подключить ребенка?", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Подключить", style: .default, handler: { (action) in
                            self.connectPupil(pupil: explainQRCode(string: object.stringValue!).id)
                        }))
                        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                        
                    }
                }
            }
        }
    }
    
    
    
    
    func connectPupil(pupil: String){
        showActivityIndetificator(superView: self.view, isTableView: false)
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
        self.db.collection("users").document(pupil).updateData(["parentId": Parent.parent.userId!]) { (error) in
            
            DispatchQueue.main.async {
                hideActivityIndetificator()
            }
            
            if error != nil{
                DispatchQueue.main.async {
                    showCNMessage(superView: self.view, msg: "Ошибка подключения к ребенку", isTableView: false)
                }
                return
            }
            DispatchQueue.main.async {
                showCNMessage(superView: self.view, msg: "Вы успешно подключили ребенка", isTableView: false)
            }
        }
        }
    }
    
}
