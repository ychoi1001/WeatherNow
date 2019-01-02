//
//  DetailWeatherViewController.swift
//  Weather Now
//
//  Created by user144641 on 10/13/18.
//  Copyright © 2018 user144641. All rights reserved.
//

import UIKit

class DetailWeatherViewController: UIViewController {
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var HumidityLabel: UILabel!
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var nameOfTheCity : String = " "
    
    var temperat : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = nameOfTheCity
        fetchWeather(city: nameOfTheCity)
        // Do any additional setup after loading the view.
    }
    
    func fetchWeather(city: String){
        let session = URLSession.shared
        // let cityString =
        let urlstring = "http://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=771d698c53f6357fe3c79d6ad0e050f1&units=metric"
        let urlStringCod = urlstring.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let weatherURL = URL.init(string: urlStringCod!)
        if let wurl = weatherURL{
            let dataTask = session.dataTask(with: wurl) {
                (data: Data?, response: URLResponse?, error: Error?) in
                if let error = error {
                    print("Error:\n\(error)")
                } else {
                if let data = data {
                        let dataString = String(data: data, encoding: String.Encoding.utf8)
                    print("All the weather data:\n\(dataString!)")
                    
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                    
                     let mainDictionary = json!.value(forKey: "main") as? NSDictionary
                     let date = json?.value(forKey: "dt")as? Int
                    let cityTime = self.getDate(timeInterval: date!)
                    
                    let  weather = json!.value(forKey: "weather") as? NSArray
                    let weather1 = weather?.object(at: 0) as? NSDictionary
                    let icon = weather1?.value(forKey: "icon")as? String
                    
                    let iconImage = icon! + ".png"
                
                    let temperature = mainDictionary!.value(forKey: "temp");
                    let humidityLevel = mainDictionary!.value(forKey: "humidity")
                  
                        DispatchQueue.main.async {
                            self.temperatureLabel.text = "\(Int(round(temperature as! Double)))°C"
                            self.weatherIcon.image = UIImage(named:"\(iconImage)")
                            self.dateLabel.text = "\(cityTime)"
                            self.HumidityLabel.text = "\(humidityLevel!)%"
                        }
                        
                    }
                    else {
                        print("Error: did not receive data")
                    }
                }
            }
            
            
            dataTask.resume()}
    }
    
    func getDate(timeInterval: Int)->String{
        let currentDate = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        let printdate = dateFormatter.string(from: currentDate as Date)
        return printdate
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
