//
//  GoogleSheetService.swift
//  QuickstartApp
//
//  Created by Yevgeniy Vasylenko on 6/30/17.
//  Copyright © 2017 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit
import Google
import GoogleAPIClientForREST
import GoogleSignIn



protocol SheetService1{
    func loadSheetForDate(date: String, completionHandler: @escaping (Error?, [[String]]?) -> Void)

}

protocol SheetService {
    func loadSheetForDate(date: String, completionHandler: @escaping (Error?, [[String]]?) -> Void)
    func loadSheetsForSpread(spreadID: String, completionHandler: @escaping (Error?, [GSheet]?) -> Void)
    func loadDataForSheet(spreadID: String, sheetName: String, completionHandler: @escaping (Error?, [[String]]?) -> Void)
    func writeRecordToSheet(record : [String], spreadID: String, sheetName: String, recordID : Int, completionHandler: @escaping (Error?) -> Void)
    func addNewRecordToSheet(record : [String], spreadID: String, sheetName: String, completionHandler: @escaping (Error?) -> Void)
    func addNewSheetToSpread(spreadID:String, sheetName : String, completionHandler: @escaping (Error?) -> Void)
    func deleteRecordAtSheet(spreadID : String , sheet : GSheet , recordID : Int, completionHandler : @escaping (Error?) -> Void)
    func deleteSheet(spreadID : String, sheet : GSheet, completionHandler: @escaping (Error?) -> Void)
    func renameSheet(spreadID : String, sheet : GSheet, newName: String, completionHandler: @escaping (Error?) -> Void)
}


class GoogleSheetService: NSObject, SheetService {
    
    
    let service: GTLRSheetsService
    
    
    init(service: GTLRSheetsService) {
        self.service = service
    }
    
    func loadSheetForDate(date: String, completionHandler: @escaping (Error?, [[String]]?) -> Void) {
        let spreadsheetId = "1tpj0OTIpYf4LCK7wp3oU7316k12NjYxxzF2edswpkxM"
        let range = date
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        
        service.executeQuery(query) { (ticket, result, error) in
            let fullArray = (result as? GTLRSheets_ValueRange)?.values as? [[String]]
            completionHandler(error, fullArray)
        }
    }
    
    func loadSheetsForSpread(spreadID: String, completionHandler: @escaping (Error?, [GSheet]?) -> Void) {
        
        let spreadsheetId = spreadID
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        
        service.executeQuery(query) { (ticket, result, error) in
            let spreadSheet = result as? GTLRSheets_Spreadsheet
            var array = [GSheet] ()
            for item in (spreadSheet?.sheets)! {
                let sheet = item as GTLRSheets_Sheet
                let item =  GSheet(sheetName: (sheet.properties?.title)!, sheetID: (sheet.properties?.sheetId)!)
                array.append(item)
            }
            completionHandler(error, array)
        }
    }
    
    
    
    func loadDataForSheet(spreadID: String, sheetName: String, completionHandler: @escaping (Error?, [[String]]?) -> Void)
    {
        let spreadsheetId = spreadID
        let range = sheetName
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        
        service.executeQuery(query) { (ticket, result, error) in
            let fullArray = (result as? GTLRSheets_ValueRange)?.values as? [[String]]
            completionHandler(error, fullArray)
        }
    }
    
    func writeRecordToSheet(record : [String], spreadID: String, sheetName: String, recordID : Int, completionHandler: @escaping (Error?) -> Void)
    {
        
        var range = sheetName + "!A"
        range.append(String(recordID + 2))
        
        let updateValues = [record]
        let valueRange = GTLRSheets_ValueRange() // GTLRSheets_ValueRange holds the updated values and other params
        valueRange.majorDimension = "ROWS" // Indicates horizontal row insert
        valueRange.range = range
        valueRange.values = updateValues
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadID, range: range)
        query.valueInputOption = "USER_ENTERED"
        service.executeQuery(query) { ticket, object, error in
            completionHandler(error)
        }
        
    }
    
    func addNewRecordToSheet(record : [String], spreadID: String, sheetName: String, completionHandler: @escaping (Error?) -> Void)
    {
        
        let range = sheetName
        let updateValues = [record]
        let valueRange = GTLRSheets_ValueRange() // GTLRSheets_ValueRange holds the updated values and other params
        valueRange.majorDimension = "ROWS" // Indicates horizontal row insert
        valueRange.range = range
        valueRange.values = updateValues
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: spreadID, range: range)
        query.valueInputOption = "USER_ENTERED"
        service.executeQuery(query) { ticket, object, error in
            completionHandler(error)
        }
    }
    
    func deleteRecordAtSheet(spreadID : String , sheet: GSheet, recordID: Int, completionHandler: @escaping (Error?) -> Void) {
        
        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
        
        let request = GTLRSheets_Request.init()
        
        let deleteRequest = GTLRSheets_DeleteDimensionRequest.init()
        
        let dimensionRange = GTLRSheets_DimensionRange.init()
        dimensionRange.dimension = "ROWS"
        dimensionRange.startIndex = (recordID + 1) as NSNumber
        dimensionRange.endIndex = (recordID + 2) as NSNumber
        dimensionRange.sheetId = sheet.sheetID
        
        deleteRequest.range = dimensionRange
        request.deleteDimension = deleteRequest
        
        batchUpdate.requests = [request]
        
        let createQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: spreadID)
        
        service.executeQuery(createQuery) { (ticket, result, err) in
            completionHandler(err)
        }
    }
    
    func addNewSheetToSpread(spreadID: String, sheetName: String, completionHandler: @escaping (Error?) -> Void) {
        
        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
        
        let request = GTLRSheets_Request.init()
        
        let properties = GTLRSheets_SheetProperties.init()
        properties.title = sheetName
        
        let sheetRequest = GTLRSheets_AddSheetRequest.init()
        sheetRequest.properties = properties
        
        request.addSheet = sheetRequest
        
        batchUpdate.requests = [request]
        
        let createQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: spreadID)
        
        service.executeQuery(createQuery) { (ticket, result, err) in
            completionHandler(err)
        }
    }
    
    func deleteSheet(spreadID : String, sheet : GSheet, completionHandler: @escaping (Error?) -> Void)
    {
        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
        
        let request = GTLRSheets_Request.init()
        
        let deleteSheetRequest = GTLRSheets_DeleteSheetRequest.init()
       
        
        deleteSheetRequest.sheetId = sheet.sheetID
        
        request.deleteSheet = deleteSheetRequest
        batchUpdate.requests = [request]
        let deleteSheetQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: spreadID)
        service.executeQuery(deleteSheetQuery) { (ticket, result, err) in
            completionHandler(err)
        }
    }
    
    func renameSheet(spreadID : String, sheet : GSheet, newName : String, completionHandler: @escaping (Error?) -> Void)
    {
        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
        
        let request = GTLRSheets_Request.init()
        
        let renameSheetRequest = GTLRSheets_UpdateSheetPropertiesRequest.init()
        let properties = GTLRSheets_SheetProperties.init()
        
        properties.sheetId = sheet.sheetID
        properties.title = newName
        renameSheetRequest.properties = properties
        renameSheetRequest.fields = "title"
        
        request.updateSheetProperties = renameSheetRequest
        batchUpdate.requests = [request]
        let deleteSheetQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: spreadID)
        service.executeQuery(deleteSheetQuery) { (ticket, result, err) in
            completionHandler(err)
        }
    }
}

