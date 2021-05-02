//
//  ReadingListView.swift
//  Readmore
//
//  Created by Mikaela Tang on 2020-12-30.
//

import SwiftUI
import UIKit
import FirebaseAuth
import SwiftSoup

class RecommendedViewController {
    // Chapters Indigo URL
    let baseurl1 : String = "https://www.chapters.indigo.ca/en-ca/home/search/?keywords="
    let baseurl2 : String = "#internal=1"
    @ObservedObject var bookListVM : BookListViewModel
    
    init (bookListVM : BookListViewModel) {
        self.bookListVM = bookListVM
    }
    
    func loadRecommended() -> [RecommendedBook] {
        var recommendedBooks : [RecommendedBook] = []
        
        // Find recommendations for each author in reading list
        for bookCellVM in bookListVM.bookCellViewModels {
            let title : String = bookCellVM.book.title
            let author : String = bookCellVM.book.author
            var authorLst : [String] = author.components(separatedBy: " ")
            var middleurl : String = ""
            
            if (authorLst.count > 0) {
                middleurl = authorLst[0]
                authorLst.remove(at: 0)
            }
            
            for s in authorLst {
                middleurl = middleurl + "%20" + s
            }
            
            if middleurl != "" {
                let url = URL(string: baseurl1 + middleurl + baseurl2)
                
                do {
                    // grab and process html from url
                    let html = try String(contentsOf: url!, encoding: String.Encoding.ascii)
                    let doc: Document = try SwiftSoup.parse(html)
                    let lst : [Element] = try doc.getElementsByClass("product-list__product-title-group").array()
                    
                    for item in lst {
                        let newTitle = try item.select("h3").first()!.select("a").first()!.text()
                        let newAuthor = try item.select("p").first()!.select("a").first()!.text()
                        
                        if (newTitle != title && newAuthor == author) {
                            recommendedBooks.append(RecommendedBook(title: newTitle, author: newAuthor))
                        }
                    }
                    
                } catch Exception.Error(type: let type, Message: let message) {
                    print(type)
                    print(message)
                } catch {
                    print("")
                }
            }
        }
        
        return recommendedBooks
    }
}

struct TempRLView: View {
    @State var nextView = true
    
    var body: some View {
        NavigationLink(destination: MainView().navigationBarBackButtonHidden(true), isActive: $nextView) {
            EmptyView()
        }
    }
}

struct MainView: View {
    @ObservedObject var bookListVM = BookListViewModel()
    @State var signOut = false
    
    @State private var index = 0
    
    var body: some View {
        VStack {
            // Navigation link to return to sign in/login screen
            NavigationLink(destination: ContentView().navigationBarHidden(true), isActive: $signOut){
                EmptyView()
            }
            
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5)) {
                        self.index = 0
                    }
                }) {
                    Text("Reading List")
                        .foregroundColor(self.index == 0 ? .black : .white)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 2, height: 50)
                }
                .background(self.index == 0 ? Constants.Colours.lightGray : Color.clear)
                .clipShape(Capsule())
                
                Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5)) {
                        self.index = 1
                    }
                }) {
                    Text("For You")
                        .foregroundColor(self.index == 1 ? .black : .white)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 2, height: 50)
                }
                .background(self.index == 1 ? Constants.Colours.lightGray : Color.clear)
                .clipShape(Capsule())
            }
            .background(Color.black.opacity(0.1))
            .clipShape(Capsule())
            
            // shows reading list or for you depending on user selection
            if self.index == 0 {
                ReadingListView(bookListVM: bookListVM)
            } else {
                RecommendedView(bookListVM: bookListVM, books: RecommendedViewController(bookListVM: bookListVM).loadRecommended())
            }
        }
        .background(Constants.Colours.lightGray)
        .navigationBarItems(
            trailing:
                Button(action: {
                    // Sign out user from firebase
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("Error: Could not sign current user out.")
                    }
                    
                    self.signOut = true
                    
                }) {
                    Text("Sign Out")
                        .padding()
                        .foregroundColor(Constants.Colours.darkCyan)
                })
    }
}

struct ReadingListView: View {
    @ObservedObject var bookListVM : BookListViewModel
        
    @State var presentAddNewItem = false
    
    var body: some View {
        VStack (alignment: .leading) {
            List {
                ForEach (bookListVM.bookCellViewModels) { bookCellVM in
                    BookCell(bookCellVM: bookCellVM)
                }
                
                // Adds new book when user clicks on "Add New Book" button
                // Once user enters, new book object is added to list
                if presentAddNewItem {
                    BookCell(bookCellVM: BookCellViewModel(book: Book(title: "", author: "", completed: false))) { book in
                        bookListVM.addBook(book)
                        self.presentAddNewItem.toggle()
                    }
                }
            }
            
            // Allow user to add new book
            Button(action: {self.presentAddNewItem.toggle()}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Constants.Colours.darkCyan)
                    
                    Text("Add New Book")
                        .foregroundColor(Constants.Colours.darkCyan)
                }
            }
            .padding()
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
        }
    }
}

struct RecommendedView: View {
    @ObservedObject var bookListVM : BookListViewModel
    @State var books : [RecommendedBook]
        
    var body: some View {
        VStack (alignment: .leading) {
            if books.isEmpty {
                List {
                    Text("No recommendations at the moment")
                }
            } else {
                List {
                    ForEach (books, id: \.self) { book in
                        RecommendedBookCell(book: book)
                    }
                }
            }
        }
    }
}

struct BookCell : View {
    @ObservedObject var bookCellVM : BookCellViewModel
    
    var onCommit : (Book) -> (Void) = {_ in}
    
    var body : some View {
        VStack{
            HStack {
                Image(systemName: bookCellVM.book.completed ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        self.bookCellVM.book.completed.toggle()
                    }
                
                TextField("Enter book title", text: $bookCellVM.book.title, onCommit: {self.onCommit(self.bookCellVM.book)})
            }
            
            HStack {
                Text("By")
                TextField("Enter author name", text: $bookCellVM.book.author)
            }
        }
    }
}

struct RecommendedBookCell : View {
    @State var book : RecommendedBook
    
    var body : some View {
        VStack (alignment: .leading) {
            Text(book.title)
            HStack {
                Text("By")
                Text(book.author)
            }
        }
    }
}
