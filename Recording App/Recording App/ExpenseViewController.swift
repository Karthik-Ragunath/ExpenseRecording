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
        var jsonDict : Dictionary<String,Any> =   Dictionary()
        jsonDict["category_id"] = "817923000000000448"
        jsonDict["currency_id"] = "817923000000000099"
        jsonDict["amount"] = self.amount
        var jsonData : Data?
        var jsonBody : NSString?
        var param = String()
        do
        {
            jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        catch
        {}
        if(jsonData != nil)
        {
            jsonBody = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue)
        }
        if let jsonString = jsonBody, !(jsonString.length == 0)
        {
            jsonBody = jsonString.replacingOccurrences(of: "\n", with: " ") as NSString?
            jsonBody = self.encodeString(string: jsonBody!)
            
            param += "JSONString=" + (jsonBody! as String)
        }
        
        param      +=   "&scope=expenseapi"
        param       =   param.replacingOccurrences(of: "\n", with: "")
        let postData    =   param.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let urlString = "https://expense." + "zoho" + ".com/api/v1/expenses?organization_id=655605203&authtoken=958d81c8647a75c60f18d1bf2585fc3f"
        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue("zbios", forHTTPHeaderField: "X-ZB-Source")
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        session.dataTask(with: request as URLRequest)
        { (data, response, error) in
            if error == nil
            {
                print("Expense created")
            }
            else
            {
                print("Error occured")
            }
            self.dismiss(animated: true, completion: nil)
        }.resume()
//        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
        self.dismissProtocol?.informDismissAction()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func encodeString(string:NSString) -> (NSString)
    {
        let allowedCharSet  =   CharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}&+").inverted
        let result          =   string.addingPercentEncoding(withAllowedCharacters: allowedCharSet)
        return result! as (NSString)
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
