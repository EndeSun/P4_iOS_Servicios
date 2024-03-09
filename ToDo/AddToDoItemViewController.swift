//
//  AddToDoItemViewController.swift
//  ToDoList
//
//  Created by Domingo on 10/5/15.
//  Copyright (c) 2015 Universidad de Alicante. All rights reserved.
//

import UIKit

class AddToDoItemViewController: UIViewController {

    var toDoItem: ToDoItem? = nil
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (saveButton.isEqual(sender)) && (textField.text!.count > 0) {
                toDoItem = ToDoItem(nombre: textField.text!)
        }
    }
}
