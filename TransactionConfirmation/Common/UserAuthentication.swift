//
//  UserAuthentication.swift
//  TransactionConfirmation
//
//  Created by Karunanithi Veerappan on 9/1/19.
//  Copyright © 2019 Karunanithi. All rights reserved.
//

import Foundation
import LocalAuthentication


class BiometricIDAuth {
    let context = LAContext()
    var loginReason = "Authenticating User"
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    completion("There was a problem verifying your identity.")
                case LAError.userCancel?:
                    completion("You pressed cancel.")
                default:
                    completion(nil)
                }
            }
        }
    }
}
