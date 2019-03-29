//
//  KeyValues.swift
//  SeeNutrition
//
//  Created by test on 2019-03-28.
//  Copyright © 2019 Alex Zhang. All rights reserved.
//

import Foundation
import Firebase

enum ValueKey: String {
    case nuixAppId
    case nuixAppKeys
}

class KeyValues {
    
    static let sharedInstance = KeyValues()
    var loadingDoneCallback: (() -> Void)?
    var fetchComplete = false
    
    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            ValueKey.nuixAppId.rawValue: "123456",
            ValueKey.nuixAppKeys.rawValue: "223679",
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    func fetchCloudValues() {
        // Change TimeInterval to >43200 (>12Hours) before submit to App Store!
        let fetchDuration: TimeInterval = 43200
        //activateDebugMode()
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) {
            [weak self] (status, error) in
            if let error = error {
                print ("Uh-oh. Got an error fetching remote values \(error)")
                return
            }
            RemoteConfig.remoteConfig().activateFetched()
            print ("Retrieved values from the cloud!")
            self?.fetchComplete = true
            self?.loadingDoneCallback?()
        }
    }
    
    func activateDebugMode() {
        let debugSettings = RemoteConfigSettings(developerModeEnabled: true)
        RemoteConfig.remoteConfig().configSettings = debugSettings
    }
    
    func bool(forKey key: ValueKey) -> Bool {
        return RemoteConfig.remoteConfig()[key.rawValue].boolValue
    }
    
    func string(forKey key: ValueKey) -> String {
        return RemoteConfig.remoteConfig()[key.rawValue].stringValue ?? ""
    }
    
    func double(forKey key: ValueKey) -> Double {
        if let numberValue = RemoteConfig.remoteConfig()[key.rawValue].numberValue {
            return numberValue.doubleValue
        } else {
            return 0.0
        }
    }
}

