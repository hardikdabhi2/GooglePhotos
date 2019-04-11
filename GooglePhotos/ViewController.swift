//
//  ViewController.swift
//  GooglePhotos
//
//  Created by Hardik on 11/04/19.
//  Copyright © 2019 HardikDabhi. All rights reserved.
//

import UIKit
import GoogleSignIn


class ViewController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate {
    
    var baseUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func BtnActionGoogleOperations(_ sender:UIButton)
    {
        
        if(sender.tag == 0){
            //This is for googel photos
            self.baseUrl = "https://photoslibrary.googleapis.com/v1/mediaItems"
        }
        else{
            //This is for google Album
            self.baseUrl = "https://photoslibrary.googleapis.com/v1/albums"
        }
        self.doGoogleSignin()
    }
    
    private func doGoogleSignin(){
        let signInst = GIDSignIn.sharedInstance()
        signInst?.clientID = "173579130161-c0t5tffojjh2dekr7di1p1cg3tbhdiq0.apps.googleusercontent.com"
        
        signInst!.delegate = self
        signInst!.uiDelegate = self
        
        
        signInst!.scopes = ["https://www.googleapis.com/auth/drive","https://www.googleapis.com/auth/drive.photos.readonly","https://www.googleapis.com/auth/photoslibrary"]
        
        
        if((GIDSignIn.sharedInstance()?.hasAuthInKeychain())!){
            GIDSignIn.sharedInstance()?.signInSilently()
        }
        else{
            GIDSignIn.sharedInstance()?.signIn()
        }
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken
            let accessToken = user.authentication.accessToken// Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            self.fetchGooglePhotosorAlbum(strUrl: self.baseUrl, accessToken: accessToken!)
            
            
            // ...
        }
    }
    
    
    private func fetchGooglePhotosorAlbum(strUrl:String,accessToken:String){
        
        let request = NSMutableURLRequest()
        request.url = URL(string: strUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
        let task = URLSession.shared.dataTask(with: request as URLRequest){data, response, error in
            guard error == nil && data != nil else{
                print("error")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                print("Google Photos response",jsonResponse)
                
            }
            catch{
                
            }
        }
        task.resume()
        
    }
    
    
}



//MARK: - For Objective c -


//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    GIDSignIn* signIn = [GIDSignIn sharedInstance];
//    [GIDSignIn sharedInstance].clientID = @"569228134106-fiikgunkcqddvcrhg897dv49f82nquig.apps.googleusercontent.com";
//    signIn.delegate = self;
//    signIn.uiDelegate = self;
//    //signIn.scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDrivePhotosReadonly,kGTLRAuthScopeDrive,nil];
//    signIn.scopes = @[@"https://www.googleapis.com/auth/drive",@"https://www.googleapis.com/auth/drive.photos.readonly",@"https://www.googleapis.com/auth/photoslibrary"];
//
//
//    [signIn signInSilently];
//
//    // Initialize the service object.
//    self.service = [[GTLRDriveService alloc] init];
//    self.service.shouldFetchNextPages = YES;
//
//    if(GIDSignIn.sharedInstance.hasAuthInKeychain == YES){
//        [[GIDSignIn sharedInstance] signInSilently];
//    }
//    else{
//        [[GIDSignIn sharedInstance]signIn];
//    }
//
//    }
//
//    - (void)signIn:(GIDSignIn *)signIn
//didSignInForUser:(GIDGoogleUser *)user
//withError:(NSError *)error
//{
//    if (error != nil)
//    {
//        self.service.authorizer = nil;
//    }
//    else
//    {
//        self.service.authorizer = user.authentication.fetcherAuthorizer;
//        NSString *strData = user.authentication.accessToken;
//
//        NSString *userId = user.userID;                  // For client-side use only!
//        NSString *idToken = user.authentication.idToken; // Safe to send to the server
//        [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
//        [self listFilesWithToken:strData];
//    }
//    }
//
//    - (void)listFilesWithToken:(NSString *)token
//{
//
//    NSString *finalString = [NSString stringWithFormat:@"%@",@"https://photoslibrary.googleapis.com/v1/mediaItems"];
//
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:[NSURL URLWithString:finalString]];
//    [request setHTTPMethod:@"GET"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:[NSString stringWithFormat:@"%@%@",@"Bearer ",token] forHTTPHeaderField:@"Authorization"];
//
//
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//    NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    //        NSLog(@"Request reply: %@", requestReply);
//    [MBProgressHUD hideHUDForView:[self view] animated:YES];
//    NSError *erro = nil;
//
//    if (data!=nil) {
//
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&erro ];
//    NSLog(@"Json Response is %@",json);
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
//
//    imageData_arr = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"mediaItems"]];
//
//    NSLog(@"All Media Are Loaded \n Media : %@",imageData_arr);
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//    [self.collectionView reloadData];
//    [self.collectionView.bottomRefreshControl endRefreshing];
//    });
//    });
//
//    }
//    dispatch_sync(dispatch_get_main_queue(),^{
//
//
//    });
//
//
//    }] resume];
//
//}
//

