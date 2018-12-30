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
    
    let imgPickerController = UIImagePickerController()
    let apiKey = "XPTYY50AdYRNm9yAvlejZqsJzztJ0J43EcqRc9VLGzGP"
    let version = "2018-12-27"
    var classificationResults : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imgPickerController.delegate = self
        // initialize share button and hide it, only show it after the image is selected and analyzed
        ShareButton.layer.cornerRadius = 5
        ShareButton.layer.borderWidth = 1
        ShareButton.layer.borderColor = UIColor.white.cgColor
        ShareButton.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            SVProgressHUD.show()
            self.cameraButton.isEnabled = false
            self.folderButton.isEnabled = false
            self.classificationResults = []
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
                    //grand central dispatch
                    DispatchQueue.main.async {
                        self.navigationItem.title = self.classificationResults.first
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.HotdogImageView.image = UIImage(named: "correct")
                    }
                }else{
                    //not a food product
                    //grand central dispatch
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Food not detected!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.HotdogImageView.image = UIImage(named: "error")
                    }
                }
                
            }
        }else{
            print("there was an error picking the image")
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

