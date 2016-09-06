//
//  ViewController.swift
//  SampleSQLite
//
//  Created by Tuuu on 9/5/16.
//  Copyright © 2016 Tuuu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let createTable = CreateTable()
        createTable.connectToDataBase()
//        createTable.createTable()
        createTable.insertValues("cars")
//        createTable.selectAllValueInTable("cars")
    }

}

