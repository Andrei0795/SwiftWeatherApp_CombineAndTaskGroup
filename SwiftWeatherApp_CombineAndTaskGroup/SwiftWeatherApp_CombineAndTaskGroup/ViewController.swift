//
//  ViewController.swift
//  SwiftWeatherApp_CombineAndTaskGroup
//
//  Created by Andrei Ionescu on 28.05.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var cityNameTextField: UITextField!
    @IBOutlet var showWeatherButton: UIButton!
    @IBOutlet var showFavorites: UIButton!
    @IBOutlet var combineSwitch: UISwitch!
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 8.0
        showWeatherButton.layer.cornerRadius = 8.0
        showFavorites.layer.cornerRadius = 8.0
        cityNameTextField.layer.cornerRadius = 8.0
        cityNameTextField.autocorrectionType = .no
        imageView.image = UIImage(named: "bucharestsunset")
    }

    @IBAction func showWeatherTapped(_ sender: UIButton) {
        if cityNameTextField.text?.count ?? 0 < 3 {
            showAlert(message: "Please enter a valid city name")
        } else {
            let currentStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loadedVC = currentStoryboard.instantiateViewController(withIdentifier: "WeatherTableViewController") as? WeatherTableViewController
            let viewModel = WeatherTableViewModel(type: .single)
            viewModel.cityName = cityNameTextField.text
            loadedVC?.viewModel = viewModel
            self.show(loadedVC!, sender: nil)
        }
    }
    
    @IBAction func showFavoritesTapped(_ sender: UIButton) {
        let ns = UserDefaults.standard
        let savedArray = ns.array(forKey: "favorites") as? [String]
        
        guard let savedArray = savedArray else {
            showAlert(message: "You have no favorites saved!")
            return
        }
        
        if savedArray.count == 0 {
            showAlert(message: "You have no favorites saved!")
            return
        }
        
        let currentStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loadedVC = currentStoryboard.instantiateViewController(withIdentifier: "WeatherTableViewController") as? WeatherTableViewController
        let viewModel = WeatherTableViewModel(type: .favorites, shouldUseCombine: !combineSwitch.isOn)
        loadedVC?.viewModel = viewModel
        self.show(loadedVC!, sender: nil)
        
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Note", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

