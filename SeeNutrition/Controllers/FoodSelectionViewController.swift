//
//  ViewController.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2018-12-27.
//  Copyright © 2022 Alex Zhang. All rights reserved.
//

import UIKit
import SVProgressHUD
import Social
import SwiftyJSON
import Alamofire
import FirebaseMLVision
import FirebaseAuth

class FoodSelectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //Weak outlet. Prevent retain cycle between view controllers and subviews.
    @IBOutlet weak var folderButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var HotdogImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!

    let imgPickerController = UIImagePickerController()
    var nutritionDataModel = NutritionData()

    //ID, keys, url and default timezone for Nutritionix API
    let nuixAppID : String = Constants.NUIX.nuixAppId
    let nuixAppKeys : String = Constants.NUIX.nuixAppKeys
    let nuixURL : String =  Constants.NUIX.nuixURL
    let nuixTimezone : String = Constants.NUIX.nuixTimeZone
    
    var classificationResults : [String] = []
    var foodItemResults : [String] = []
    var currentPickedFoodItem : String = ""
    var resultSubView: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Deligate & protocal design pattern
        imgPickerController.delegate = self
        if let userName = User.getCurrentFirstName() {
            showToast(message: "Welcome, \(userName)")
        } else {
            showToast(message: "Welcome, Local Test User")
        }
    }
    
    //method to make UITextField height dynamic according to text length
    //remove the comment, change the arg to make the function works for UITextView
    func adjustUITextFieldHeight(arg : UITextField)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
    }
    
    //Cloud base image detection
    func runGoogleMLVisualRecognition(image: UIImage) {
        //configuration
        let options = VisionCloudImageLabelerOptions();
        options.confidenceThreshold = 0.75
        
        //get an instance of imageLabeler
        let labelDetector = Vision.vision().cloudImageLabeler(options: options)
        
        //convert UIImage to VisionImage
        let image: VisionImage = VisionImage(image: image)
        
        labelDetector.process(image) { labels, error in
            guard error == nil, let labels = labels, !labels.isEmpty else {
                print(error!)
                print("fail to classify the image!")
                return
            }
            
            //enable camera, folder button
            DispatchQueue.main.async {
                self.cameraButton.isEnabled = true
                self.folderButton.isEnabled = true
                SVProgressHUD.dismiss()
            }
            // Labeled image
            for label in labels {
                let labelText = label.text
                let _ = label.confidence!
                //append all names of classification results to a global list
                self.classificationResults.append(labelText)
            }
            self.renderLabelResults();
        }
    }
    
    // check if a array of strings contain food item
    func checkFood(array: [String]) -> Bool{
        let ln = LabelName();
        for item in array {
            for name in ln.genericFoodNames {
                if (item.lowercased().contains(name)) {
                   return true
                }
            }
        }
        return false
    }
    
    func renderLabelResults() {
        // detect food product
        if (checkFood(array: self.classificationResults)) {
            self.setUIWhenFoodDetected()
        }else{
            //not a food product
            self.setUIWhenFoodNotDetected()
        }
    }
    
    func setUIWhenFoodDetected() {
        
        self.assignNonGenericFoodDescription(descriptionArray: self.classificationResults)
        // food detected but no suitable text description, treat as food not detected
        if self.foodItemResults.count <= 0 {
            self.setUIWhenFoodNotDetected()
        }
        // grand central dispatch
        DispatchQueue.main.async {
            // clear all previous elements from result subview
            self.resultSubView.subviews.forEach({ $0.removeFromSuperview() })
            
            self.navigationItem.title = "Food detected!"
            let noticeTextField: UITextField = UITextField()
            
            noticeTextField.text = "Your food may be:"
            noticeTextField.frame = CGRect(x: self.view.bounds.size.width / 2 - 323 / 2, y: 140, width: 323, height: 52)
            noticeTextField.tag = 200
            Utilities.styleResultTextFields(noticeTextField)
            
            var btnIndex = 0
            for foodItem in self.foodItemResults {
                let foodBtn = UIButton(type: .system)
                foodBtn.addTarget(self, action: #selector(self.buttonAction(_:)), for: .touchUpInside)
                foodBtn.setTitle(foodItem, for: .normal)
                // Position Button
                foodBtn.frame = CGRect(x: self.view.bounds.size.width / 2 - 268 / 2, y: 200 +  CGFloat(btnIndex) * 60, width: 268, height: 48)
                foodBtn.alpha = 0.8
                foodBtn.tag = 200
                Utilities.styleFilledButton(foodBtn)
                self.view.addSubview(foodBtn)
                btnIndex+=1
                // List at most 6 food options
                if (btnIndex > 5) {
                    break
                }
            }
            self.view.addSubview(noticeTextField)
        }
    }
    
    @objc func buttonAction(_ sender:UIButton!)
        {
            if let label = sender.titleLabel {
                print(label.text!);
                currentPickedFoodItem = label.text!
                getNutritionData()
            }
        }
    
    func setUIWhenFoodNotDetected() {
        //grand central dispatch
        DispatchQueue.main.async {
            self.navigationItem.title = "Food not detected!"
            self.navigationController?.navigationBar.barTintColor = UIColor.red
            self.navigationController?.navigationBar.isTranslucent = false
            self.HotdogImageView.image = UIImage(named: "error")
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            DispatchQueue.main.async {
                SVProgressHUD.show()
                self.cameraButton.isEnabled = false
                self.folderButton.isEnabled = false
                self.imageView.image = image
            }
            //clear the results array everytime users pick an new image
            self.classificationResults = []
            self.foodItemResults = []
            
            //remove previously added result views (if exist)
            let views = self.view.getViewsByTag(tag: 200)
            views.forEach { view in view?.removeFromSuperview()}
            
            //dismiss the imgPickerController after presented
            imgPickerController.dismiss(animated: true, completion: nil)
            //Run google image recognition
            runGoogleMLVisualRecognition(image: image)
        }else{
            print("there was an error picking the image")
        }
    }

    
    //assign to foodItemResults the elements of the description that only contains description of food and nothing else
    //(excluding items which contain string color, food, nutrition, plant, dish, restaurant, building
    func assignNonGenericFoodDescription(descriptionArray: [String]) {
        var foodDescriptionArray: [String] = []
        let ln = LabelName();
        for item in descriptionArray {
            let filteredNames: [String] = ln.genericFoodNames + ln.genericNonFoodNames;
            var filter_curr_item: Bool = false
            for fn in filteredNames {
                if (item.lowercased().contains(fn)){
                    filter_curr_item = true
                    break
                }
            }
            if (filter_curr_item == false) {
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

    func getNutritionData() {
        let headers: HTTPHeaders = [
            "x-app-id" : nuixAppID,
            "x-app-key": nuixAppKeys
        ]
        let parameters: Parameters = [
            "query":currentPickedFoodItem,
            "timezone": nuixTimezone
        ]
        AF.request(nuixURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.updateNutritionData(json: json)
                    self.performSegue(withIdentifier: "toFoodDataViewController", sender:UIViewController.self)
                case .failure(let result):
                    print(result)
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Fail to get nutrition infomation."
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

    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            let initialViewController = UIStoryboard.initialViewController(for: .login)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }catch let err{
            print(err)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toFoodDataViewController") {
            let destinationVC = segue.destination as! FoodDataViewController
            destinationVC.nutritionD = nutritionDataModel
        }
    }
    
}


