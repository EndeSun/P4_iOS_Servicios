//
//  NumItemsViewController.swift
//  ToDoList
//
//  Created by Domingo on 12/5/15.
//  Copyright (c) 2015 Universidad de Alicante. All rights reserved.
//

import UIKit

class NumItemsViewController: UIViewController {

    var terminados = 0
    @IBOutlet weak var numItems: UILabel!
    let store = NSUbiquitousKeyValueStore.default

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        numItems.text = "Se han completado \(terminados) ítems."
        
        //Store in the icloud
        let itemcount: Int = Int(terminados)
        print("Guardando el valor \(itemcount)")
        store.set(itemcount, forKey: "itemNum")
        store.synchronize()
        

        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
