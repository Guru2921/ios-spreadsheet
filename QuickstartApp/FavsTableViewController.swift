//
//  FavsTableViewController.swift
//  QuickstartApp
//
//  Created by PRAE on 3/10/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit


protocol FavsTableViewControllerDelegate {
    
    func onClickFavorites(vc:FavsTableViewController, didSelectSpread spread:GSpreadSheet)
    
}


class FavsTableViewController: UITableViewController {
    
    var mCountOfSheets : Int = 0
    var mSpreadSheetList = [GSpreadSheet]()
    var delegate : FavsTableViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
    }
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mSpreadSheetList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavTableViewCell  else {
            fatalError("The dequeued cell is not an instance of FavTableViewCell.")
        }
        let spreadName = mSpreadSheetList[indexPath.row].name
        cell.labelFav.text = spreadName
        cell.imageFav.image = UIImage(named: "spread")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.onClickFavorites(vc: self, didSelectSpread: (self.mSpreadSheetList[indexPath.row]))
    }
    
    func loadArray(spreadList: [GSpreadSheet]) {
        self.mSpreadSheetList = spreadList
        self.tableView.reloadData()
    }
    
}

