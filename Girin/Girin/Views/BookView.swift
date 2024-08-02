//
//  BookView.swift
//  girin
//
//  Created by 박찬빈 on 9/12/22.
//

import SwiftUI
import CoreData

class BookViewModel: ObservableObject {
    
    @Published var showAlert = false
    @Published var errorMessage: String = ""
    
    func deleteBookFromCoreData(book: FetchedResults<Book>.Element, context: NSManagedObjectContext) {
        context.delete(book)
        DataController().save(context: context)
    }
    
    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
}

struct BookView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var vm = BookViewModel()
    
    var book: FetchedResults<Book>.Element
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack() {
                VStack(alignment: .center) {
                    BookImage(image: book.cache?.thumbnail ?? "", width: 100.0, height: 150.0)
                        .padding(.bottom, 10.0)
                    
                    Text("\(book.userData?.userTitle ?? "")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 3.0)
                    
                    Text("\(book.userData?.userAuthor ?? "")")
                        .font(.callout)
                        .foregroundColor(Color.gray)
                        .padding(.bottom, 2.0)
                    
                    Text("\(((book.cache?.publisher ?? "") + ", " + (book.cache?.datetime ?? "").prefix(4)) )")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                        .padding(.bottom, 7.0)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        ZStack {
                            Color.modeColor
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.defaultColor, radius: 0.7)
                            //.border(Color.gray, width: 0.7)
                            
                            
                            HStack() {
                                Spacer()
                                HStack(spacing: 0) {
                                    Image(systemName: "folder")
                                        .padding(.trailing, 3.0)
                                    Text("\(book.userData?.category ?? "")")
                                    
                                }
                                Spacer()
                                HStack(spacing: 0) {
                                    Image(systemName: "calendar")
                                        .padding(.trailing, 3.0)
                                    Text(vm.dateToString(date: book.userData?.readDate ?? Date()))
                                }
                                Spacer()
                                HStack(spacing: 0) {
                                    Image(systemName: "star.circle")
                                        .padding(.trailing, 3.0)
                                    Text("\(book.userData?.rating ?? "")점")
                                }
                                Spacer()
                            }
                            .foregroundColor(Color.gray)
                            .font(.footnote)
                            .padding(7)
                        }
                        Spacer()
                    }
                    
                }
                .padding(.bottom, 20.0)
                
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("한 줄 리뷰")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    Divider()
                        .padding(.bottom, 3.0)
                    Text(book.userData?.oneLineSum ?? "")
                        .foregroundColor(Color.defaultColor)
                        .font(.callout)
                    Spacer()
                }
                
                .padding(.bottom, 20.0)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("노트")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    Divider()
                        .padding(.bottom, 3.0)
                        .padding(.bottom, 1.0)
                    Text(book.userData?.notes ?? "")
                        .foregroundColor(Color.defaultColor)
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20.0)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Color.defaultColor)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    EditBookView(
                        title: book.userData?.userTitle ?? "",
                        author: book.userData?.userAuthor ?? "",
                        selectedCategory: book.userData?.category ?? "",
                        selectedRating: book.userData?.rating ?? "",
                        date: book.userData?.readDate ?? Date(),
                        oneLineSum: book.userData?.oneLineSum ?? "",
                        notes: book.userData?.notes ?? "",
                        book: book)
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(Color.defaultColor)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.showAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(Color.defaultColor)
                }
                .alert(isPresented: $vm.showAlert) {
                    Alert(
                        title: Text("책 삭제"),
                        message: Text("노트를 포함한 작성한 모든 데이터가 삭제됩니다. 정말 삭제할까요?"),
                        primaryButton: .default(
                            Text("취소"),
                            action: {}
                        ),
                        secondaryButton: .destructive(
                            Text("확인"),
                            action: {
                                vm.deleteBookFromCoreData(book: book, context: managedObjContext)
                                self.mode.wrappedValue.dismiss()
                            }
                        )
                    )
                }
            }
        }
    }
    
}
