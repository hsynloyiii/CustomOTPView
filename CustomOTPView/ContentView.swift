//
//  ContentView.swift
//  CustomOTPView
//
//  Created by mohamad hosein hakimi on 2/8/22.
//

import SwiftUI

/* Two step to use OTPView :
    1. create State property wrapper for otpCode to track the whole code and use it at the end
    2. create State property wrapper for error if you want to handle/enable the error, if not just use .constant(false) value
 

 * If the clearAfterFinish (explained below) is not enabled and you have finished writing the OTP, then it was not correct(the error triggered), you don't have to clear the each field step by step, just click on first field and start typing again (feel free for that due to this OTP can undrestand the new code has entered and put it over the last code, if there is a change)
 */
struct ContentView: View {
    @State private var otpCode = ""
    @State private var isErrorEnabled = false
    var body: some View {
        
        VStack {
            OTPView(
                otpCode: $otpCode,
                otpCount: 8,
                isErrorEnabled: $isErrorEnabled, /// use .constant(false) if you don't need to handle error
                errorText: "False", /// By default is ""
                errorColor: .red, /// By default is red (no need to use if you want red error color)
                normalFieldColor: .secondary, /// By default is gray.opacity(0.3)
                selectedFieldColor: .black, /// By defualt is black (no need if want black selected field)
                clearAfterFinish: false /// This has massive structure if you want to clear OTP text after finishing it (not prefer if you want to enable the OTP error)
            ) {
                /// You can do anything after finishing the OTP (make request, ...)
                checkCode()
            }
            .padding()
            
            Button("Check", action: checkCode)
        }
    }
    
    func checkCode() {
        if otpCode != "12345678" {
            /// If you want to show the error with animation, put in withAnimation {} block
            withAnimation {
                isErrorEnabled = true
            }
        } else {
            isErrorEnabled = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
