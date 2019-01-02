//
//  CitySearchViewController.swift
//  Weather Now
//
//  Created by user144641 on 10/13/18.
//  Copyright © 2018 user144641. All rights reserved.
//

import UIKit
import CoreData


struct CityData: Decodable {
    let country: String?
    let geonameid: Int?
    let name: String?
    let subcountry: String?
}

class CitySearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, NSFetchedResultsControllerDelegate {
   
    
    @IBOutlet weak var citySearchBar: UISearchBar!
    
    @IBOutlet weak var citySearchTableView: UITableView!
    //to use singleton object AppDelegte to get access to NSmangedObject and save data to the database
    lazy var cityAppdelegate : AppDelegate = {
        return (UIApplication.shared.delegate as! AppDelegate)
    }()
    
    
    var citySelected : [WorldCities]?
    var cityArray = [CityData]()    //an array of Citi
    var filteredCity = [CityData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonParsing()
        // Do any additional setup after loading the view.
    }
    
    
    
    func jsonParsing(){
        
        let url = URL(string: "https://pkgstore.datahub.io/core/world-cities/world-cities_json/data/5b3dd46ad10990bca47b04b4739a02ba/world-cities_json.json")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {return }
            do{
                let cityData = try JSONDecoder().decode([CityData].self, from: data)
                for index in cityData{
                         self.cityArray.append(index)
                     }
                DispatchQueue.main.async {
                    self.citySearchTableView.reloadData()
                
                }
                
            }catch let jsonErr{
                print("Error serializing json:", jsonErr)
                
            }
            
            }.resume()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard  !searchText.isEmpty else {
            self.filteredCity = self.cityArray
            self.citySearchTableView.reloadData()
            return
        }
        self.filteredCity = self.cityArray.filter ({CityData -> Bool in
            // If dataItem matches the searchText, return true to include it
            (CityData.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        self.citySearchTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = citySearchTableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
        cell.textLabel?.text = self.filteredCity[indexPath.row].name
        cell.detailTextLabel?.text = self.filteredCity[indexPath.row].country
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = self.filteredCity[indexPath.row].name!
        let country = self.filteredCity[indexPath.row].country!
        
        if  !checkData(cityName: city, coutryName: country) {
            let citySelected =  NSEntityDescription.insertNewObject(forEntityName: "WorldCities", into: cityAppdelegate.persistentContainer.viewContext) as! WorldCities
            
            citySelected.cityName = self.filteredCity[indexPath.row].name
            citySelected.countryName = self.filteredCity[indexPath.row].country
           cityAppdelegate.saveContext()
  
            alertMessage(selectedCity: citySelected.cityName!)
            
        }
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func checkData(cityName : String, coutryName: String)-> Bool {
        let myFetrequest :NSFetchRequest<WorldCities> = WorldCities.fetchRequest()
        
        let predicate = NSPredicate.init(format: "cityName == %@ AND countryName == %@ ", cityName, coutryName)
        myFetrequest.predicate = predicate
    
        do {
            let allcities = try cityAppdelegate.persistentContainer.viewContext.fetch(myFetrequest)
            if allcities.count  > 0{
                return true
                
            }
            
        }catch{}
        return false
        
    }
    
    func alertMessage(selectedCity: String){
        let alert = UIAlertController(title: "Success", message: "\(selectedCity) is saved to core data", preferredStyle: UIAlertController.Style.alert)
        
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
        self.present(alert, animated: true)
                }
    }
    

}
