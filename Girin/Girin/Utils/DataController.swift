//
//  DataController.swift
//  girin
//
//  Created by 박찬빈 on 9/12/22.
//

import Foundation
import CoreData
import SwiftUI


 class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "BookModel")
    
    init() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("Failed to load the data \(error.localizedDescription)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data Saved.")
        } catch {
            print("We could not save the data...")
        }
    }
    
     func addBook(data: Document, context: NSManagedObjectContext) {
        let book = Book(context: context)
        let cache = BookCache(context: context)
        let userData = BookUserData(context: context)
        
        // Book
        book.isbn = data.isbn
         
        // BookCache
         cache.authors = data.authors
         cache.thumbnail = data.thumbnail
         cache.isbn = data.isbn
         cache.datetime = data.datetime
         cache.publisher = data.publisher
         cache.title = data.title
         
        // BookUserData
         userData.category = "_"
         userData.notes = ""
         userData.oneLineSum = ""
         userData.rating = "_"
         userData.readDate = Date()
         userData.userAuthor = data.authors.joined(separator: ", ")
         userData.userTitle = data.title
        
         book.cache = cache
         book.userData = userData
         save(context: context)
    }
    
    func editBook(book: Book, title: String, author: String, category: String, rating: String, date: Date, oneLineSum: String, notes: String, context: NSManagedObjectContext) {
        
        // BookUserData
        book.userData?.category = category
        book.userData?.notes = notes
        book.userData?.oneLineSum = oneLineSum
        book.userData?.rating = rating
        book.userData?.readDate = date
        book.userData?.userAuthor = author
        book.userData?.userTitle = title
        
        save(context: context)
    }
}

