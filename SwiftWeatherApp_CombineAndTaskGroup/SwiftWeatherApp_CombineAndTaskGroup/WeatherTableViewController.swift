//
//  WeatherTableViewController.swift
//  SwiftWeatherApp_CombineAndTaskGroup
//
//  Created by Andrei Ionescu on 28.05.2024.
//

import UIKit
import Combine

class WeatherTableViewController: UITableViewController {
    @IBOutlet var statusLabel: UILabel!
    
    var refreshAction = UIRefreshControl()
    var cancellables = Set<AnyCancellable>()
    
    var viewModel: WeatherTableViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        refreshAction.addTarget(self, action: #selector(refreshNow), for: .valueChanged)
        refreshAction.tintColor = .blue
        tableView.addSubview(refreshAction)
        tableView.bounces = false
        viewModel.getWeather()
        viewModel.updateTable.receive(on: DispatchQueue.main).sink { [weak self] item in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
        statusLabel.text = viewModel.status
    }
    
    @objc private func refreshNow() {
        refreshAction.endRefreshing()
        viewModel.getWeather()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.weatherItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as? WeatherCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.weatherLabel.text = viewModel.weatherTempForItem(at: indexPath) + " degrees"
        cell.feelsLikeLabel.text = "Feels like: " + viewModel.weatherTempForItem(at: indexPath) + " degrees"
        cell.titleLabel.text = viewModel.weatherItems[indexPath.row].name
        cell.pressureLabel.text = "Pressure: " + String(viewModel.weatherItems[indexPath.row].main.pressure)
        cell.humidityLabel.text = "Humidity: " + String(viewModel.weatherItems[indexPath.row].main.humidity)

        let imageName = viewModel.itemIsInFavorites(name: viewModel.weatherItems[indexPath.row].name) ? "star.fill" : "star"
        cell.saveButton.setImage(UIImage(systemName: imageName), for: .normal)
        cell.saveButton.imageView?.contentMode = .scaleAspectFit
        return cell
    }
}

extension WeatherTableViewController: WeatherCellDelegate {
    func didTapButton(in cell: WeatherCell) {
        tableView.reloadData()
    }
}
