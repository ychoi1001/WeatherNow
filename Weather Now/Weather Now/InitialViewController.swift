//
//  InitialViewController.swift
//  Weather Now
//
//  Created by user144641 on 10/13/18.
//  Copyright © 2018 user144641. All rights reserved.
//

import UIKit
import CoreData

class InitialViewController: UIViewController,UISearchBarDelegate,UITableViewDelegate ,UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
    
    
    @IBOutlet weak var selectedCitiesSearchBar: UISearchBar!
    
    @IBOutlet weak var selectedCitiesTableView: UITableView!
    
    var citiesData : [WorldCities]?
    
    //a pointer to AppDelegate object so that we can reffer to its ob
    lazy var cityAppdelegate : AppDelegate = {
        return (UIApplication.shared.delegate as! AppDelegate)
    }()
    
    // instantiates NSFetchedResultsController inorder to get access to NSmanagedObjects in the CoreData
    lazy var fetchcontroller : NSFetchedResultsController<WorldCities> =
        
        {
            let fetchCity = NSFetchRequest<WorldCities>(entityName: "WorldCities")
            
            let sort1 =  NSSortDescriptor(key: "cityName", ascending: true)
            let sort2 = NSSortDescriptor(key: "countryName", ascending: true)
            
            
            fetchCity.sortDescriptors = [sort1, sort2]
            
            let fetchtem =  NSFetchedResultsController(fetchRequest: fetchCity, managedObjectContext: cityAppdelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchtem.delegate = self;
            return fetchtem
            
    }()
    
    // searching for city which might be stored in coreData
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let cityPredicate : NSPredicate?
        
        if(searchText.count > 0){
            
            cityPredicate =  NSPredicate(format: "cityName Contains[c] %@", searchText)
        }
        else{
            cityPredicate = nil
        }
        fetchcontroller.fetchRequest.predicate = cityPredicate;
        fetchingData()
        selectedCitiesTableView.reloadData()
    }
    
    // the following method fetchs data from database and use do-catch to handle error
    func fetchingData(){
        do
        {
            try  fetchcontroller.performFetch()
            
        }catch{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchingData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchingData()
        //  performFetchfucntion()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return (fetchcontroller.sections![section]).numberOfObjects
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = selectedCitiesTableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        
        let city = fetchcontroller.object(at: indexPath)
        cell.textLabel?.text = city.cityName
        cell.detailTextLabel?.text = city.countryName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "toDetailVC"{
            let avc = segue.destination as! DetailWeatherViewController
            let  indexpath  = selectedCitiesTableView.indexPathForSelectedRow
            let currentcell = selectedCitiesTableView.cellForRow(at: indexpath!)
            let mystr = currentcell?.textLabel?.text
            avc.nameOfTheCity = mystr!
        }
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let deletObject = fetchcontroller.object(at: indexPath);
            cityAppdelegate.persistentContainer.viewContext.delete(deletObject)
            cityAppdelegate.saveContext()
            
        }
        
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "noooo"
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        selectedCitiesTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            selectedCitiesTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            selectedCitiesTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            selectedCitiesTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            selectedCitiesTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            selectedCitiesTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            selectedCitiesTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        selectedCitiesTableView.endUpdates()
    }
    
}
