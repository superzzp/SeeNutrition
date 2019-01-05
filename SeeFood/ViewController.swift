//
//  ViewController.swift
//  SeeFood
//
//  Created by Alex Zhang on 2018-12-27.
//  Copyright © 2018 Alex Zhang. All rights reserved.
//

import UIKit
import VisualRecognition
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var folderButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var HotdogImageView: UIImageView!
    @IBOutlet weak var ShareButton: UIButton!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var foodNameIndicatorText: UITextField!
    @IBOutlet weak var foodDescriptionButtonA: UIButton!
    @IBOutlet weak var foodDescriptionButtonB: UIButton!
    @IBOutlet weak var foodDescriptionButtonC: UIButton!
    
 

    
    
    let imgPickerController = UIImagePickerController()
    let apiKey = "XPTYY50AdYRNm9yAvlejZqsJzztJ0J43EcqRc9VLGzGP"
    let version = "2018-12-27"
    var classificationResults : [String] = []
    var foodItemResults : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imgPickerController.delegate = self
        initializeDesigns()
        
    }
    
    func initializeDesigns() {
        // initialize share button and hide it, only show it after the image is selected and analyzed
        ShareButton.layer.cornerRadius = 5
        ShareButton.layer.borderWidth = 1
        
        foodNameIndicatorText.layer.cornerRadius = 5
        foodNameIndicatorText.layer.borderWidth = 0
        self.adjustUITextFieldHeight(arg: foodNameIndicatorText)
        
        foodDescriptionButtonA.layer.cornerRadius = 5
        foodDescriptionButtonA.layer.borderWidth = 1
        foodDescriptionButtonA.layer.borderColor = UIColor.white.cgColor
        
        foodDescriptionButtonB.layer.cornerRadius = 5
        foodDescriptionButtonB.layer.borderWidth = 1
        foodDescriptionButtonB.layer.borderColor = UIColor.white.cgColor
        
        foodDescriptionButtonC.layer.cornerRadius = 5
        foodDescriptionButtonC.layer.borderWidth = 1
        foodDescriptionButtonC.layer.borderColor = UIColor.white.cgColor
        
        ShareButton.layer.borderColor = UIColor.white.cgColor
        ShareButton.layer.backgroundColor = UIColor(red: 0, green: 253.0/255.0, blue: 1, alpha: 0.8).cgColor
        foodNameIndicatorText.layer.backgroundColor = UIColor(red: 0, green: 253.0/255.0, blue: 1, alpha: 0.8).cgColor
        foodDescriptionButtonA.layer.backgroundColor = UIColor(red: 0, green: 253.0/255.0, blue: 1, alpha: 0.8).cgColor
        foodDescriptionButtonB.layer.backgroundColor = UIColor(red: 0, green: 253.0/255.0, blue: 1, alpha: 0.8).cgColor
        foodDescriptionButtonC.layer.backgroundColor = UIColor(red: 0, green: 253.0/255.0, blue: 1, alpha: 0.8).cgColor
        
        ShareButton.isHidden = true
        foodNameIndicatorText.isHidden = true
        foodDescriptionButtonA.isHidden = true
        foodDescriptionButtonB.isHidden = true
        foodDescriptionButtonC.isHidden = true
    }
    
    //method to make UITextField height dynamic according to text length
    //remove the comment, change the arg to make the function works for UITextView
    func adjustUITextFieldHeight(arg : UITextField)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        //arg.isScrollEnabled = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            SVProgressHUD.show()
            self.cameraButton.isEnabled = false
            self.folderButton.isEnabled = false
            self.ShareButton.isHidden = true
            foodNameIndicatorText.isHidden = true
            foodDescriptionButtonA.isHidden = true
            foodDescriptionButtonB.isHidden = true
            foodDescriptionButtonC.isHidden = true
            //clear the results array everytime users pick an new image
            self.classificationResults = []
            self.foodItemResults = []
            imageView.image = image
            //dismiss the imgPickerController after presented
            imgPickerController.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            //the part of the code only gets triggered when the classify gets and return result into the response or error
            //so everything inside the curly brases run in the background thread
            //the best practice is to require the code that is related to display to run in main thread (grand central dispatch)
            visualRecognition.classify(image: image) { response, error in
                if let error = error {
                    print(error)
                }
                guard let classifiedImages = response?.result else {
                    print("Failed to classify the image")
                    return
                }
                print(classifiedImages)
                //check sample response at https://cloud.ibm.com/apidocs/visual-recognition?language=node#data-handling for details
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                //append the classification results back to the global index classificationResults
                for index in 0 ..< classes.count {
                    
                    self.classificationResults.append(classes[index].className)
                }
                print(self.classificationResults)
                //grand central dispatch
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    self.folderButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.ShareButton.isHidden = false
                }
                //detect food product
                if (self.classificationResults.contains("food") || self.classificationResults.contains("food product")) {
                    self.assignNonFoodDescription(descriptionArray: self.classificationResults)
                    //food detected but no suitable text description, treat as food not detected
                    if self.foodItemResults.count <= 0 {
                        self.setUIWhenFoodNotDetected()
                    }
                    print(self.foodItemResults)
                    //grand central dispatch
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Food detected!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.HotdogImageView.image = UIImage(named: "correct")
                        self.foodNameIndicatorText.isHidden = false
                        
                        if self.foodItemResults.count == 1 {
                            self.foodDescriptionButtonA.setTitle(self.foodItemResults[0], for: UIControl.State.normal)
                            self.foodDescriptionButtonA.isHidden = false
                        }
                        
                        if self.foodItemResults.count == 2 {
                            self.foodDescriptionButtonA.setTitle(self.foodItemResults[0], for: UIControl.State.normal)
                            self.foodDescriptionButtonB.setTitle(self.foodItemResults[1], for: UIControl.State.normal)
                            self.foodDescriptionButtonA.isHidden = false
                            self.foodDescriptionButtonB.isHidden = false
                        }
                        
                        if self.foodItemResults.count == 3 || self.foodItemResults.count > 3 {
                            self.foodDescriptionButtonA.setTitle(self.foodItemResults[0], for: UIControl.State.normal)
                            self.foodDescriptionButtonB.setTitle(self.foodItemResults[1], for: UIControl.State.normal)
                            self.foodDescriptionButtonC.setTitle(self.foodItemResults[2], for: UIControl.State.normal)
                            self.foodDescriptionButtonA.isHidden = false
                            self.foodDescriptionButtonB.isHidden = false
                            self.foodDescriptionButtonC.isHidden = false
                        }
                    }
                }else{
                    //not a food product
                    self.setUIWhenFoodNotDetected()
                }
                
            }
        }else{
            print("there was an error picking the image")
        }
        
    }
    
    func setUIWhenFoodNotDetected(){
        //grand central dispatch
        DispatchQueue.main.async {
            self.navigationItem.title = "Food not detected!"
            self.navigationController?.navigationBar.barTintColor = UIColor.red
            self.navigationController?.navigationBar.isTranslucent = false
            self.HotdogImageView.image = UIImage(named: "error")
        }
    }
    
    
    //assign to foodItemResults the elements of the description that only contains description of food and nothing else
    //(excluding items which contain string color, food, nutrition, plant, dish, restaurant, building
    func assignNonFoodDescription(descriptionArray: [String]) {
        for item in descriptionArray {
            if (item.lowercased().range(of: "color") == nil && item.lowercased().range(of: "food") == nil && item.lowercased().range(of: "nutrition") == nil && item.lowercased().range(of: "plant") == nil && item.lowercased().range(of: "dish") == nil && item.lowercased().range(of: "restaurant") == nil && item.lowercased().range(of: "building") == nil
            ){
                self.foodItemResults.append(item)
            }
        }
    }
    
    @IBAction func folderTapped(_ sender: UIBarButtonItem) {
        //use photo album for testing on mac
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {

            imgPickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
            imgPickerController.allowsEditing = false
            present(imgPickerController, animated: true, completion: nil)

        }else{
            let alert = UIAlertController(title: "Photo Album Unvaliable", message: "Please use a device with a photo album to use the app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            present(alert, animated: true, completion: nil)
        }

    }

    

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title)")
            vc?.add(imageView.image)
            present(vc!, animated: true, completion: nil)
        }else{
            navigationItem.title = "please install twitter"
        }
    }
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        //tap into camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let array = UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera)
            if array!.contains("public.image") {
                imgPickerController.sourceType = UIImagePickerController.SourceType.camera
                imgPickerController.allowsEditing = false
                present(imgPickerController, animated: true, completion: nil)
            }else{
                print("the camera does not support taking image")
            }
            
            
        }else{
            //give user an alert if the device does not have a camara
            let alert = UIAlertController(title: "Camera Unvaliable", message: "Please use a device with a working camera to use the app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
}

