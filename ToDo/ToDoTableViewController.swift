//
//  ToDoListTableViewController.swift
//  ToDoList
//
//  Created by Domingo on 10/5/15.
//  Copyright (c) 2015 Universidad de Alicante. All rights reserved.
//

import UIKit

class ToDoTableViewController: UITableViewController {

    var toDoItems = [ToDoItem]()
    var itemsTerminados = 0
    let store = NSUbiquitousKeyValueStore.default
    var valoriCloud: Int = 0
    
    //delete selected items (items done)
    func borraItems() {
        var itemsPendientes = [ToDoItem]()
        for toDoItem in toDoItems {
            if (!toDoItem.completado) {
                itemsPendientes.append(toDoItem)
            } else {
                itemsTerminados += 1
            }
        }
        toDoItems = itemsPendientes
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the value from de iCloud
        valoriCloud = Int(store.longLong(forKey: "itemNum"))
        print("Valor cargado de iCLoud: \(valoriCloud)")
        itemsTerminados = valoriCloud
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return toDoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListPrototypeCell", for: indexPath) 

        // Configure the cell...

        let toDoItem = toDoItems[indexPath.row]
        cell.textLabel!.text = toDoItem.nombreItem
        if (toDoItem.completado) {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let itemPulsado = toDoItems[indexPath.row]
        itemPulsado.completado = !itemPulsado.completado
        itemPulsado.fechaFinalizacion = Date()
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }

    @IBAction func unWindToList(_ segue: UIStoryboardSegue) {
        let fuente: AddToDoItemViewController = segue.source as! AddToDoItemViewController
        if let item = fuente.toDoItem {
            toDoItems.append(item)
            self.tableView.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemsTerminados" {
            if let destinationVC = segue.destination as? NumItemsViewController {
                borraItems()
                destinationVC.terminados = itemsTerminados
            }
        }
    }

}
