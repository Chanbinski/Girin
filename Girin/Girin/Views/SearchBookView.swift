//
//  SearchBookView.swift
//  girin
//
//  Created by 박찬빈 on 9/13/22.
//

import SwiftUI



struct SearchBookView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.dismiss) var dismiss
    
    var books: FetchedResults<Book>
    // var books: [BookItem]
    @State private var searchText: String = ""
    
    var body: some View {
        
        VStack() {
            List {
                let filteredBooks = searchText.isEmpty ? books.filter { _ in true } : books.filter { ($0.userData?.userTitle ?? "").contains(searchText) }
                ForEach(filteredBooks, id: \.self) { book in
                    NavigationLink {
                        BookView(book: book)
                    } label: {
                        HStack {
                            BookImage(image: book.cache?.thumbnail ?? "", width: 80.0, height: 128.0)
                                .padding(.trailing, 10.0)
                            VStack(alignment: .leading) {
                                Text((book.userData?.userTitle ?? ""))
                                    .fontWeight(.bold)
                                    .padding(.bottom, 3.0)
                                Text(book.userData?.userAuthor ?? "")
                                    .font(.callout)
                                    .foregroundColor(Color.gray)
                                    .padding(.bottom, 3.0)
                                Text("읽은 날: " + dateToString(date: book.userData?.readDate ?? Date()))
                                    .font(.caption)
                                    .foregroundColor(Color.gray)
                                    .padding(.bottom, 1.0)
                                Text("한 줄 리뷰: " + (book.userData?.oneLineSum ?? ""))
                                    .font(.caption)
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .frame(height: 150)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .listStyle(.plain)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("나의 책들", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Color.defaultColor)
                }
            }
        }
        .padding(.horizontal, 20.0)
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

}

//struct SearchBookView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBookView()
//    }
//}
