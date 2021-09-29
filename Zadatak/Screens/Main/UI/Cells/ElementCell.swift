//
//  ElementCell.swift
//  Zadatak
//
//  Created by Luka Ivanić on 24.09.2021..
//

import UIKit

class ElementCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var beginningLabel: UILabel!
    @IBOutlet weak var endingLabel: UILabel!
    
    
    
    func configure(_ element: Element){
        titleLabel.text = element.title
        tagLabel.text = element.tag
        
        if let beginningDate = element.beginningDate,
           let endingDate = element.endingDate{
            let formatter = DateFormatter()
            formatter.dateFormat = "YY/MM/dd"
            beginningLabel.text = formatter.string(from: beginningDate)
            endingLabel.text = formatter.string(from: endingDate)
        }
        
        tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CGFloat(tagPaddingRight)).isActive = true
    }
    
}
