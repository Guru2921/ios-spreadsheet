//
//  FoodSheetModel.swift
//  QuickstartApp
//
//  Created by Yevgeniy Vasylenko on 6/27/17.
//  Copyright © 2017 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit
import Google
import GoogleAPIClientForREST
import GoogleSignIn


class SpreadModel: NSObject {
    
    let spreadService: SpreadService
    let sheetService : SheetService
    var spreadArray = [GSpreadSheet]()
    var favsArray = [GSpreadSheet]()
    var sheetFullArray  : [[String]]?
    var isNewSheet : Bool = true
    
    var spreadsCompletionHandler: ((Error?, [GSpreadSheet]) -> Void)?
    var sheetsCompletionHandler: ((Error?, [GSheet]) -> Void)?
    var recordsLoadCompletionHandler: ((Error?, [String]) -> Void)?
    
    
    init(spreadService: SpreadService, sheetService : SheetService) { //  remove from constructor
        self.spreadService = spreadService;
        self.sheetService = sheetService;
    }
    
    func getSpreadLists(completionHandler: @escaping (Error?, [GSpreadSheet]) -> Void){
        
        self.spreadsCompletionHandler = completionHandler
        if spreadArray.count > 0 {
            self.spreadsCompletionHandler!(nil, self.spreadArray)
        }
        else {
            spreadService.loadSpreadsForUser(completionHandler: { (err, results) in
                if let err = err {
                    self.spreadsCompletionHandler!(err, [])
                } else {
                    
                    let fileList = results as! GTLRDrive_FileList
                    for file in fileList.files! {
                        self.spreadArray.append(GSpreadSheet(name: file.name!, sheetID: file.identifier!))
                    }
                    
                    self.spreadsCompletionHandler!(err, self.spreadArray)
                }
            })
        }
        
    }
    
    func getSheetsFor(spread : GSpreadSheet, completionHandler: @escaping (Error?, [GSheet]) -> Void) {
        
        self.sheetsCompletionHandler = completionHandler
    
        
        sheetService.loadSheetsForSpread(spreadID: spread.sheetID, completionHandler: { (err, array) in
            if let err = err {
                self.sheetsCompletionHandler!(err, [])
            } else {
                self.sheetsCompletionHandler!(err,array!)
            }
        })
    }
    
    func addNewSheetToSpread(spreadID : String, sheetName : String, completionHandler: @escaping (Error?) -> Void) {
        
        let addSheetCompletionHandler = completionHandler
        
        
        sheetService.addNewSheetToSpread(spreadID: spreadID, sheetName : sheetName, completionHandler: { (err) in
            if let err = err {
                addSheetCompletionHandler(err)
            } else {
                addSheetCompletionHandler(err)
            }
        })
    }
    
    func getDataForSheet(spreadID:String, sheetName:String, completionHandler: @escaping (Error?, [String]) -> Void) {
        
        self.recordsLoadCompletionHandler = completionHandler
        
        
        sheetService.loadDataForSheet(spreadID: spreadID, sheetName:sheetName, completionHandler: { (err, array) in
            if let err = err {
                self.recordsLoadCompletionHandler!(err, [])
            } else {
                
                if let err = err {
                    self.recordsLoadCompletionHandler!(err, [])
                } else {
                    if array == nil {
                        self.isNewSheet = true;
                        self.sheetFullArray = nil
                        self.recordsLoadCompletionHandler!(err, [])
                    }
                    else
                    {
                        self.isNewSheet = false;
                        self.sheetFullArray = array!
                        self.addNeedFields(spreadID: spreadID, sheetName: sheetName)
                        self.getRecordsCompletionHandler()
                    }
                }
            }
        })
    }
    func deleteSheet(spreadID : String, sheet : GSheet, completionHandler: @escaping (Error?) -> Void)
    {
        let deletSheetCompletionHandler = completionHandler
        sheetService.deleteSheet(spreadID: spreadID, sheet : sheet,  completionHandler: { (err) in
            deletSheetCompletionHandler(err)
        })
    }
    
    func renameSheet(spreadID : String, sheet : GSheet, newName :String,  completionHandler: @escaping (Error?) -> Void)
    {
        let renameSheetCompletionHandler = completionHandler
        sheetService.renameSheet(spreadID: spreadID, sheet : sheet, newName : newName, completionHandler: { (err) in
            renameSheetCompletionHandler(err)
        })
    }
    
