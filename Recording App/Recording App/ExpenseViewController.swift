//
//  ExpenseViewController.swift
//  Recording App
//
//  Created by Praveen Kumar U on 28/07/18.
//  Copyright © 2018 Praveen Kumar U. All rights reserved.
//

import Foundation
import UIKit

class ExpenseViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    
    var location = String()
    var itemName = String()
    var category = String()
    var quantity = String()
    var price = String()
    var amount = String()
    var dismissProtocol : DismissProtocol?
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneTapped))
    }
    
    @objc func handleDoneTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
        self.dismissProtocol?.informDismissAction()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell?.selectionStyle = .none
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell?.textLabel?.textAlignment = .left
        cell?.detailTextLabel?.textAlignment = .right
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "Expense Category"
            cell?.detailTextLabel?.text = category
            break
            
        case 1:
            cell?.textLabel?.text = "Hotel Name: "
            cell?.detailTextLabel?.text = location
        
        case 2:
            cell?.textLabel?.text = "Item Name"
            cell?.detailTextLabel?.text = itemName
            break
        
        case 3:
            cell?.textLabel?.text = "Item Quantity"
            cell?.detailTextLabel?.text = quantity
            break
            
        case 4:
            cell?.textLabel?.text = "Price"
            cell?.detailTextLabel?.text = price
            break
        
        case 5:
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell?.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell?.textLabel?.text = "Amount"
            cell?.detailTextLabel?.text = amount
            break
            
        default:
            break
        }
        
        return cell!
    }
    
    
    func setupTableView()
    {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        var constraints = [NSLayoutConstraint]()
        
        let views = ["tableView" : tableView]
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
}
