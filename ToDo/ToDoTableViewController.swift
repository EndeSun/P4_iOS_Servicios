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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getValuefromiCloud()
        getCloudKit()
        getRecord()
        //self.tareaRecord["owningList"] = CKRecord.Reference(record: self.tareaRecord, action: .deleteSelf)
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
    
    func saveRecord(nameTask: String){
        let tareaRecord = CKRecord(recordType: "Tarea")
        tareaRecord["nombre"] = nameTask
        //save in the private record at the cloudKit
        print("Guardando en el cloudKit privado")
        
        privateDB.save(tareaRecord, completionHandler: {
            (record: CKRecord?, error: Error?) in
                print("Error al guardar: \(String(describing: error))") //When the error is nil = we do not have error 🥲
        })
    }
    
    func getRecord(){
        let query = CKQuery(recordType: "Tarea", predicate: NSPredicate(value:true))
        //New Version --> fetch
        if #available(iOS 15.0, *) {
            self.privateDB.fetch(withQuery: query, completionHandler: { (result) in
                switch result {
                case .success(let records):
                    for (_, recordResult) in records.matchResults {
                        if case .success(let record) = recordResult {
                            if let nombre = record["nombre"] {
                                let toDoItem = ToDoItem(nombre: nombre as! String)
                                self.toDoItems.append(toDoItem)
                            }
                        }
                    }
                    DispatchQueue.main.async( execute: {
                        self.tableView.reloadData()
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
                    for result in results! {
                        if let nombre = result["nombre"] {
                            let toDoItem = ToDoItem(nombre: nombre as! String)
                            self.toDoItems.append(toDoItem)
                        }
                    }
                    DispatchQueue.main.async( execute: {
                        self.tableView.reloadData()
                    })
                } else {
                    print("Query error: \(String(describing: error))")
                }
            })
        }
    }
    
    
    
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
            saveRecord(nameTask: item.nombreItem)
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
    
    func getValueFromBackGround(itemNum: Int){
        itemsTerminados = itemNum
    }
}

