//
//  BookCellViewModel.swift
//  Readmore
//
//  Created by Mikaela Tang on 2021-01-04.
//

import Foundation
import Combine
import FirebaseAuth

class BookCellViewModel : ObservableObject, Identifiable {
    @Published var bookRepository = BookRepository()
    @Published var book : Book
    
    var id = ""
    @Published var completedStateIconName = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(book : Book) {
        self.book = book
        
        $book
            .map { book in
                book.completed ? "checkmark.circle.fill" : "circle"
            }
            .assign(to: \.completedStateIconName, on: self)
            .store(in: &cancellables)
        
        $book
            .compactMap { book in
                book.id
            }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
        
        // Updates firestore documents when changes are made
        $book
            .dropFirst()
            .debounce(for: 0.8, scheduler: RunLoop.main) // only updates firestore once user stops typing
            .sink { book in
                self.bookRepository.updateBook(book)
            }
            .store(in: &cancellables)
    }
}
