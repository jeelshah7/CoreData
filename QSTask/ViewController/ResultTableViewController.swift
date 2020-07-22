//
//  ResultTableViewController.swift
//  QSTask
//
//  Created by Dhrupal Shah on 21/07/20.
//  Copyright © 2020 Jeel Shah. All rights reserved.
//

import UIKit
import CoreData

class ResultTableViewController: UITableViewController {

    var results = [Result](){
        didSet{
            //TODO: Replace with diff algo.
            self.resultsModelView = self.results.map {ResultModelView(result: $0)}
        }
    }
    var resultsModelView = [ResultModelView]()
    
    private var cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Results"
        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: cellId)
        self.tableView.rowHeight = UITableView.automaticDimension
        fetchData()
        
    }
    
    func networkCall()
    {
        let urlString = ""
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if(error == nil){
                guard let data = data else {return}
                
                do{
                    let request = try JSONDecoder().decode(Request.self, from: data)
                    self.results = request.results
                    self.resultsModelView = self.results.map {ResultModelView(result: $0)}
                    self.saveData()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }catch{
                    print("Data interpretation error:-",error)
                }
            }else{
                print("Error in network call",error)
            }
        }.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsModelView.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ResultTableViewCell
        cell.titleLabel.text = resultsModelView[indexPath.row].name
        cell.descriptionLabel.text = resultsModelView[indexPath.row].vicinity
        resultsModelView[indexPath.row].imageData.bind{
            guard let data = $0 else {return}
            DispatchQueue.main.async{
                cell.iconImageView.image = UIImage(data: data)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            self.resultsModelView.remove(at: indexPath.row)
            self.deleteData(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete]
    }

    //MARK: Core Data operations.
    var cdResult: [NSManagedObject] = []
    func deleteData(index: Int){
        let container = AppDelegate.persistentContainer
        let context = container.viewContext
        
        context.delete(cdResult[index])
        cdResult.remove(at: index)
        do {
            try context.save()
        } catch {
            print("Error saving after deletion:",error)
        }
    }
    func fetchData(){
        
        let container = AppDelegate.persistentContainer
        let context = container.viewContext
        
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "ResultModel")
        
        do {
            cdResult = try context.fetch(fetchRequest)
            results = cdResult.map {Result(icon: ($0.value(forKeyPath: "icon") as? String)!, name: ($0.value(forKeyPath: "name") as? String)!, vicinity: ($0.value(forKeyPath: "vicinity") as? String)!)}
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if(results.count==0){
                networkCall()
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func saveData()
    {
        let container = AppDelegate.persistentContainer
        let context = container.viewContext
        let entity =
        NSEntityDescription.entity(forEntityName: "ResultModel",
                                   in: context)!
        
        
        for result in results{
            let resultEntity =  NSManagedObject(entity: entity,
                                          insertInto: context)
            resultEntity.setValue(result.name, forKey: "name")
            resultEntity.setValue(result.icon, forKey: "icon")
            resultEntity.setValue(result.vicinity, forKey: "vicinity")
        }
        do{
            try context.save()
        }catch{
            print("Error saving data in storage:",error)
        }
    }
}
