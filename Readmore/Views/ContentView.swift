//
//  ContentView.swift
//  Readmore
//
//  Created by Mikaela Tang on 2020-12-30.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

struct ContentView: View {
    @State var hasCurrentUser : Bool
    
    var body: some View {
        // If no user is logged in
        if hasCurrentUser == false {
            ZStack {
                // Background
                LinearGradient(gradient: .init(colors: [ Constants.Colours.lemon, Constants.Colours.mint, Constants.Colours.darkCyan]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                Home()
            }
        }
        
        // If some user is already logged in
        else {
            NavigationLink(destination: ReadingListView().navigationBarBackButtonHidden(true), isActive: $hasCurrentUser) {
                EmptyView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(hasCurrentUser: false)
    }
}

struct Home: View {
    @State private var index = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("readmore")
                    .font(.system(size: 60, weight: .light, design: .default))
                    .foregroundColor(Constants.Colours.darkCyan)
                    .offset(x: 9, y: 2)
                
                // Logo
                Image(systemName: "books.vertical")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Constants.Colours.darkCyan)
            }
            .offset(y: -UIScreen.main.bounds.height / 8)
            
            HStack {
                // Login and sign up buttons
                Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5)) {
                        self.index = 0
                    }
                }) {
                    Text("Login")
                        .foregroundColor(self.index == 0 ? .black : .white)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 50)
                }
                .background(self.index == 0 ? Constants.Colours.lightGray : Color.clear)
                .clipShape(Capsule())
                
                Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5)) {
                        self.index = 1
                    }
                }) {
                    Text("Sign Up")
                        .foregroundColor(self.index == 1 ? .black : .white)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 50)
                }
                .background(self.index == 1 ? Constants.Colours.lightGray : Color.clear)
                .clipShape(Capsule())
            }
            .background(Color.black.opacity(0.1))
            .clipShape(Capsule())
            
            // Show login or sign up text fields depending on user selection
            if self.index == 0 {
                Login()
            }
            
            else {
                SignUp()
            }
        }
    }
}



struct Login: View {
    @State private var error : String?
    @State private var showHomeScreen : Bool = false
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack (spacing: 10){
            TextField("Enter Email Address", text: self.$email)
                .padding()
                .background(Constants.Colours.lightGray)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .cornerRadius(10)
                        
            SecureField("Password", text: self.$password)
                .padding()
                .background(Constants.Colours.lightGray)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .cornerRadius(10)
            
            NavigationLink(destination: ContentView(hasCurrentUser: true).navigationBarBackButtonHidden(true), isActive: $showHomeScreen) {
                EmptyView()
            }
            
            // Login button
            Button(action: {
                // Validate fields
                let err : String? = self.validateFields()
                
                if err != nil {
                    error = err
                }
                
                else {
                    // Create cleaned versions of the text field
                    let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                    let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Signing in the user
                    Auth.auth().signIn(withEmail: cleanedEmail, password: cleanedPassword) { (result, err) in
                        
                        // Error signing in user
                        if err != nil {
                            error = err!.localizedDescription
                        }
                        
                        else {
                            showHomeScreen = true
                        }
                    }
                }
            }) {
                Text("LOGIN")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.vertical, 20)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 50)
            }
            .background(
                LinearGradient(gradient: .init(colors: [Constants.Colours.darkCyan, Constants.Colours.mint, Constants.Colours.lemon]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(8)
            .shadow(radius: 25)
            
            // Show error.
            if error != nil {
                Utilities.showError(error!)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
    }
    
    func validateFields() -> String? {
        // Check if fields are filled
        if email.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        return nil
    }
}



struct SignUp: View {
    @State private var error : String?
    @State private var showHomeScreen : Bool = false
    
    @State private var fullName : String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var password1: String = ""
    
    var body: some View {
        VStack (spacing: 10) {
            TextField("Last Name, First Name", text: $fullName)
                .padding()
                .background(Constants.Colours.lightGray)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .cornerRadius(10)
            
            TextField("Enter Email", text: $email)
                .padding()
                .background(Constants.Colours.lightGray)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .cornerRadius(10)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Constants.Colours.lightGray)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .cornerRadius(10)
            
            SecureField("Re-Enter Password", text: $password1)
                .padding()
                .background(Constants.Colours.lightGray)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .cornerRadius(10)
            
            NavigationLink(destination: ContentView(hasCurrentUser: true).navigationBarBackButtonHidden(true), isActive: $showHomeScreen) {
                EmptyView()
            }
            
            // Sign up button
            Button(action: {
                // Validate the fields
                let err : String? = validateFields()
                
                if err != nil {
                    error = err
                }
                
                else {
                    
                    // Create cleaned versions of the data
                    let cleanedFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                    let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Create the user
                    Auth.auth().createUser(withEmail: cleanedEmail, password: cleanedPassword) { (result, err) in
                        
                        // Check for errors
                        if err != nil {
                            
                            // There was an error creating the user
                            error = err!.localizedDescription
                        }
                        
                        else {
                            
                            // User was created successfully, now store the first name and last name
                            let db = Firestore.firestore()
                            
                            db.collection("users").addDocument(data:["fullName": cleanedFullName, "uid": result!.user.uid ]) { (err) in
                                
                                if err != nil {
                                    // Show error message
                                    error = "Error saving user data."
                                }
                                
                                else {
                                    print("Signed up: \(Auth.auth().currentUser?.uid)")
                                    showHomeScreen = true
                                }
                            }
                        }
                    }
                }
            }) {
                Text("SIGN UP")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.vertical, 20)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 50)
            }
            .background(
                LinearGradient(gradient: .init(colors: [Constants.Colours.darkCyan, Constants.Colours.mint, Constants.Colours.lemon]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(8)
            .shadow(radius: 25)
            
            // Show error.
            if error != nil {
                Utilities.showError(error!)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
    }
    
    func validateFields() -> String? {
        // Check if fields are empty
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines) == "" || email.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        // Check if email is valid
        if Utilities.isEmailValid(email.trimmingCharacters(in: .whitespacesAndNewlines)) == false {
            return "Please enter a valid email address."
        }
        
        // Check if password is valid
        if Utilities.isPasswordValid(password.trimmingCharacters(in: .whitespacesAndNewlines)) == false {
            return "Password must be at least 8 characters long, contains a special character and a number."
        }
        
        // Check if passwords are the same
        if self.password != self.password1 {
            return "The password you re-entered does not match that above it."
        }
        
         return nil
    }
}
