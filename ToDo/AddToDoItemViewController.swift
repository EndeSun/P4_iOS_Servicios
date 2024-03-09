//
//  AddToDoItemViewController.swift
//  ToDoList
//
//  Created by Domingo on 10/5/15.
//  Copyright (c) 2015 Universidad de Alicante. All rights reserved.
//

import UIKit

enum Opciones: Int {
    case Privado = 0
    case Público
}


class AddToDoItemViewController: UIViewController {

    var toDoItem: ToDoItem? = nil
    var optionTask : String?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func seleccion(_ sender:UISegmentedControl) {
        let option = Opciones(rawValue: sender.selectedSegmentIndex)!
        switch option {
        case .Privado:
            optionTask = "Privado"
        case .Público:
            optionTask = "Público"
        }
    }
    
    
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
            if(optionTask == "Público"){
                toDoItem = ToDoItem(nombre: textField.text!, isFromPublicDB: true)
            }else{
                toDoItem = ToDoItem(nombre: textField.text!)
            }
                
        }
    }
}