    func deleteRecordAtSheet(spreadID : String, sheet : GSheet , recordID : Int, completionHandler: @escaping (Error?) -> Void)
    {
        let deletRecordCompletionHandler = completionHandler
        sheetService.deleteRecordAtSheet(spreadID: spreadID, sheet : sheet, recordID : recordID, completionHandler: { (err) in
           deletRecordCompletionHandler(err)
        })
    }
    
    func putEditedRecordToSheet(record : [String], spreadID:String, sheetName:String, recordID : Int, completionHandler: @escaping (Error?) -> Void) {
        let savingEditedRecordCompletionHandler = completionHandler
        sheetService.writeRecordToSheet(record : record, spreadID: spreadID, sheetName: sheetName, recordID: recordID, completionHandler: {(err) in
                savingEditedRecordCompletionHandler(err)
        })
    }
    
    func putNewRecordToSheet(record : [String], spreadID:String, sheetName:String, completionHandler: @escaping (Error?) -> Void) {
        let savingNewRecordCompletionHandler = completionHandler
        sheetService.addNewRecordToSheet(record : record, spreadID: spreadID, sheetName: sheetName, completionHandler: {(err) in
                savingNewRecordCompletionHandler(err)
        })
    }

    func addNewHeaderToSheet(record : [String], spreadID:String, sheetName:String, completionHandler: @escaping (Error?) -> Void) {
        sheetService.addNewRecordToSheet(record : record, spreadID: spreadID, sheetName: sheetName, completionHandler: {(err) in
            self.sheetFullArray?.append(record)
            completionHandler(err)
        })
    }
    func getDataForRecord(recordID: Int) -> [String]{
        if sheetFullArray!.count < 2 {
            return []
        }
        
        if recordID+1 < (sheetFullArray?.count)! {
            return sheetFullArray![recordID + 1]
        }
        return []
    }
    
    func getHeaderRecordForSheet() -> [String]{
        if (self.sheetFullArray?.count)! > 0 {
            return self.sheetFullArray![0]
        }
        return []
    }
    
    private func addNeedFields(spreadID : String, sheetName : String)
    {
        var array : [String] = self.getHeaderRecordForSheet()
        
        if array.contains("CreatedAt") && array.contains("UpdatedAt"){
            return;
        }
        else if array.contains("CreatedAt")
        {
            array.append("UpdatedAt")
            self.sheetFullArray?[0].append("UpdatedAt")
        }
        else if array.contains("UpdatedAt")
        {
            array.append("CreatedAt")
            self.sheetFullArray?[0].append("CreatedAt")
        }
        else
        {
            array.append("CreatedAt")
            self.sheetFullArray?[0].append("CreatedAt")
            array.append("UpdatedAt")
            self.sheetFullArray?[0].append("UpdatedAt")
        }
        
        let headerRecordID = -1
        sheetService.writeRecordToSheet(record : array, spreadID: spreadID, sheetName: sheetName, recordID: headerRecordID, completionHandler: {(err) in
            return;
        })
        
    }
    private func getRecordsCompletionHandler() {
        if sheetFullArray!.count < 2 {
            // send error to delegate
            return
        }
        var array = [String]()
        for i in 1..<(sheetFullArray!.count) {
            if sheetFullArray![i] != nil
            {
                if sheetFullArray![i].count > 0 {
                    array.append(sheetFullArray![i][0])
                }
                else{
                    array.append("")
                }
            }
            else
            {
                array.append("")
            }
        }
        
        self.recordsLoadCompletionHandler?(nil, array)
    }
    
    func getSheetRecords() -> [String]
    {
        if sheetFullArray!.count < 2 {
            return []
        }
        var array = [String]()
        for i in 1..<(sheetFullArray!.count) {
            if sheetFullArray![i].count > 0 {
                array.append(sheetFullArray![i][0])
            }
            else
            {
                array.append("")
            }
        }
        return array
    }
    
    func updateRecordAtFullArray(recordID : Int, array: [String])
    {
        sheetFullArray![recordID+1] = array
    }
    
    func addRecordToFullArray(array : [String]){
        sheetFullArray?.append(array)
    }
    
    func addSpreadToFav(spread : GSpreadSheet)
    {
        favsArray.append(spread)
    }
    
    func removeSpreadFromFav(spread : GSpreadSheet)
    {
        for index in 0 ..< favsArray.count {
            let item = favsArray[index]
            if item.sheetID == spread.sheetID{
                if favsArray.count > index {
                    favsArray.remove(at: index)
                    break
                }
                return
            }
        }
    }
}
