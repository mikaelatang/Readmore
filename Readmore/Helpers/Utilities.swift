//
//  Utilities.swift
//  Readmore
//
//  Created by Mikaela Tang on 2021-01-02.
//

import Foundation
import SwiftUI

struct Utilities {
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func isEmailValid(_ email : String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func showError(_ message : String) -> some View {
        var errorMsg : some View{
            Text(message)
                .font(/*@START_MENU_TOKEN@*/.headline/*@END_MENU_TOKEN@*/)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colours.scarletSage)
                .fixedSize(horizontal: false, vertical: true)
        }
        
        return errorMsg
    }
}
