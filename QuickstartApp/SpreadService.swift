
import Google
import GoogleAPIClientForREST
import GoogleSignIn

protocol SpreadService {
    func loadSpreadsForUser(completionHandler: @escaping (Error?, GTLRDrive_FileList?) -> Void)
}
