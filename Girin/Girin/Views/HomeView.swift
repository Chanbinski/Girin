//
//  Home.swift
//  girin
//
//  Created by 박찬빈 on 9/9/22.
//

import SwiftUI

extension Color {
    static let defaultColor = Color("defaultColor")
    static let modeColor = Color("modeColor")
}

struct User {
    let uid, email, username: String
}

class HomeViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var isUserCurrentlyLoggedOut = false
    @Published var showSheet: Bool = false
    
    @Published var timePeriod = ["이번 달", "3개월", "1년", "전체"]
    @Published var selectedTimePeriod = "이번 달"
    
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
    
    func isIncluded(_ input: Date) -> Bool {
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: date)
        let inputComponents = calendar.dateComponents([.month, .year], from: input)
        
        var currentMonth = components.month ?? 0
        let currentYear = components.year ?? 0
        let inputMonth = inputComponents.month ?? 0
        let inputYear = inputComponents.year ?? 0
        
        if (self.selectedTimePeriod == "전체") { return true }
        else if (self.selectedTimePeriod == "1년") {
            if (currentYear == inputYear) { return true }
            else if (currentYear - inputYear == 1 && currentMonth < inputMonth) { return true }
            else { return false }
        }
        else if (currentYear - inputYear <= 1) {
            if (self.selectedTimePeriod == "3개월") {
                if (currentMonth < inputMonth) { currentMonth += 12 }
                if (currentMonth - inputMonth < 3) { return true }
            }
            else if (self.selectedTimePeriod == "이번 달" && currentMonth == inputMonth) {
                return true
            }
        }
        return false
    }
}

struct HomeView: View {
    
    @ObservedObject private var vm = HomeViewModel()
    
    // Fetch from Core Data
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.userData?.readDate, order: .reverse)]) var books: FetchedResults<Book>
    
    var layout = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack() {
                VStack() {
                    // Header
                    HStack() {
                        HStack(alignment: .center) {
                            Text("Girin")
                                .font(.title)
                                .fontWeight(.black)
//                                .foregroundStyle(
//                                    LinearGradient(
//                                        colors: [.defaultColor, .yellow, .brown],
//                                        startPoint: .leading,
//                                        endPoint: .trailing
//                                    )
//                                )
                        }
                        Spacer()
                        HStack() {
                            NavigationLink {
                                SearchBookView(books: books)
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.defaultColor)
                            }
                        }
                    }
                    
                    // Filter
                    HStack() {
                        Menu {
                            Picker("기간", selection: $vm.selectedTimePeriod) {
                                ForEach(vm.timePeriod, id: \.self) {
                                    Text($0)
                                }
                            }
                            
                        } label: {
                            Text("\(vm.selectedTimePeriod)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.defaultColor)
                                .padding(.trailing, 2.0)
                            Image(systemName: "chevron.down")
                                .font(.footnote)
                                .foregroundColor(.defaultColor)
                        }
                        
                        
                        Spacer()
                        NavigationLink {
                            StatisticsView(books: books, selectedTimePeriod: vm.selectedTimePeriod)
                        } label: {
                            Image(systemName: "chart.bar")
                                .font(.title3)
                                .foregroundColor(.defaultColor)
                        }
                    }
                    .padding(.vertical, 10.0)
                    .padding(.bottom, 5.0)
                    
                    // Grid of Books
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            LazyVGrid(columns: layout, spacing: 20) {
                                let filteredBooks = books.filter { vm.isIncluded($0.userData?.readDate ?? Date()) }
                                ForEach(filteredBooks) { bookItem in
                                    NavigationLink {
                                        BookView(book: bookItem)
                                    } label: {
                                        BookImage(image: bookItem.cache?.thumbnail ?? "", width: 100.0, height: 150.0)
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        
                        HStack {
                            Spacer()
                            Button {
                                vm.showSheet.toggle()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 70, height: 70)
                                        .shadow(radius: 10)
//                                        .foregroundStyle(
//                                            LinearGradient(
//                                                colors: [.brown, .yellow, .brown],
//                                                startPoint: .topLeading,
//                                                endPoint: .bottomTrailing
//                                            )
//                                        )
                                    
                                    Image(systemName: "plus")
                                        .foregroundColor(.modeColor)
                                        .font(.title2)
                                }
                            }
                        }
                        
                    }
                   
                }
                .padding(.horizontal)
                
                // Launch Search View
                ZStack {
                    if vm.showSheet {
                        AddBookView(showSheet: $vm.showSheet)
                            .padding(.top, 35.0)
                            .transition(.move(edge: .bottom))
                            .animation(.spring())
                    }
                }
                .zIndex(2.0)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
            
            
            
    }
}
