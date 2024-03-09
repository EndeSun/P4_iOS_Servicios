//
//  ToDoListTableViewController.swift
//  ToDoList
//
//  Created by Domingo on 10/5/15.
//  Copyright (c) 2015 Universidad de Alicante. All rights reserved.
//

import UIKit
import CloudKit

class ToDoTableViewController: UITableViewController {

    //table items with this array
    var toDoItems = [ToDoItem]()
    //-------------------------
    var itemsTerminados = 0
    let store = NSUbiquitousKeyValueStore.default
    var valoriCloud: Int = 0
    let container =  CKContainer.default()
    var privateDB: CKDatabase!
    var publicDB: CKDatabase!
    var customRefreshControl = UIRefreshControl()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getValuefromiCloud()
        getCloudKit()
        getRecord()
        getRecordPublic()
        requestDiscoverPermission()
        
        // Refresh controller configuration
        self.customRefreshControl.attributedTitle = NSAttributedString(string: "Actualizando")
        self.customRefreshControl.addTarget(self, action: #selector(getRecord), for: .valueChanged)
        tableView.addSubview(self.customRefreshControl)
    }
    
    
    
    //Sender function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemsTerminados" {
            if let destinationVC = segue.destination as? NumItemsViewController {
                borraItems()
                destinationVC.terminados = itemsTerminados
            }
        }
    }
    
    func getCloudKit(){
        self.privateDB = self.container.privateCloudDatabase
        self.publicDB = self.container.publicCloudDatabase
    }
    
    func saveRecord(nameTask: String, publicCloud: Bool){
        let tareaRecord = CKRecord(recordType: "Tarea")
        tareaRecord["nombre"] = nameTask
        //save in the private record at the cloudKit
        if(publicCloud){
            print("Guardando en el cloudKit público")
            publicDB.save(tareaRecord, completionHandler: {
                (record: CKRecord?, error: Error?) in
                    print("Error al guardar: \(String(describing: error))") //When the error is nil = we do not have error 🥲
            })
        }else{
            print("Guardando en el cloudKit privado")
            privateDB.save(tareaRecord, completionHandler: {
                (record: CKRecord?, error: Error?) in
                    print("Error al guardar: \(String(describing: error))") //When the error is nil = we do not have error 🥲
            })
        }
        
    }
    
    func requestDiscoverPermission(){
        //For user Discover for the others classmates
        self.container.requestApplicationPermission(
            CKContainer.ApplicationPermissions.userDiscoverability,
            completionHandler: { (permissionStatus, error) in
                print("Permiso concedido: " +
                    "\(permissionStatus == CKContainer.ApplicationPermissionStatus.granted)")})
        
        self.container.discoverAllIdentities(completionHandler: { (optUsers, error) in
            if let users = optUsers {
                for user in users {
                    print(user)
                }
            }})
    }
    
    @objc func getRecord(){
        let query = CKQuery(recordType: "Tarea", predicate: NSPredicate(value:true))
        //New Version --> fetch
        if #available(iOS 15.0, *) {
            self.privateDB.fetch(withQuery: query, completionHandler: { (result) in
                switch result {
                case .success(let records):
                    var newData: [ToDoItem] = []
                    for (_, recordResult) in records.matchResults {
                        if case .success(let record) = recordResult {
                            if let nombre = record["nombre"] {
                                if !self.toDoItems.contains(where: { $0.nombreItem == nombre as! String }) {
                                    newData.append(ToDoItem(nombre: nombre as! String))
                                }
                            }
                        }
                    }
                    self.toDoItems.append(contentsOf: newData)
                    
                    DispatchQueue.main.async( execute: {
                        self.tableView.reloadData()
                        self.customRefreshControl.endRefreshing()
                    })
                    break
                case .failure(let error):
                    print("Error al cargar: \(error)")
                    break
                }
            })
        } else {
            //Old version --> perform
            self.privateDB.perform(query, inZoneWith: nil, completionHandler: {
                (results, error) in
                if error == nil {
                    var newData: [ToDoItem] = []
                     // Procesar los resultados y agregar solo los nuevos datos a newData
                    for result in results! {
                        guard let nombre = result["nombre"] as? String else { continue }
                        if !self.toDoItems.contains(where: { $0.nombreItem == nombre }) {
                            newData.append(ToDoItem(nombre: nombre))
                        }
                    }
                    self.toDoItems.append(contentsOf: newData)
                    
                    DispatchQueue.main.async( execute: {
                        self.tableView.reloadData()
                        self.customRefreshControl.endRefreshing()
                    })
                } else {
                    print("Query error: \(String(describing: error))")
                }
            })
        }
    }
    
    @objc func getRecordPublic(){
        let query = CKQuery(recordType: "Tarea", predicate: NSPredicate(value:true))
        //New Version --> fetch
        if #available(iOS 15.0, *) {
            self.publicDB.fetch(withQuery: query, completionHandler: { (result) in
                switch result {
                case .success(let records):
                    var newData: [ToDoItem] = []
                    for (_, recordResult) in records.matchResults {
                        if case .success(let record) = recordResult {
                            if let nombre = record["nombre"] {
                                if !self.toDoItems.contains(where: { $0.nombreItem == nombre as! String }) {
                                    newData.append(ToDoItem(nombre: nombre as! String, isFromPublicDB: true))
                                }
                            }
                        }
                    }
                    self.toDoItems.append(contentsOf: newData)
                    
                    DispatchQueue.main.async( execute: {
                        self.tableView.reloadData()
                        self.customRefreshControl.endRefreshing()
                    })
                    break
                case .failure(let error):
                    print("Error al cargar: \(error)")
                    break
                }
            })
        } else {
            //Old version --> perform
            self.publicDB.perform(query, inZoneWith: nil, completionHandler: {
                (results, error) in
                if error == nil {
                    var newData: [ToDoItem] = []
                     // Procesar los resultados y agregar solo los nuevos datos a newData
                    for result in results! {
                        guard let nombre = result["nombre"] as? String else { continue }
                        if !self.toDoItems.contains(where: { $0.nombreItem == nombre }) {
                            newData.append(ToDoItem(nombre: nombre, isFromPublicDB: true))
                        }
                    }
                    self.toDoItems.append(contentsOf: newData)
                    
                    DispatchQueue.main.async( execute: {
                        self.tableView.reloadData()
                        self.customRefreshControl.endRefreshing()
                    })
                } else {
                    print("Query error: \(String(describing: error))")
                }
            })
        }
    }
    
    //Delete task in the cloudKit
    func deleteTarea(_ toDoItem: ToDoItem) {
        let query = CKQuery(recordType: "Tarea",
                            predicate: NSPredicate(format: "nombre == %@", argumentArray: [toDoItem.nombreItem]))
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) in
            if error == nil {
                for result in results! {
                    let record: CKRecord! = result as CKRecord
                    self.privateDB.delete(withRecordID: record.recordID, completionHandler: {
                        (recordID, error) in print("Error: \(String(describing: error))")
                    })
                }
            }
        })
        
    }
    
    //-------------------------------------------
    //-------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListPrototypeCell", for: indexPath)
        let toDoItem = toDoItems[indexPath.row]
        
        cell.textLabel!.text = toDoItem.nombreItem
        cell.textLabel!.textColor = toDoItem.isFromPublic ? UIColor.systemRed : UIColor.black
        
        if (toDoItem.completado) {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
    
    //delete selected items (for done items) // we must also delete tasks in the CloudKit
    func borraItems() {
        var itemsPendientes = [ToDoItem]()
        for toDoItem in toDoItems {
            if (!toDoItem.completado) {
                itemsPendientes.append(toDoItem)
            } else {
                itemsTerminados += 1
                deleteTarea(toDoItem)
            }
        }
        toDoItems = itemsPendientes
        
        
        tableView.reloadData()
    }
    
    //Receiver function from AddToDoItemViewController
    @IBAction func unWindToList(_ segue: UIStoryboardSegue) {
        let fuente: AddToDoItemViewController = segue.source as! AddToDoItemViewController
        
        if let item = fuente.toDoItem {
            toDoItems.append(item)
            //save task to the private record --> TO_DO private or public cloudkit is required
            saveRecord(nameTask: item.nombreItem, publicCloud: item.isFromPublic)
            self.tableView.reloadData()
        }
    }
    
    
    
    //Selected row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let itemPulsado = toDoItems[indexPath.row]
        //item state
        itemPulsado.completado = !itemPulsado.completado
        itemPulsado.fechaFinalizacion = Date()
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }
    
    //-------------------------------------------
    //-------------------------------------------
    func getValuefromiCloud(){
        valoriCloud = Int(store.longLong(forKey: "itemNum"))
        print("Valor cargado de iCloud: \(valoriCloud)")
        itemsTerminados = valoriCloud
    }
    
    //When other device change value, we receive the message from the app Delegate
    func getValueFromBackGround(itemNum: Int){
        itemsTerminados = itemNum
    }
}

