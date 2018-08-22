//
//  WeatherUpdatesViewController.swift
//  IoTWeather
//
//  Created by steven freed on 8/18/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import UIKit
import AWSIoT

class WeatherUpdatesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    
    // table view and collection view data
    var tableViewData = [Day]()
    var collectionViewData = [Hour]()
    
    // topic we are subscribed to
    let topic = "weatherUpdates/"
    
    // MARK: - Makes weather updates viewable to user
    func getWeatherUpdate(temp: String?, view: String?) {
        tempLabel.text = "\(temp!)°"
        viewLabel.text = view!
        backgroundView.image = UIImage(named: view!)
    }
    
    // MARK: - Subscribes to topic "weatherUpdates/"
    func subscribeToWeatherUpdates()
    {
        let iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
        
        iotDataManager.subscribe(toTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce, messageCallback: {
            (payload) ->Void in
            
            let stringValue = String(data: payload, encoding: .utf8)
           
            do {
                
                let data = stringValue?.data(using: .utf8)
                let dict = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                // Store weather reading in Core Data
                let temp = Int16(bitPattern: dict["temperature"] as! UInt16)
                let view = String(describing: dict["view"]!)
                
                PersistentStore.saveReading(temp: temp, view: view)
        
                DispatchQueue.main.async {
                    
                  self.getWeatherUpdate(temp: String(describing: temp), view: view)
                }
                
            } catch {
                print(error)
            }
        })
    }
    
    // MARK: - Checks for user connection and for latest weather updates
    override func viewWillAppear(_ animated: Bool) {
        if mqttStatus == "Connected"
        {
         self.subscribeToWeatherUpdates()
        }
        
        // checks for last weather update
        if PersistentStore.requestReading() != nil
        {
            let reading: WReading = PersistentStore.requestReading()!
            let temp = String(describing: reading.temp)
            let view = reading.view!
           
           self.getWeatherUpdate(temp: temp, view: view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Automatic row heights
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set collection view border
        let borderTop = CALayer()
        let borderBottom = CALayer()
        let thickness: CGFloat = 0.5
        
        borderTop.backgroundColor = UIColor.white.cgColor
        borderBottom.backgroundColor = UIColor.white.cgColor
        borderTop.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: thickness)
        borderBottom.frame = CGRect(x: 0, y: (self.collectionView.frame.height - thickness), width: self.collectionView.frame.width, height: thickness)
        
        self.collectionView.layer.addSublayer(borderTop)
        self.collectionView.layer.addSublayer(borderBottom)
        
        // Set flow layout for collection view
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout
        
        // Load table view days data
        self.tableViewData.append(Day.init(day: "Sunday", image: "cloud", high: 72, low: 65))
        self.tableViewData.append(Day.init(day: "Monday", image: "cloud", high: 76, low: 67))
        self.tableViewData.append(Day.init(day: "Tuesday", image: "cloud", high: 77, low: 71))
        self.tableViewData.append(Day.init(day: "Wednesday", image: "sun", high: 83, low: 64))
        self.tableViewData.append(Day.init(day: "Thursday", image: "sun", high: 79, low: 63))
        self.tableViewData.append(Day.init(day: "Friday", image: "sun", high: 81, low: 64))
        self.tableViewData.append(Day.init(day: "Saturday", image: "sun", high: 81, low: 65))
        
        // Load collection view hours data
        self.collectionViewData.append(Hour.init(hour: "7pm", image: "sun", temp: 82))
        self.collectionViewData.append(Hour.init(hour: "8pm", image: "sun", temp: 79))
        self.collectionViewData.append(Hour.init(hour: "9pm", image: "cloud", temp: 76))
        self.collectionViewData.append(Hour.init(hour: "10pm", image: "cloud", temp: 75))
        self.collectionViewData.append(Hour.init(hour: "11pm", image: "cloud", temp: 75))
        self.collectionViewData.append(Hour.init(hour: "12am", image: "cloud", temp: 74))
        self.collectionViewData.append(Hour.init(hour: "1am", image: "cloud", temp: 69))
        self.collectionViewData.append(Hour.init(hour: "2am", image: "sun", temp: 64))
        
    }

}

extension WeatherUpdatesViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! DaysTableViewCell
        
        cell.dayLabel.text = tableViewData[indexPath.row].day!
        cell.dayImageView.image = UIImage(named: tableViewData[indexPath.row].image!)
        cell.highLabel.text = String(describing: tableViewData[indexPath.row].high!)
        cell.lowLabel.text = String(describing: tableViewData[indexPath.row].low!)
        
        return cell
    }
    
}

extension WeatherUpdatesViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! HoursCollectionViewCell
        
        cell.hourLabel.text = collectionViewData[indexPath.row].hour!
        cell.tempLabel.text = "\(String(describing: collectionViewData[indexPath.row].temp!))°"
        cell.imageView.image = UIImage(named: collectionViewData[indexPath.row].image!)
        
        return cell
    }
    
}


