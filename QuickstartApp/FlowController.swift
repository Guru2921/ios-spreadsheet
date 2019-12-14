//
//  FlowController.swift
//  QuickstartApp
//
//  Created by Yevgeniy Vasylenko on 6/27/17.
//  Copyright © 2017 Yevgeniy Vasylenko. All rights reserved.
//
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

// MARK: - Flow controller delegate -

@objc
class FlowController: NSObject, SpreadsTableViewControllerDelegate, SheetsTableViewControllerDelegate, SheetRecordsViewControllerDelegate, RecordEditViewControllerDelegate,RecordAddViewControllerDelegate,
    HeaderAddViewControllerDelegate, GoogleLoginDelegate, MainTabControllerDelegate,
    FavsTableViewControllerDelegate,
UINavigationControllerDelegate,UITabBarControllerDelegate {
    
  
    
    
    let nc: UINavigationController
    
    var mainTabController = MainTabController()
    var spreadsMainView = SpreadsTableViewController()
    var favsMainView = FavsTableViewController()
    var spreadsView = SpreadsTableViewController()
    var sheetsView = SheetsTableViewController()
    var recordsView = SheetRecordsViewController()
    var recordEditView = RecordEditViewController()
    var recordAddView = RecordAddViewController()
    var headerAddView = HeaderAddViewController()
    let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
    
    //variabls selection status
    var selectedSpread = GSpreadSheet(name: "", sheetID: "")
    var selectedSheet = GSheet(sheetName: "", sheetID: 0)
    var selectedRecord = Int ()
    
    var googleService: GTLRSheetsService?
    var spreadModel : SpreadModel!
    
    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: "name")
        }
        
        set(newName) {
            if let newName = newName {
                UserDefaults.standard.set(newName, forKey: "name")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "name")
            }
        }
    }
    var google = GoogleLogin()
    var loggedOut = false

    init(navigationController: UINavigationController) {
        
        self.nc = navigationController
        super.init()

        //spreadSelect
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(significantTimeChange(notification:)),
                                               name: NSNotification.Name.UIApplicationSignificantTimeChange,
                                               object: nil)


        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground(notification:)),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil);
        
        self.nc.delegate = self
        self.recordEditView.delegate = self
        self.recordAddView.delegate = self
        self.headerAddView.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
    
    @objc func significantTimeChange(notification: Notification) {
       
    }
    
    
    @objc func didEnterBackground(notification: Notification) {
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.synchronize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func start() {
        let g = GoogleLogin()
        g.delegate = self
        self.google = g
        nc.viewControllers = [google]
        
    }
    
    func logOutGoogle() {
        self.loggedOut = true
        google.logout()
        start()
    }
    
    func googleLogin(vc: GoogleLogin, didFinishAuth driveService: GTLRDriveService, didFinishAuth sheetService: GTLRSheetsService) {
        //let loadFromWeb = GoogleSheetService(service: spreadService)
       //foodSheet = FoodModel(sheetService: loadFromWeb, day: dayOfWeek)
       //requestPersonSelection()
        let spreadService = GoogleDriveService(service: driveService)
        let sheetService = GoogleSheetService(service: sheetService)
        self.spreadModel = SpreadModel(spreadService: spreadService, sheetService: sheetService)
        requestSpreadSelection()

    }
    func requestSpreadSelection() {
    
        self.mainTabController = storyboard.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
        self.mainTabController.delegate = self
        self.spreadsMainView = mainTabController.viewControllers?[0] as! SpreadsTableViewController
        self.spreadsMainView.delegate = self
        
        
        self.favsMainView = mainTabController.viewControllers?[1] as! FavsTableViewController
        self.favsMainView.delegate = self
        
        
        updateTabbarController()
        
        self.mainTabController.delegate1 = self
        self.nc.viewControllers = [mainTabController]
        
    }
    
    
    func updateTabbarController()
    {
        spreadModel.getSpreadLists(completionHandler: {(err, spreadsList) in
            self.spreadsMainView.loadArray(spreadList: spreadsList)
            
            self.updateFavorites()
        })
    }
    
    func updateFavorites()
    {
        self.loadFav()
        self.spreadsMainView.loadFavArray(favList: self.spreadModel.favsArray)
        self.favsMainView.loadArray(spreadList: self.spreadModel.favsArray)
    }
    func saveFav()
    {
        let userDefaults = UserDefaults.standard
        let encodeData : Data = NSKeyedArchiver.archivedData(withRootObject: spreadModel.favsArray)
        
        //  var keyName :String =  UserDefaults.standard.string(forKey: "name")!
        
        let keyName :String = self.google.userName
        userDefaults.set(encodeData, forKey: keyName)
        
        userDefaults.synchronize()
    }
    
    func loadFav()
    {
        let userDefaults = UserDefaults.standard
        
        let keyName :String = self.google.userName
        
        if userDefaults.object(forKey: keyName) == nil{
            return;
        }
        let decoded = userDefaults.object(forKey: keyName) as! Data
        let decodedFavs = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [GSpreadSheet]
        
        spreadModel.favsArray = decodedFavs
        
    }
    
    func onClickAddFav(vc: SpreadsTableViewController, didSelectSpread spread: GSpreadSheet) {
        spreadModel.addSpreadToFav(spread:spread)
        
        self.saveFav()
        
        updateFavorites()
    }
    
    func onClickRemoveFav(vc: SpreadsTableViewController, didSelectSpread spread: GSpreadSheet) {
        spreadModel.removeSpreadFromFav(spread:spread)
        self.saveFav()
        updateFavorites()
    }
    
    func onClickFavorites(vc: FavsTableViewController, didSelectSpread spread: GSpreadSheet) {
        self.selectedSpread = spread
        self.sheetsView =  storyboard.instantiateViewController(withIdentifier: "SheetsTableViewController") as! SheetsTableViewController
        self.sheetsView.delegate = self
        updateSheetsListViewController()
        
        self.nc.pushViewController(sheetsView, animated: true)
    }
    
    func updateSpreadSelectionViewController()
    {
        spreadModel.getSpreadLists(completionHandler: {(err, spreadsList) in
            self.spreadsView.loadArray(spreadList: spreadsList)
        })
    }
    
    
    func onClickSpread(vc: SpreadsTableViewController, didSelectSpread spread: GSpreadSheet) {
        self.selectedSpread = spread
        self.sheetsView =  storyboard.instantiateViewController(withIdentifier: "SheetsTableViewController") as! SheetsTableViewController
        self.sheetsView.delegate = self
        updateSheetsListViewController()
        
        
        self.nc.pushViewController(sheetsView, animated: true)
    }
    
    
    
    func updateSheetsListViewController() {
        spreadModel.getSheetsFor(spread: self.selectedSpread, completionHandler: { (err, shArray) in
            if err != nil {
                showAlert(vc: self.nc, title: "Something went wrong", message: "Sheets list unavailable")
            } else {
                self.sheetsView.loadArray(sheetsArray: shArray)
            }})
    }
    
    //Delegates at the SheetsTableViewController
    func onClickSheet(vc: SheetsTableViewController, didSelectSheet selectedSheet: GSheet) {
        self.selectedSheet = selectedSheet
        self.recordsView =  storyboard.instantiateViewController(withIdentifier: "SheetRecordsViewController") as! SheetRecordsViewController
        self.recordsView.delegate = self
        updateSheetRecordsViewController()
        self.nc.pushViewController(recordsView, animated: true)
    }
    
    func onClickBtnAddSheet(vc: SheetsTableViewController) {
        
        let alert = UIAlertController(title: "Add new sheet", message: "Input your sheet name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ (alertAction) in
            let textField = alert.textFields![0]
            if textField.text != "" {
                self.spreadModel.addNewSheetToSpread(spreadID : self.selectedSpread.sheetID, sheetName : textField.text!, completionHandler: { (err) in
                    if err != nil {
                        showAlert(vc: self.nc, title: "Something went wrong", message: "Sheets list unavailable")
                    } else {
                        self.updateSheetsListViewController()
                        var messageStr : String = textField.text!
                        messageStr.append(" has been added")
                        showAlert(vc: self.nc, title: "Success", message: messageStr)
                    }})
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter your sheet title"
        })
        self.nc.present(alert, animated: true, completion: nil)
    }
    
    func onClickDeleteSheet(vc: SheetsTableViewController, didSelectSheet selectedSheet: GSheet) {
        //
        self.spreadModel.deleteSheet(spreadID: self.selectedSpread.sheetID, sheet : selectedSheet, completionHandler : { (err) in
            
        })
    }
    
    func onClickRenameSheet(vc: SheetsTableViewController, didSelectSheet selectedSheet: GSheet) {
        //
        let alert = UIAlertController(title: "Add new sheet", message: "Input your sheet name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ (alertAction) in
            let textField = alert.textFields![0]
            if textField.text != "" {
                
                self.spreadModel.renameSheet(spreadID: self.selectedSpread.sheetID, sheet : selectedSheet, newName: textField.text!, completionHandler : { (err) in
                    if err != nil {
                        showAlert(vc: self.nc, title: "Something went wrong", message: "Sheets list unavailable")
                    } else {
                        self.updateSheetsListViewController()
                        //showAlert(vc: self.nc, title: "Success", message: "Sheet name changed!")
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter your sheet title"
            textField.text = selectedSheet.sheetName
        })
        self.nc.present(alert, animated: true, completion: nil)
    }
    func updateSheetRecordsViewController() {
        spreadModel.getDataForSheet(spreadID : self.selectedSpread.sheetID, sheetName: self.selectedSheet.sheetName, completionHandler: { (err, array) in
            
            if err != nil {
                showAlert(vc: self.nc, title: "Something went wrong", message: "Sheets list unavailable")
            } else {
                self.recordsView.loadRecords(sheet: self.selectedSheet, array: array)
            }})
    }
    
    //Delegates at the SheetRecordsViewController
    func onClickRecord(vc: SheetRecordsViewController, didSelectRecord recordID: Int) {
        self.selectedRecord = recordID
        self.recordEditView =  storyboard.instantiateViewController(withIdentifier: "RecordEditViewController") as! RecordEditViewController
        self.recordEditView.delegate = self
        updateRecordEditViewController()
        self.nc.pushViewController(recordEditView, animated: true)
    }
    
    func onClickBtnAddRecord(vc: SheetRecordsViewController) {
        if self.spreadModel.sheetFullArray == nil {
            
            self.headerAddView =  storyboard.instantiateViewController(withIdentifier: "headerAddView") as! HeaderAddViewController
            self.headerAddView.delegate = self
            self.nc.pushViewController(headerAddView, animated: true)
        }
        else{
            let headerArray = self.spreadModel.getHeaderRecordForSheet()
            self.recordAddView =  storyboard.instantiateViewController(withIdentifier: "RecordAddViewController") as! RecordAddViewController
            self.recordAddView.delegate = self
            self.recordAddView.loadData(headerArray: headerArray)
            self.nc.pushViewController(recordAddView, animated: true)
        }
    }
    
    func onClickDeleteRecord(vc: SheetRecordsViewController, didSelectRecord recordID: Int) {
        self.spreadModel.deleteRecordAtSheet(spreadID: self.selectedSpread.sheetID, sheet : self.selectedSheet, recordID:recordID, completionHandler : { (err) in
            
        })
    }
    
    
    func updateRecordEditViewController() {
        let array = spreadModel.getDataForRecord(recordID : self.selectedRecord)
        let headerArray = spreadModel.getHeaderRecordForSheet()
        self.recordEditView.loadData(headerArray: headerArray, array: array)
        
    }
    
    //Delegates at RecordEditViewController
    func onClickBtnSaveEditRecord(vc: RecordEditViewController, didEditRecord array: [String]) {
        self.spreadModel.updateRecordAtFullArray(recordID : self.selectedRecord, array: array)
        self.spreadModel.putEditedRecordToSheet(record : array, spreadID: self.selectedSpread.sheetID, sheetName: self.selectedSheet.sheetName, recordID: self.selectedRecord, completionHandler : { (err) in
            if err != nil {
                showAlert(vc: self.nc, title: "Something went wrong", message: "Couldn't save your record")
            } else {
                let recordArray = self.spreadModel.getSheetRecords()
                self.recordsView.loadRecords(sheet: self.selectedSheet, array: recordArray)
                self.nc.popViewController(animated: true)
                showAlert(vc: self.nc, title: "Sucess", message: "Success: Updated Record.")
            }
        })
    }
    
    //Delegates at RecordEditViewController
    func onClickBtnSaveNewRecord(vc: RecordAddViewController, didAddRecord array: [String]) {
        self.spreadModel.addRecordToFullArray(array: array)
        self.spreadModel.putNewRecordToSheet(record : array, spreadID: self.selectedSpread.sheetID, sheetName: self.selectedSheet.sheetName, completionHandler : { (err) in
            if err != nil {
                showAlert(vc: self.nc, title: "Something went wrong", message: "Couldn't add your record")
            } else {
                
                self.updateSheetRecordsViewController()
                self.nc.popViewController(animated: true)
                showAlert(vc: self.nc, title: "Sucess", message: "Success: New record added.")
            }
        })
    }
    
    func onClickBtnSaveHeaderRecord(vc: HeaderAddViewController, didAddRecord array: [String]) {
        self.spreadModel.addNewHeaderToSheet(record : array, spreadID: self.selectedSpread.sheetID, sheetName: self.selectedSheet.sheetName, completionHandler : { (err) in
            if err != nil {
                showAlert(vc: self.nc, title: "Something went wrong", message: "Couldn't add your record")
            } else {
                self.updateSheetRecordsViewController()
                self.nc.popViewController(animated: true)
                showAlert(vc: self.nc, title: "Sucess", message: "Success: Record fields added.")
            }
        })
    }
    
    
}




