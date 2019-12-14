//
//  SheetsTableViewController.swift
//  QuickstartApp
//
//  Created by PRAE on 2/25/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit

protocol SheetsTableViewControllerDelegate {    
    func onClickSheet(vc:SheetsTableViewController, didSelectSheet selectedSheet:GSheet)
    func onClickBtnAddSheet(vc : SheetsTableViewController)
    func onClickDeleteSheet(vc : SheetsTableViewController, didSelectSheet selectedSheet: GSheet)
    func onClickRenameSheet(vc : SheetsTableViewController, didSelectSheet selectedSheet: GSheet)
}


class SheetsTableViewController: UITableViewController {
    
    var mSheetsList = [GSheet]()
    var delegate : SheetsTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.title = "Sections"
        
        let addSheetButton = UIBarButtonItem(
            title: "Add Section",
            style: .plain,
            target: self,
            action: #selector(onClickBtnAddSheet(sender:))
        )
        self.navigationItem.rightBarButtonItem = addSheetButton
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mSheetsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SheetViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SheetViewCell  else {
            fatalError("The dequeued cell is not an instance of SpreadTableViewCell.")
        }
        let sheetName = mSheetsList[indexPath.row].sheetName
        cell.labelSheet.text = sheetName
        cell.imageSheet.image = UIImage(named: "sheet")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // called when user taps on some row
        self.delegate?.onClickSheet(vc: self, didSelectSheet: (self.mSheetsList[indexPath.row]))
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            self.delegate?.onClickDeleteSheet(vc: self, didSelectSheet: (self.mSheetsList[indexPath.row]))
            mSheetsList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        
        let editAction = UITableViewRowAction(style: .normal, title: "Rename") { (rowAction, indexPath) in
            //TODO: edit the row at indexPath here
            self.delegate?.onClickRenameSheet(vc: self, didSelectSheet: (self.mSheetsList[indexPath.row]))
        }
        editAction.backgroundColor = .blue
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            //TODO: Delete the row at indexPath here
            if self.mSheetsList.count > 1 {
                self.delegate?.onClickDeleteSheet(vc: self, didSelectSheet: (self.mSheetsList[indexPath.row]))
                self.mSheetsList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        deleteAction.backgroundColor = .red
        
        
        return [editAction, deleteAction]
    }
    
    func loadArray(sheetsArray: [GSheet]) {
        self.mSheetsList = sheetsArray
        self.tableView.reloadData()
    }
    
    func onClickBtnAddSheet(sender: UIBarButtonItem) {
        self.delegate?.onClickBtnAddSheet(vc: self)
    }
    
}
