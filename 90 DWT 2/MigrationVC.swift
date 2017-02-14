////
////  MigrationVC.swift
////
////  Created by Tim Roadley on 30/09/2015.
////  Copyright © 2015 Tim Roadley. All rights reserved.
////
//
//import UIKit
//
//class MigrationVC: UIViewController {
//
//    @IBOutlet var label: UILabel!
//    @IBOutlet var progressView: UIProgressView!    
//
//    // MARK: - MIGRATION
//    func progressChanged (note:AnyObject?) {
//        if let _note = note as? NSNotification {
//            if let progress = _note.object as? NSNumber {
//                let progressFloat:Float = round(progress.floatValue * 100)
//                let text = "Migration Progress: \(progressFloat)%"
//                print(text)
//
//                dispatch_async(dispatch_get_main_queue(), {                
//                    self.label.text = text
//                    self.progressView.progress = progress.floatValue
//                })
//            } else {print("\(#function) FAILED to get progress")}
//        } else {print("\(#function) FAILED to get note")}
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MigrationVC.progressChanged(_:)), name: "migrationProgress", object: nil)
//    }
//    
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: "migrationProgress", object: nil)
//    }
//}
