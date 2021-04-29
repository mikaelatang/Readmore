//
//  BookListViewModel.swift
//  Readmore
//
//  Created by Mikaela Tang on 2021-01-04.
//

import Foundation
import Combine
import FirebaseAuth

class BookListViewModel : ObservableObject {
    @Published var bookRepository = BookRepository()
    @Published var bookCellViewModels = [BookCellViewModel]()
    var currentUser = Auth.auth().currentUser?.uid
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bookRepository.loadData(currentUser)
        
        bookRepository.$books.map { books in
            books.map { book in
                BookCellViewModel(book: book)
            }
        }
        .assign(to: \.bookCellViewModels, on: self)
        .store(in: &cancellables)
    }
    
    func addBook(_ book : Book) {
        bookRepository.addBook(book)
    }
}
