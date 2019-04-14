//
//  MessageInputTextView.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 3/29/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//

import UIKit

class MessageInputTextView: UITextView {
    
    // MARK: - Properties
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter message.."
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    
    @objc func handleInputTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
}
