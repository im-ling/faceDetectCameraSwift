//
//  ViewController.swift
//  myCameraDemoSwift3
//
//  Created by NowOrNever on 18/07/2017.
//  Copyright © 2017 Focus. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI(){
        let button = UIButton.init(type: .contactAdd)
        button.addTarget(self, action:#selector(buttonFunction), for: .touchUpInside);
        self.view.addSubview(button)
        button.center = self.view.center
    }
    
    @objc func buttonFunction() {
        let vc = AVCaptureVideoPicViewController()
        present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

