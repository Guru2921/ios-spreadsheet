import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

protocol GoogleLoginDelegate {
//    func personSelectionViewController(vc:PersonSelectionViewController, didSelectPerson personName:String);
    func googleLogin(vc: GoogleLogin, didFinishAuth driveService : GTLRDriveService, didFinishAuth sheetService: GTLRSheetsService)
}


class GoogleLogin: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeDrive]
    private var query: GTLRSheetsQuery!
    private let sheetService = GTLRSheetsService()
    private let driveService = GTLRDriveService()
    let justText = UILabel()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    var imageHungry: UIImageView?
    var delegate: GoogleLoginDelegate?
    
    var userName : String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        //Add backgroundimage
        let image = UIImage(named: "googlesheet")
        let imageView = UIImageView(image: image!)
        imageHungry = imageView
        imageHungry?.frame = CGRect(x: 0, y: -300, width: 400, height: 200)
        imageHungry?.translatesAutoresizingMaskIntoConstraints = true
        imageHungry?.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 100)
        imageHungry?.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
        view.addSubview(imageHungry!)
        
        
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().clientID = "967025069353-g6sptjvu8as8kpj8seuoj74tn1eluqin.apps.googleusercontent.com"
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        
        signInButton.frame = CGRect(x: 150, y: 250, width: 200, height: 10);
        signInButton.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight];
        signInButton.translatesAutoresizingMaskIntoConstraints = true

        // Add the sign-in button.
        view.addSubview(signInButton)
        signInButton.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + 70)
        signInButton.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if (error) != nil {
            self.sheetService.authorizer = nil
            self.driveService.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.justText.isHidden = true
            self.imageHungry?.isHidden = true
            //let image = UIImage(named: "readdle1.png")
            //let logo = UIImageView(image: image!)
            //logo.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
            //logo.translatesAutoresizingMaskIntoConstraints = true
            //logo.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 100)
            //logo.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
            //view.addSubview(logo)
            //Create Activity Indicator
            let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            myActivityIndicator.center = view.center
            myActivityIndicator.hidesWhenStopped = false
            myActivityIndicator.startAnimating()
            view.addSubview(myActivityIndicator)
            self.sheetService.authorizer = user.authentication.fetcherAuthorizer()
            self.driveService.authorizer = user.authentication.fetcherAuthorizer()
            delegate?.googleLogin(vc: self, didFinishAuth: driveService, didFinishAuth: sheetService)
            
            self.userName = user.profile.email
        }
    }
    
    func logout(){
        //logout code
        GIDSignIn.sharedInstance().signOut()
    }
    
}

func showAlert(vc: UIViewController, title : String, message: String) {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: UIAlertControllerStyle.alert
    )
    let ok = UIAlertAction(
        title: "OK",
        style: UIAlertActionStyle.default,
        handler: nil
    )
    alert.addAction(ok)
    vc.present(alert, animated: true)
}
