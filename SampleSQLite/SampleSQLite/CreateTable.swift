//
//  CreateTable.swift
//  SampleSQLite
//
//  Created by Tuuu on 9/5/16.
//  Copyright © 2016 Tuuu. All rights reserved.
//

import Foundation
import SQLite
class CreateTable: NSObject{
    
    let path = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory, .UserDomainMask, true
        ).first!
    var db:Connection! = nil
    
    override init() {
        super.init()
        connectToDataBase()
    }
    func connectToDataBase()
    {
        print(path)
        
        do
        {
            db = try Connection("\(path)/db.sqlite3")
            db.trace { (info) in
                print(info)
            }
        }
        catch(let error as NSError)
        {
            print(error.description)
        }
    }
    func createTable()
    {
        //        let db = try Connection("path/to/db.sqlite3")
        
        let users = Table("users")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String>("email")
        
        
        
        let cars = Table("cars")
        let carId = Expression<Int64>("id")
        let carsName = Expression<String?>("name")
        
        let detailCars = Table("detailCars")
        let owner = Expression<Int64>("owner")
        //        let owner = Expression<Int64>("owner")
        
        do
        {
            try db.run(users.create { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(email, unique: true)
                })
            try db.run(cars.create(block: { (t) in
                t.column(carId, primaryKey: true)
                t.column(carsName)
                
            }))
            try db.run(detailCars.create(block: { (t) in
                t.column(carId, references: cars, carId)
                t.column(owner, references: users, id)
                t.primaryKey(carId, owner)
            }))
        }
        catch (let error as NSError)
        {
            print(error)
        }
    }
    func insertValues(tableName: String)
    {
        let table = Table("users")
        let name = Expression<String?>("name")
        let email = Expression<String>("email")
        for i in 0 ... 100
        {
            let insertValue = table.insert(name <- "Alice\(i)", email <- "email\(i).com")
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
            do
            {
                try db.run(insertValue)
            }
            catch (let error as NSError)
            {
                print(error)
            }
        }
        let cars = Table("cars")
        let carName = Expression<String?>("name")
        var insertValue = cars.insert(carName <- "Porscher")
        
        let detailCars = Table("detailCars")
        let carId = Expression<Int64>("id")
        let userId = Expression<Int64>("owner")
        
        do
        {
            //            try db.run(insertValue)
            insertValue = detailCars.insert(carId <- 1121, userId <- 2)
            try db.execute("PRAGMA foreign_keys = ON;")
            try db.run(insertValue)
        }
        catch (let error as NSError)
        {
            print(error)
        }
        //        deleteRow(tableName, id:3)
    }
    func deleteRow(tableName: String, id: Int64)
    {
        let table = Table(tableName)
        let idToDelete = Expression<Int64>("id")
        let userToDelete = table.filter(idToDelete == 3)
        do
        {
            try db.run(userToDelete.delete())
        }
        catch (let error as NSError)
        {
            print(error)
        }
    }
    func updateRow(tableName: String, id: Int64)
    {
        let table = Table(tableName)
        let alice = table.filter(id == rowid)
        
        //        try db.run(alice.update(email <- email.replace("mac.com", with: "me.com")))
        // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
        // WHERE ("id" = 1)
    }
    func selectAllValueInTable(tableName: String)
    {
        let table = Table(tableName)
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String>("email")
        do
        {
            for user in try db.prepare(table) {
                print("id: \(user[id]), name: \(user[name]), email: \(user[email])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
            }
            // SELECT * FROM "users"
        }
        catch (let error as NSError)
        {
            print(error)
        }
        //selecting columns
        do
        {
            for user in try db.prepare(table.select(id, email))
            {
                print(user[id])
            }
        }
        catch
        {
            
        }
        //Plucking Rows
        //        if let user = try db.pluck(table)
        //        {
        //
        //        }
        // SELECT * FROM "users" LIMIT 1
    }
    func filterRow()
    {
        let users = Table("users")
        let id = Expression<Int64>("id")
        let verified = Expression<Bool>("verified")
        let email = Expression<String>("email")
        users.filter(id == 1)
        users.filter([1, 2, 3, 4, 5].contains(id))
        users.filter(email.like("%@mac.com"))
        users.filter(verified && email.lowercaseString == "@mail")
        users.filter(id == 1 || email.lowercaseString == "@mail")
    }
    
    
    func queries()
    {
        let table = Table("users")
        let email = Expression<String>("email")
        let name = Expression<String?>("name")
        let query = table.select(email).filter(name != nil).order(email.desc, name).limit(5, offset: 10)
        
        
    }
    func aggregationFunc()
    {
        let users = Table("users")
        let name = Expression<String?>("name")
        let id = Expression<Int64>("id")
        let balance = Expression<Int64>("balance")
        do
        {
            let count = db.scalar(users.count)
            let countUserWithName = db.scalar(users.filter(name != nil).count)
            let max = db.scalar(users.select(id.max))
            let sum = db.scalar(users.select(balance.sum))
        }
        catch let error as NSError
        {
            print(error)
        }
    }
    func joinTable()
    {
        let table = Table("users")
        let user_id = Expression<Int64>("user_id")
        let id = Expression<Int64>("id")
        table.join(table, on: user_id == table[id])

        
    }
    
    func transaction()
    {
        let users = Table("users")
        let email = Expression<String>("email")
        let managerID = Expression<Int64>("managerID")
        do
        {
            try db.transaction {
                let rowid = try self.db.run(users.insert(email <- "betty@icloud.com"))
                try self.db.run(users.insert(email <- "cathy@icloud.com", managerID <- rowid))
            }
        }
        catch
        {
            
        }
    }
    
}