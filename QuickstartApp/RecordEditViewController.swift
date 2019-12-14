//
//  RecordEditViewController.swift
//  QuickstartApp
//
//  Created by PRAE on 2/26/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit
protocol RecordEditViewControllerDelegate {
    func onClickBtnSaveEditRecord(vc:RecordEditViewController, didEditRecord array:[String])
}
class RecordEditViewController: UITableViewController {

    var headerArray =  [String]()
    var array = [String] ()
    
    var delegate : RecordEditViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Record"
        self.view.backgroundColor = UIColor.white
        
        let saveButton = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(onClickBtnSave(sender:))
        )
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func loadData(headerArray : [String], array : [String]) {
        self.headerArray = headerArray
        self.array = array
        
    }
    
    private func getSubviewsOf<T : UIView>(view:UIView) -> [T] {
        var subviews = [T]()
        
        for subview in view.subviews {
            subviews += getSubviewsOf(view: subview) as [T]
            
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        
        return subviews
    }
    
    func isAbleToSave() -> Bool {
        let allSubviews : [UITextField] = self.getSubviewsOf(view: self.view)
        for subview in allSubviews {
            let textField = subview as UITextField
            if (textField.text?.count)! > 0 {
                return true;
            }
        }
        return false;
    }
    
    func onClickBtnSave(sender: UIBarButtonItem) {
        var array = [String]()
        if isAbleToSave() == false {
            return
        }
        let allSubviews : [UITextField] = self.getSubviewsOf(view: self.view)
        for subview in allSubviews {
            if subview.isEnabled {
                array.append(subview.text!)
            }
        }
        
        var reversedArray : [String] = array.reversed()
        reversedArray.append("")
        reversedArray.append("")
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss"
        let dateString = dateFormatter.string(from: date)
        
        let upIndex : Int = headerArray.firstIndex(of: "UpdatedAt")!
        let crIndex : Int = headerArray.firstIndex(of: "CreatedAt")!
        if self.array.count > crIndex {
            if self.array[crIndex] == "" {
                reversedArray[crIndex] = dateString
            }
            else {
                reversedArray[crIndex] = self.array[crIndex]
            }
        }
        else{
            reversedArray[crIndex] = dateString
        }
        if self.array.count > upIndex {
            if reversedArray.count > upIndex
            {
                reversedArray[upIndex] = dateString
            }
        }
        else {
            if(reversedArray.count > upIndex)
            {
                reversedArray[upIndex] = dateString
            }
        }
        self.delegate?.onClickBtnSaveEditRecord(vc:self, didEditRecord:reversedArray)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return headerArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RecordEditViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecordEditViewCell  else {
            fatalError("The dequeued cell is not an instance of RecordEditViewCell.")
        }
        let fieldName = headerArray[indexPath.row]
        var fieldValue = ""
        if array.count > indexPath.row {
            fieldValue = array[indexPath.row]
        }
        else
        {
            fieldValue = ""
        }
        if fieldName == "CreatedAt" || fieldName == "UpdatedAt" {
            cell.textEditField.isEnabled = false;
            cell.imageEditField.image = UIImage(named: "calendar")
        }
        else {
            cell.textEditField.isEnabled = true;
            cell.imageEditField.image = UIImage(named: "record_edit")
        }
        cell.labelEditField.text = fieldName
        cell.textEditField.text = fieldValue
        
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // called when user taps on some row
    }
}
