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


class GoogleDriveService: NSObject, SpreadService {
    
    let service: GTLRDriveService
    
    
    init(service: GTLRDriveService) {
        self.service = service
    }
    
    func loadSpreadsForUser(completionHandler: @escaping (Error?, GTLRDrive_FileList?) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType='application/vnd.google-apps.spreadsheet'"
        
        service.executeQuery(query) { (ticket, results, error) in
            completionHandler(error, results as? GTLRDrive_FileList)
        }
    }
    
}
