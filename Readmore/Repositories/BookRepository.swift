//
//  BookRepository.swift
//  Readmore
//
//  Created by Mikaela Tang on 2021-01-04.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class BookRepository {
    
    let db = Firestore.firestore()
    
    @Published var books = [Book]()
    
    func loadData(_ userId : String?) {
        db.collection("books")
            .order(by: "createdTime")
            .whereField("userId", isEqualTo: userId!)
            .addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.books = querySnapshot.documents.compactMap { document in
                    try? document.data(as: Book.self)
                }
            }
        }
    }
    
    // Adds new book to firestore
    func addBook(_ book : Book) {
        do {
            var addedBook = book
            addedBook.userId = Auth.auth().currentUser?.uid
            let _ = try db.collection("books").addDocument(from: addedBook)
        }
        catch {
            fatalError("Unable to encode book: \(error.localizedDescription)")
        }
    }
    
    // Updates existing book in firestore
    func updateBook(_ book : Book) {
        if let bookID = book.id {
            do {
                let _ = try db.collection("books").document(bookID).setData(from: book)
            }
            catch {
                fatalError("Unable to encode book: \(error.localizedDescription)")
            }
        }
    }
}
