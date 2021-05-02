//
//  Book.swift
//  Readmore
//
//  Created by Mikaela Tang on 2021-01-04.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Book : Codable, Identifiable {
    @DocumentID var id : String?
    var title : String
    var author : String
    var completed : Bool
    @ServerTimestamp var createdTime : Timestamp?
    var userId : String?
}

struct RecommendedBook : Hashable {
    var title : String
    var author : String
}

#if DEBUG
let testDataBooks = [
    Book(title: "The Lord of the Rings", author: "J.R.R Tolkien", completed: false),
    Book(title: "Romeo and Juliet", author: "Shakespeare", completed: true),
    Book(title: "The Cheese", author: "Mikaela Tang", completed: false)
]
#endif
