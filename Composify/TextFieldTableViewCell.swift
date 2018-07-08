//
//  TextFieldTableViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 02.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    
    var textField: UITextField!
    var placeholder: String?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension TextFieldTableViewCell {
    func setupViews() {
        let frame = CGRect(x: separatorInset.left, y: 0, width: contentView.frame.width - separatorInset.left, height: contentView.frame.height)
        textField = UITextField(frame: frame)
        textField.placeholder = placeholder
        
        contentView.addSubview(textField)
    }
}
