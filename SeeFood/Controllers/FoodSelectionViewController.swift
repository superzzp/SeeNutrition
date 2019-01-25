//
//  ViewController.swift
//  SeeFood
//
//  Created by Alex Zhang on 2018-12-27.
//  Copyright © 2018 Alex Zhang. All rights reserved.
//

import UIKit
import SVProgressHUD
import Social
import VisualRecognition
import Firebase
import SwiftyJSON
import Alamofire

class FoodSelectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
    var nutritionDataModel = NutritionData()


    

    
    //ID, keys, url and default timezone for Nutritionix api
    let nuixAppID = Constants.NUIX.NUIXAPPID
    let nuixAppKeys = Constants.NUIX.NUIXAPPKEYS
    let nuixURL =  "https://trackapi.nutritionix.com/v2/natural/nutrients"
    let nuixTimezone = "US/Eastern"
    
    var classificationResults : [String] = []
    var foodItemResults : [String] = []
    var currentPickedFoodItem: String = ""

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
// Watson image recognition currently not working, return error 400, use Google image recognition instead
    
//    func runWatsonVisualRecognition(image:UIImage) {
//        let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
//        visualRecognition.classify(image: image, threshold: 0.0, owners: ["default"], classifierIDs: ["food"], acceptLanguage: "en") { response, error in
//            if let error = error {
//                print("============================here is error =========================================")
//                print(error)
//                print("============================end of error =========================================")
//            }
//            guard let classifiedImages = response?.result else {
//                print("Failed to classify the image")
//                return
//            }
//            print(classifiedImages)
//            //check sample response at https://cloud.ibm.com/apidocs/visual-recognition?language=node#data-handling for details
//            let classes = classifiedImages.images.first!.classifiers.first!.classes
//            //append the classification results back to the global index classificationResults
//            for index in 0 ..< classes.count {
//
//                self.classificationResults.append(classes[index].className)
//            }
//            print(self.classificationResults)
//            //grand central dispatch
//            DispatchQueue.main.async {
//                self.cameraButton.isEnabled = true
//                self.folderButton.isEnabled = true
//                SVProgressHUD.dismiss()
//                self.ShareButton.isHidden = false
//            }
//            self.checkFoodAndSetUI();
//        }
//    }
    
    
    //Cloud base image detection, use with care
    func runGoogleMLVisualRecognition(image: UIImage) {
        //configuration
        let options = VisionCloudDetectorOptions()
        options.modelType = .latest
        options.maxResults = 10
        
        //get an instance of imageDetector
        
        let labelDetector = Vision.vision().cloudImageLabeler()
        
        //convert UIImage to VisionImage
        let image: VisionImage = VisionImage(image: image)
        
        labelDetector.process(image) { labels, error in
            guard error == nil, let labels = labels, !labels.isEmpty else {
                print(error)
                print("fail to classify the image!")
                return
            }
            
            // Labeled image
            // START_EXCLUDE
            print("================classification results ===================")
            for label in labels {
                let labelText = label.text
                let entityId = label.entityID!
                let confidence = label.confidence!
                print ("label: \(labelText), confidence: \(confidence)")
                
                //append all names of classification results to a global list
                self.classificationResults.append(labelText)
            }
            print("================end of classification results ====================")
            
            //grand central dispatch
            //enable camera, folder button and activate share Button
            DispatchQueue.main.async {
                self.cameraButton.isEnabled = true
                self.folderButton.isEnabled = true
                self.ShareButton.isHidden = false
                SVProgressHUD.dismiss()
            }
            
            self.checkFoodAndSetUI();
        }
//        labelDetector.detect(in: image) { labels, error in
//            guard error == nil, let labels = labels, !labels.isEmpty else {
//                print(error)
//                print("fail to classify the image!")
//                return
//            }
//
//            // Labeled image
//            // START_EXCLUDE
//            print("================classification results ===================")
//            for label in labels {
//                let labelText = label.label!
//                let entityId = label.entityId!
//                let confidence = label.confidence!
//                print ("label: \(labelText), confidence: \(confidence)")
//
//                //append all names of classification results to a global list
//                self.classificationResults.append(labelText)
//            }
//            print("================end of classification results ====================")
//
//            //grand central dispatch
//            //enable camera, folder button and activate share Button
//            DispatchQueue.main.async {
//                self.cameraButton.isEnabled = true
//                self.folderButton.isEnabled = true
//                self.ShareButton.isHidden = false
//                SVProgressHUD.dismiss()
//            }
//
//            self.checkFoodAndSetUI();
//            
//        }
        
    }
    //check if a array of strings contain food item
    func checkFood(array: [String]) -> Bool{
        for item in array {
            if (item.lowercased().range(of: "food") != nil || item.lowercased().range(of: "dish") != nil) {
                return true
            }
        }
        return false
    }
    
    func checkFoodAndSetUI() {
        //detect food product
        if (checkFood(array: classificationResults)) {
            self.assignNonFoodDescription(descriptionArray: self.classificationResults)
            //food detected but no suitable text description, treat as food not detected
            if self.foodItemResults.count <= 0 {
                self.setUIWhenFoodNotDetected()
            }
            print(self.foodItemResults)
            //grand central dispatch
            DispatchQueue.main.async {
                self.navigationItem.title = "Food detected!"
                self.navigationController?.navigationBar.barTintColor = UIColor.init(displayP3Red: 60.0/255, green:179.0/255 , blue: 113.0/255, alpha: 1)
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
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            SVProgressHUD.show()
            self.cameraButton.isEnabled = false
            self.folderButton.isEnabled = false
            self.ShareButton.isHidden = true
            self.foodNameIndicatorText.isHidden = true
            self.foodDescriptionButtonA.isHidden = true
            self.foodDescriptionButtonB.isHidden = true
            self.foodDescriptionButtonC.isHidden = true
            //clear the results array everytime users pick an new image
            self.classificationResults = []
            self.foodItemResults = []
            imageView.image = image
            //dismiss the imgPickerController after presented
            imgPickerController.dismiss(animated: true, completion: nil)
            
            //watson imageRecognition currently has strange bug, use google image reg instaead
            //runWatsonVisualRecognition(image: image)
            
            runGoogleMLVisualRecognition(image: image)
            
            
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
        var foodDescriptionArray: [String] = []
        for item in descriptionArray {
            if (item.lowercased().range(of: "color") == nil && item.lowercased().range(of: "food") == nil && item.lowercased().range(of: "nutrition") == nil && item.lowercased().range(of: "plant") == nil && item.lowercased().range(of: "dish") == nil && item.lowercased().range(of: "restaurant") == nil && item.lowercased().range(of: "building") == nil && item.lowercased().range(of: "ing") == nil && item.lowercased().range(of: "cuisine") == nil
            ){
                foodDescriptionArray.append(item)
            }
        }
        foodItemResults = removeDuplicates(array: foodDescriptionArray)
    }
    
    //return an new array with all duplicates removed, including any strings in the array with duplicate substrings
    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            let foodStringParts = value.split(separator:" ")
            var itemContainsSplitValueParts = false
            for item in encountered {
                for stringPart in foodStringParts {
                    if item.lowercased().range(of: stringPart) != nil {
                        itemContainsSplitValueParts = true
                    }
                }
            }
            if itemContainsSplitValueParts {
                // Do nothing if any item in encountered contains the split value strings
            }
            else {
                // Add value to the set.
                encountered.insert(value)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
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
    
    

//    @IBAction func shareButtonPressed(_ sender: UIButton) {
//        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
//            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//            vc?.setInitialText("My food is \(navigationItem.title)")
//            vc?.add(imageView.image)
//            present(vc!, animated: true, completion: nil)
//        }else{
//            navigationItem.title = "please install twitter"
//        }
//    }
//

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
    
    @IBAction func foodDescriptionAPressed(_ sender: UIButton) {
        currentPickedFoodItem = foodDescriptionButtonA.currentTitle!
        getNutritionData()


    }


    @IBAction func foodDescriptionBPressed(_ sender: UIButton) {
        currentPickedFoodItem = foodDescriptionButtonB.currentTitle!
        getNutritionData()
        
    }

    @IBAction func foodDescriptionCPressed(_ sender: UIButton) {
        currentPickedFoodItem = foodDescriptionButtonC.currentTitle!
        getNutritionData()
    }

    func getNutritionData() {
        let headers: HTTPHeaders = [
            "x-app-id" : nuixAppID,
            "x-app-key": nuixAppKeys
        ]

        let parameters: Parameters = [
            "query":currentPickedFoodItem,
            "timezone": nuixTimezone
        ]

        Alamofire.request(nuixURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                print("successfully get JSON data!")
                let jso: JSON = JSON(response.result.value!)
//                print(jso)
                self.updateNutritionData(json: jso)
                print("================================line 416====================")
                print(self.nutritionDataModel.food_name)
                self.performSegue(withIdentifier: "toFoodDataViewController", sender:UIViewController.self)
//                self.delegate?.userSelectedANutritionEntry()
                
            }else{
                print("fail to get JSON response!")
                DispatchQueue.main.async {
                    self.navigationItem.title = "Fail to get nutrition infomation"
                }
            }
        }
        
        
    }
    
    func updateNutritionData(json: JSON) {
        self.nutritionDataModel.food_name = json["foods"][0]["food_name"].stringValue
        self.nutritionDataModel.brand_name = json["foods"][0]["brand_name"].stringValue
        self.nutritionDataModel.serving_unit = json["foods"][0]["serving_unit"].stringValue
        
        self.nutritionDataModel.serving_weight_grams = json["foods"][0]["serving_weight_grams"].intValue
        self.nutritionDataModel.serving_qty = json["foods"][0]["serving_qty"].intValue
        self.nutritionDataModel.nf_calories = json["foods"][0]["nf_calories"].intValue
        
        self.nutritionDataModel.nf_total_fat = json["foods"][0]["nf_total_fat"].doubleValue
        self.nutritionDataModel.nf_saturated_fat = json["foods"][0]["nf_saturated_fat"].doubleValue
        self.nutritionDataModel.nf_cholesterol = json["foods"][0]["nf_cholesterol"].doubleValue
        self.nutritionDataModel.nf_sodium = json["foods"][0]["nf_sodium"].doubleValue
        self.nutritionDataModel.nf_total_carbohydrate = json["foods"][0]["nf_total_carbohydrate"].doubleValue
        self.nutritionDataModel.nf_dietary_fiber = json["foods"][0]["nf_dietary_fiber"].doubleValue
        self.nutritionDataModel.nf_sugars = json["foods"][0]["nf_sugars"].doubleValue
        self.nutritionDataModel.nf_protein = json["foods"][0]["nf_protein"].doubleValue
        self.nutritionDataModel.nf_potassium = json["foods"][0]["nf_potassium"].doubleValue
        self.nutritionDataModel.nf_p = json["foods"][0]["nf_p"].doubleValue
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toFoodDataViewController") {
            print("find seggg!!!!!!!!!!!!!!!!!")
            let destinationVC = segue.destination as! FoodDataViewController
            destinationVC.nutritionD = nutritionDataModel
            print("set seggg!!!!!!!!!!!!!!!!!")
            
            
        }
        
    }
    
    
}

