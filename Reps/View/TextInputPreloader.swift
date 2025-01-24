import SwiftUI
import UIKit

struct TextInputPreloader: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            let textField = UITextField()
            view.addSubview(textField)
            textField.becomeFirstResponder()
            DispatchQueue.main.async {
                textField.resignFirstResponder()
                textField.removeFromSuperview()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
} 