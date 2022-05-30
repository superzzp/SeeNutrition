//
//  UIViewExtensions.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2019-03-28.
//  Copyright © 2022 Alex Zhang. All rights reserved.
//
import UIKit

extension UIViewController {
    
    //create a notification view similiar to the toast in Android
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
    })
} }

extension UIView {
  func getViewsByTag(tag:Int) -> Array<UIView?>{
    return subviews.filter { ($0 as UIView).tag == tag } as [UIView]
  }
}
