//
//  SpreadsTableViewController.swift
//  QuickstartApp
//
//  Created by PRAE on 2/25/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit

class GSpreadSheet: NSObject, NSCoding {
    
    var name: String
    var sheetID : String
    
    init(name: String, sheetID: String) { //  remove from constructor
        self.name = name
        self.sheetID = sheetID
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let sheetid = aDecoder.decodeObject(forKey: "sheetID") as! String
        let sheetname = aDecoder.decodeObject(forKey: "name") as! String
        self.init(name: sheetname, sheetID: sheetid)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sheetID, forKey : "sheetID")
        aCoder.encode(name, forKey: "name")
        
    }
}

class GSheet: NSObject {
    
    
    
    var sheetName: String
    var sheetID : NSNumber
    
    init(sheetName: String, sheetID: NSNumber) { //  remove from constructor
        self.sheetName = sheetName
        self.sheetID = sheetID
    }
    
   
}

protocol SpreadsTableViewControllerDelegate {
    
    func onClickSpread(vc:SpreadsTableViewController, didSelectSpread spread:GSpreadSheet)
    func onClickAddFav(vc:SpreadsTableViewController, didSelectSpread spread:GSpreadSheet)
    func onClickRemoveFav(vc:SpreadsTableViewController, didSelectSpread spread:GSpreadSheet)
}


class SpreadsTableViewController: UITableViewController {

    var mCountOfSheets : Int = 0
    var mSpreadSheetList = [GSpreadSheet]()
    var favList = [GSpreadSheet] ()
    var delegate : SpreadsTableViewControllerDelegate?
    
    
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
        let cellIdentifier = "SpreadTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SpreadTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SpreadTableViewCell.")
        }
        let spreadName = mSpreadSheetList[indexPath.row].name
        cell.labelSpread.text = spreadName
        cell.imageSpread.image = UIImage(named: "spread")
        
        if self.isContainsInFavList(spread:mSpreadSheetList[indexPath.row]) {
            //  cell.buttonFav.setTitle("-", for: UIControlState.normal )
            
            let image1 = UIImage(named: "fav_normal")
            cell.buttonFav.setImage(image1, for: UIControlState.normal)
        }else{
            // cell.buttonFav.setTitle("+", for: UIControlState.normal )
            
            let image1 = UIImage(named: "fav_not")
            cell.buttonFav.setImage(image1, for: UIControlState.normal)
        }
        
        cell.buttonFav.tag = indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.onClickSpread(vc: self, didSelectSpread: (self.mSpreadSheetList[indexPath.row]))
    }

    func loadArray(spreadList: [GSpreadSheet]) {
        self.mSpreadSheetList = spreadList
        self.tableView.reloadData()
    }
    
    
    func loadFavArray(favList: [GSpreadSheet]) {
        self.favList = favList
        self.tableView.reloadData()
    }
    
    
    @IBAction func addToFav(_ sender: UIButton) {
        let cell = self.tableView.cellForRow(at: NSIndexPath.init(row: sender.tag, section: 0) as IndexPath) as! SpreadTableViewCell
        
        if self.isContainsInFavList(spread: self.mSpreadSheetList[sender.tag]) == true {
            favList.append(self.mSpreadSheetList[sender.tag])
            self.delegate?.onClickRemoveFav(vc: self, didSelectSpread: (self.mSpreadSheetList[sender.tag]))
            self.tableView.reloadData()
        }
        else {
            self.removeSpreadFromFav(spread: self.mSpreadSheetList[sender.tag])
            self.delegate?.onClickAddFav(vc: self, didSelectSpread: (self.mSpreadSheetList[sender.tag]))
            self.tableView.reloadData()
        }
        
    }
    
    func isContainsInFavList(spread: GSpreadSheet) -> Bool
    {
        for item in favList{
            if item.sheetID == spread.sheetID
            {    return true }
        }
        return false
    }
    
    func removeSpreadFromFav(spread : GSpreadSheet)
    {
        for index in 0 ..< favList.count {
            let item = favList[index]
            if item.sheetID == spread.sheetID{
                if favList.count > index {
                    favList.remove(at: index)
                    break
                }
                return
            }
        }
    }
}
