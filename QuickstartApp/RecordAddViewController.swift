//
//  RecordAddViewController.swift
//  QuickstartApp
//
//  Created by PRAE on 2/27/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit

protocol RecordAddViewControllerDelegate {
    func onClickBtnSaveNewRecord(vc:RecordAddViewController, didAddRecord array:[String])
}

class RecordAddViewController: UITableViewController {

    var headerArray =  [String]()
   
    var delegate : RecordAddViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Record"
        self.view.backgroundColor = UIColor.white
        
        let saveButton = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(onClickBtnSave(sender:))
        )
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func loadData(headerArray : [String]) {
        self.headerArray = headerArray
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
            array.append(subview.text!)
        }
        
        var reversedArray : [String] = array.reversed()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss"
        let dateString = dateFormatter.string(from: date)
        reversedArray.append(dateString)
        reversedArray.append(dateString)
        self.delegate?.onClickBtnSaveNewRecord(vc:self, didAddRecord:reversedArray)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return headerArray.count - 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RecordAddViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecordAddViewCell  else {
            fatalError("The dequeued cell is not an instance of SpreadTableViewCell.")
        }
        
        let fieldName = headerArray[indexPath.row]
        cell.labelFieldName.text = fieldName
        cell.imageRecordAdd.image = UIImage(named: "record_add")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // called when user taps on some row
    }
}
