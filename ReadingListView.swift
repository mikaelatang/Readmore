//
//  ReadingListView.swift
//  Readmore
//
//  Created by Mikaela Tang on 2020-12-30.
//

import SwiftUI
import FirebaseAuth

struct TempRLView: View {
    @State var nextView = true
    
    var body: some View {
        NavigationLink(destination: ReadingListView().navigationBarBackButtonHidden(true), isActive: $nextView) {
            EmptyView()
        }
    }
}

struct ReadingListView: View {
    @ObservedObject var bookListVM = BookListViewModel()
        
    @State var presentAddNewItem = false
    @State var signOut = false
    
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
            
            // Navigation link to return to sign in/login screen
            NavigationLink(destination: ContentView().navigationBarHidden(true), isActive: $signOut){
                EmptyView()
            }
        }
        .navigationBarTitle("Reading List")
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReadingListView()
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
