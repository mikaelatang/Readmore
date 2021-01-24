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
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("User after logging in: \(Auth.auth().currentUser?.uid)")
        bookRepository.loadData(Auth.auth().currentUser?.uid)
        
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
