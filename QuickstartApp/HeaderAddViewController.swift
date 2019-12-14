//
//  HeaderAddViewController.swift
//  QuickstartApp
//
//  Created by PRAE on 2/28/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit
protocol HeaderAddViewControllerDelegate {
    func onClickBtnSaveHeaderRecord(vc:HeaderAddViewController, didAddRecord array:[String])
}



class HeaderAddViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    var delegate : HeaderAddViewControllerDelegate?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fieldNameTextField: UITextField!

    var fields: [String] = []
    
    
    let cellReuseIdentifier = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    
        tableView.delegate = self
        tableView.dataSource = self
        
        let saveButton = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(onClickBtnSave(sender:))
        )
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.title = "Add Fields"
        
        
    }
    
    @IBAction func onBtnAddNew(_ sender: UIButton) {
        if self.fieldNameTextField.text!.isEmpty {
        } else{
            
            tableView.beginUpdates()
            let newIndexPath = IndexPath(row: fields.count, section: 0)
            fields.append(self.fieldNameTextField.text!)
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            self.tableView.endUpdates()
            
            self.fieldNameTextField.text = ""
        }
    }

    func onClickBtnSave(sender: UIBarButtonItem) {
        self.delegate?.onClickBtnSaveHeaderRecord(vc:self, didAddRecord:self.fields)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fields.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.fields[indexPath.row]
        
        return cell
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            tableView.beginUpdates()
            fields.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
}

