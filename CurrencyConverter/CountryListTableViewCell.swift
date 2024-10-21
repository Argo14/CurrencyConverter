//
//  CountryListTableViewCell.swift
//  CurrencyConverter
//
//  Created by Arjun Gopakumar on 21/10/24.
//

import UIKit

class CountryListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryCurrencyCodeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
