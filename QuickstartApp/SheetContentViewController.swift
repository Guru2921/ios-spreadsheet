//
//  SheetContentViewController.swift
//  QuickstartApp
//
//  Created by PRAE on 2/26/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit

protocol SheetRecordsViewControllerDelegate {
    func onClickRecord(vc:SheetRecordsViewController, didSelectRecord recordID:Int)
    func onClickBtnAddRecord(vc : SheetRecordsViewController)
    func onClickDeleteRecord(vc : SheetRecordsViewController, didSelectRecord recordID: Int)
}


class SheetRecordsViewController: UITableViewController {
    
    var records =  [String]()
    var delegate : SheetRecordsViewControllerDelegate?
    var currentSheet = GSheet(sheetName: "", sheetID : 0)
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.title = "Records"
        let addRecordButton = UIBarButtonItem(
            title: "Add Record",
            style: .plain,
            target: self,
            action: #selector(onClickBtnAddRecord(sender:))
        )
        self.navigationItem.rightBarButtonItem = addRecordButton
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return records.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RecordViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecordViewCell  else {
            fatalError("The dequeued cell is not an instance of SpreadTableViewCell.")
        }
        let recordName = records[indexPath.row]
        cell.labelRecord.text = recordName
        cell.imageRecord.image = UIImage(named: "record")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // called when user taps on some row
        self.delegate?.onClickRecord(vc: self, didSelectRecord: (indexPath.row))
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            records.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.delegate?.onClickDeleteRecord(vc: self, didSelectRecord: (indexPath.row))
            
        } else if editingStyle == .insert {
            
        }
    }
    
    func loadRecords(sheet : GSheet, array: [String]) {
        currentSheet = sheet
        self.records = array
        self.tableView.reloadData()
    }
    
    func onClickBtnAddRecord(sender: UIBarButtonItem) {
        self.delegate?.onClickBtnAddRecord(vc: self)
    }
}
