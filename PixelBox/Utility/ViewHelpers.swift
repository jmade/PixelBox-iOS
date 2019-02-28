//
//  ViewHelpers.swift
//  Tracker
//
//  Created by Justin Madewell on 7/20/18.
//  Copyright © 2018 Earthwave Technologies. All rights reserved.
//

import UIKit

struct View {}

extension View {
    
    static func makeButton(_ target:UIViewController,_ action: Selector,_ color:UIColor,_ text:String = "") -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = color
        btn.setAttributedTitle(buttonAttributedTitle(text), for: UIControl.State())
        btn.showsTouchWhenHighlighted = true
        btn.isEnabled = true
        btn.isUserInteractionEnabled = true
        
        btn.layer.maskedCorners = [
            CACornerMask.layerMaxXMaxYCorner,
            CACornerMask.layerMaxXMinYCorner,
            CACornerMask.layerMinXMaxYCorner,
            CACornerMask.layerMinXMinYCorner,
        ]
        btn.layer.cornerRadius = 12.0
        btn.layer.masksToBounds = true
        
        let edge: CGFloat = 16.0
        btn.contentEdgeInsets = .init(top: edge, left: edge, bottom: edge, right: edge)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        target.view.addSubview(btn)
        
        btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        btn.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        btn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btn.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        btn.addTarget(target, action: action, for: .touchUpInside)
        return btn
    }

    
    static func prepareButton(_ btn:UIButton,_ color:UIColor,_ text:String = "") {
        btn.backgroundColor = color
        btn.setAttributedTitle(buttonAttributedTitle(text), for: UIControl.State())
        btn.showsTouchWhenHighlighted = true
        btn.isEnabled = true
        btn.isUserInteractionEnabled = true
        
        btn.layer.maskedCorners = [
            CACornerMask.layerMaxXMaxYCorner,
            CACornerMask.layerMaxXMinYCorner,
            CACornerMask.layerMinXMaxYCorner,
            CACornerMask.layerMinXMinYCorner,
        ]
        btn.layer.cornerRadius = 12.0
        btn.layer.masksToBounds = true
        
        let edge: CGFloat = 16.0
        btn.contentEdgeInsets = .init(top: edge, left: edge, bottom: edge, right: edge)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
    }
    
    static func prepareButton(_ btn:UIButton,_ color:UIColor,_ text:String = "",_ textColor:UIColor) {
        btn.backgroundColor = color
        btn.setAttributedTitle(buttonAttributedTitle(text,textColor), for: UIControl.State())
        btn.showsTouchWhenHighlighted = true
        btn.isEnabled = true
        btn.isUserInteractionEnabled = true
        
        btn.layer.maskedCorners = [
            CACornerMask.layerMaxXMaxYCorner,
            CACornerMask.layerMaxXMinYCorner,
            CACornerMask.layerMinXMaxYCorner,
            CACornerMask.layerMinXMinYCorner,
        ]
        btn.layer.cornerRadius = 12.0
        btn.layer.masksToBounds = true
        
        let edge: CGFloat = 16.0
        btn.contentEdgeInsets = .init(top: edge, left: edge, bottom: edge, right: edge)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
    }
    
    static func buttonAttributedTitle(_ text:String,_ color:UIColor) -> NSAttributedString {
        return NSAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font: UIFont(descriptor: UIFont.preferredFont(forTextStyle: .headline).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0),
                NSAttributedString.Key.foregroundColor : color,
                ]
        )
    }
    
    
    
    
    static func buttonAttributedTitle(_ text:String) -> NSAttributedString {
        return NSAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font: UIFont(descriptor: UIFont.preferredFont(forTextStyle: .headline).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0),
                NSAttributedString.Key.foregroundColor : UIColor.white,
                ]
        )
    }
    
    
    
}


extension View {

        static func stack(_ leadingViews:[UIView],_ trailingViews:[UIView],_ centeredInView:UIView) {
            
            func makeStack(_ spacing:CGFloat = 8.0) -> UIStackView {
                let stack = UIStackView()
                stack.axis = .vertical
                stack.distribution = .fillEqually
                stack.spacing = spacing
                stack.translatesAutoresizingMaskIntoConstraints = false
                return stack
            }
            
            // Leading
            let leadingStack = makeStack()
            leadingViews.forEach {
                leadingStack.addArrangedSubview($0)
            }
            
            // Trailing
            let trailingStack = makeStack()
            trailingViews.forEach {
                trailingStack.addArrangedSubview($0)
            }
            
            // Container
            let containerStack = makeStack()
            containerStack.axis = .horizontal
            
            containerStack.addArrangedSubview(leadingStack)
            containerStack.addArrangedSubview(trailingStack)
            
            centeredInView.addSubview(containerStack)
            containerStack.centerYAnchor.constraint(equalTo: centeredInView.layoutMarginsGuide.centerYAnchor).isActive = true
            containerStack.leadingAnchor.constraint(equalTo: centeredInView.layoutMarginsGuide.leadingAnchor).isActive = true
            containerStack.trailingAnchor.constraint(equalTo: centeredInView.layoutMarginsGuide.trailingAnchor).isActive = true
            
        }
}



extension View {
    
    static func prepareLabel(_ label:UILabel,_ insideView:UIView,_ constrainedLeadingAndTrailing:Bool = true){
        label.backgroundColor = .white
        label.textAlignment = .center
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 0
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        insideView.addSubview(label)
        
        if constrainedLeadingAndTrailing {
            label.leadingAnchor.constraint(equalTo: insideView.safeAreaLayoutGuide.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: insideView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        }

    }
    
}




