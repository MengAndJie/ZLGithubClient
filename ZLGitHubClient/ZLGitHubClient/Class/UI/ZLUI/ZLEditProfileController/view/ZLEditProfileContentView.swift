//
//  ZLEditProfileContentView.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/8/26.
//  Copyright © 2019 ZM. All rights reserved.
//

import UIKit

class ZLEditProfileContentView: ZLBaseView {

    static let minHeight: CGFloat = 550.0
    
    @IBOutlet weak var personalDescTextView: UITextView!
    
    @IBOutlet weak var companyTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var blogTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func resignAllFirstResponder()
    {
        self.personalDescTextView.resignFirstResponder()
        self.companyTextField.resignFirstResponder()
        self.addressTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.blogTextField.resignFirstResponder()
    }
    
}
