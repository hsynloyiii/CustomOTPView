//
//  OTPView.swift
//  LogInSample
//
//  Created by mohamad hosein hakimi on 2/3/22.


import SwiftUI


fileprivate class OTPViewModel: ObservableObject {
    @Published var otpNumbers: [String] = []
}

struct OTPView: View {
    
    @StateObject private var otpVM = OTPViewModel()
    private let spaceBetweenBoxes: CGFloat = 10
    
    @FocusState private var focusableField: Int?
    
    @State private var fieldSelected: Int?
    
    @State private var otpViewHeight: CGFloat = CGFloat()
    
    @State private var isFirstClicked = false
    
    /// Arguments should/can pass in
    @Binding var otpCode: String
    let otpCount: Int
    @Binding var isErrorEnabled: Bool
    var errorText: String = ""
    var errorColor: Color = .red
    var normalFieldColor: Color = .gray.opacity(0.3)
    var selectedFieldColor: Color = .black
    var clearAfterFinish: Bool = false /// Not prefer if you wanna enable the error in OTP
    let finishedAction: () -> Void
    
    var body: some View {
        
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: spaceBetweenBoxes) {
                ForEach(otpVM.otpNumbers.indices, id: \.self) { index in
                    otpField(
                        Binding(
                            get: {
                                otpVM.otpNumbers[index]
                            },
                            set: { newValue in
                                otpVM.otpNumbers[index] = newValue
                            }
                        ),
                        index: index,
                        focus: otpVM.otpNumbers.indices[index]
                    )
                }
            }
            
            if isErrorEnabled {
                Text(errorText)
                    .font(.subheadline)
                    .foregroundColor(errorColor)
                    .padding(.top, 10)
            }
        }
        .modifier(SizeModifier())
        .frame(maxHeight: otpViewHeight)
        .onPreferenceChange(ViewHeightKey.self) {
            otpViewHeight = $0
        }
        .onAppear {
            otpVM.otpNumbers = [String](repeating: "", count: otpCount)
        }
    }
    
    private func otpField(_ bindingText: Binding<String>, index: Int, focus: Int) -> some View {
        TextField("",
                  text: bindingText,
                  onEditingChanged: { bool in fieldSelected = index }
        )
            .focused($focusableField, equals: focus)
            .font(.title)
            .padding([.top, .bottom], 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isErrorEnabled ? errorColor : fieldSelected == index ? selectedFieldColor : normalFieldColor, lineWidth: 1)
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .onChange(of: otpVM.otpNumbers[index]) { newValue in
                otpVM.otpNumbers[index] = newValue.count > 1 && newValue[0] != newValue[1]
                ? String(newValue[1])
                : String(newValue.prefix(1))
                
                otpCode = otpVM.otpNumbers.reduce("", +)
                
                if isErrorEnabled && clearAfterFinish && newValue.count <= 1
                || isErrorEnabled && newValue.count > 1 && newValue[0] != newValue[1]{
                    isErrorEnabled = false
                }
                
                if newValue.count == 1 {
                    if otpVM.otpNumbers.indices[index] == otpCount - 1 {
                        if clearAfterFinish {
                            Task {
                                await delayDeleteOtp()
                                isFirstClicked = false
                                fieldSelected = nil
                                finishedAction()
                            }
                        } else {
                            finishedAction()
                        }
                    } else {
                        focusableField = focus + 1
                    }
                }
                
            }
            .allowsHitTesting(
                isFirstClicked
                ? fieldSelected != nil && fieldSelected != index && otpVM.otpNumbers[index].isEmpty ? false : true
                : index == 0 ? true : false
            )
            .onTapGesture {
                isFirstClicked = true
            }
    }
    
    @MainActor
    private func delayDeleteOtp() async {
        try? await Task.sleep(nanoseconds: 150_000_000)
        otpVM.otpNumbers.indices.forEach { index in
            otpVM.otpNumbers[index] = ""
        }
        hideKeyboard()
    }
    
}



fileprivate struct MyOTPTextFieldStyle: TextFieldStyle {
    var isErrorEnabled: Bool
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration.padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isErrorEnabled ? Color.red : Color.gray, lineWidth: 3)
            )
    }
}

fileprivate struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}


fileprivate struct SizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear.preference(key: ViewHeightKey.self, value: geometry.size.height)
            }
        )
    }
}


fileprivate extension StringProtocol {
    subscript(offset: Int?) -> Character {
        self[index(startIndex, offsetBy: offset ?? 0)]
    }
}


fileprivate extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
