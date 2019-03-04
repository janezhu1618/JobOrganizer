//
//  UITextField+InputAccessory.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 3/1/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit

extension UITextField {
    public func setupKeyboardToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done
            , target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
    }
    @objc private func doneButtonAction(textfield: UITextField) {
        textfield.resignFirstResponder()
    }
}
