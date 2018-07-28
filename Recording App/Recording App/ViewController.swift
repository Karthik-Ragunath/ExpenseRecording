//
//  ViewController.swift
//  Recording App
//
//  Created by Praveen Kumar U on 28/07/18.
//  Copyright © 2018 Praveen Kumar U. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var recordButton = UIButton()
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.white
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Record", for: .normal)
        recordButton.backgroundColor = UIColor.gray
        recordButton.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        self.view.addSubview(recordButton)
        
        let viewsDict = ["record": recordButton]
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-350-[record(50)]", options: [], metrics: nil, views: viewsDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[record(200)]", options: [], metrics: nil, views: viewsDict))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func startRecord()
    {
        self.navigationController?.pushViewController(RecordingViewController(), animated: true)
    }

}

