//
//  WeatherCell.swift
//  SwiftWeatherApp_CombineAndTaskGroup
//
//  Created by Andrei Ionescu on 28.05.2024.
//

import UIKit


protocol WeatherCellDelegate: AnyObject {
    func didTapButton(in cell: WeatherCell)
}

class WeatherCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var feelsLikeLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    weak var delegate: WeatherCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBAction func tappedAddToFavorites(_ sender: UIButton) {
        guard let title = titleLabel.text else {
            return
        }
        let ns = UserDefaults.standard
        let savedArray = ns.array(forKey: "favorites") as? [String]
        
        guard var savedArray = savedArray else {
            let newArray = [title]
            ns.set(newArray, forKey: "favorites")
            saveButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            delegate?.didTapButton(in: self)
            return
        }
        
        if savedArray.contains(title) {
            saveButton.setImage(UIImage(systemName: "star"), for: .normal)
            savedArray.removeAll {
                $0 == title
            }
        } else {
            saveButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            savedArray.append(title)
        }
        ns.set(savedArray, forKey: "favorites")
        delegate?.didTapButton(in: self)
    }
}
