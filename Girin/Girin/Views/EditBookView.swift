//
//  EditBookView.swift
//  girin
//
//  Created by 박찬빈 on 9/13/22.
//

import SwiftUI

struct EditBookView: View {

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss

    @State var title: String
    @State var author: String
    @State var selectedCategory: String
    @State var selectedRating: String
    @State var date: Date
    @State var oneLineSum: String
    @State var notes: String

    var book: FetchedResults<Book>.Element
    
    @State private var showAlert = false
    @State private var showAlert2 = false
    @State private var showBookInfo = false
    
    private let categories = ["_", "총류", "철학", "종교", "사회과학", "자연과학", "기술과학", "예술", "언어", "문학", "역사", "기타"]
    private let ratings = ["_", "5", "4", "3", "2", "1"]

    var body: some View {

        VStack() {
            Text("\(title)")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 300, alignment: .center)
                .multilineTextAlignment(.center)

            List {

                // Category
                VStack(alignment: .leading) {
                    HStack {
                        Text("카테고리")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        Spacer()
                        Menu {
                            Picker("카테고리", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) {
                                    Text($0)
                                }
                            }

                        } label: {
                            Text(selectedCategory)
                                .font(.callout)
                                .foregroundColor(Color.blue)
                            Image(systemName: "folder.fill")
                                .font(.footnote)
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                .listRowSeparator(.hidden)

                // Rating
                VStack(alignment: .leading) {
                    HStack {
                        Text("평점")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        Spacer()
                        Menu {
                            Picker("평점", selection: $selectedRating) {
                                ForEach(ratings, id: \.self) {
                                    Text($0)
                                }
                            }

                        } label: {
                            Text(selectedRating)
                                .font(.callout)
                                .foregroundColor(Color.blue)
                            Image(systemName: "star.fill")
                                .font(.footnote)
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                .listRowSeparator(.hidden)

                // Date
                VStack(alignment: .leading) {
                    HStack {
                        Text("읽은 날")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        Spacer()
                        DatePicker(selection: $date, in: ...Date(), displayedComponents: .date) {
                        }
                        //clipped()
                        .labelsHidden()
                    }
                }
                .padding(.bottom, 10.0)
                .listRowSeparator(.hidden)

                // One Line Summary
                VStack(alignment: .leading) {
                    HStack {
                        Text("한 줄 리뷰")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    .padding(.bottom, 1.0)
                    ZStack {
                        ZStack {
                            Color.modeColor
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.defaultColor, radius: 0.7)
                            TextField("\(oneLineSum)", text: $oneLineSum)
                                .padding(5)
                                .padding(.leading, 5)
                        }
                    }

                }
                .padding(.bottom, 10.0)
                .listRowSeparator(.hidden)

                // Notes
                VStack(alignment: .leading) {
                    HStack {
                        Text("노트")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    .padding(.bottom, 1.0)
                    ZStack {
                        ZStack {
                            Color.modeColor
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.defaultColor, radius: 0.7)

                            Text(notes)
                                .padding(7)
                                .cornerRadius(12.0)
                            TextEditor(text: $notes)
                                .font(.callout)
                                .frame(alignment: .leading)
                                .padding(5)
                                .multilineTextAlignment(.leading)
                                .cornerRadius(12.0)
                        }
                    }
                }
                .padding(.bottom, 10.0)
                .listRowSeparator(.hidden)

                HStack(alignment: .center) {
                    Button {
                        showBookInfo.toggle()
                    } label: {
                        Text("도서 정보 수정")
                            .font(.footnote)
                            .foregroundColor(Color.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listRowSeparator(.hidden)

                if showBookInfo {

                    // Title
                    VStack(alignment: .leading) {
                        HStack {
                            Text("제목")
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        .padding(.bottom, 1.0)
                        ZStack {
                            Color.modeColor
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.defaultColor, radius: 0.7)
                            TextField("\(title)", text: $title)
                                .padding(5)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.bottom, 10.0)
                    .listRowSeparator(.hidden)

                    // Author
                    VStack(alignment: .leading) {
                        HStack {
                            Text("저자")
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        .padding(.bottom, 1.0)
                        ZStack {
                            Color.modeColor
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.defaultColor, radius: 0.7)
                            TextField("\(author)", text: $author)
                                .padding(5)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.bottom, 10.0)
                    .listRowSeparator(.hidden)

                    Text("위의 정보는 사용자에게 디스플레이 되는 책 정보입니다. 수정 사항은 카카오 책 검색 API 호출 결과와는 무관합니다.")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)

        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showAlert2 = true
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Color.defaultColor)
                }
                .alert(isPresented: $showAlert2) {
                    Alert(
                        title: Text("책 저장 취소"),
                        message: Text("이 페이지를 나가면 작성한 기록은 사라집니다. 나가시겠습니까?"),
                        primaryButton: .default(
                                        Text("취소"),
                                        action: {}
                        ),
                        secondaryButton: .destructive(
                            Text("확인"),
                            action: {
                                withAnimation {
                                    self.mode.wrappedValue.dismiss()
                                }
                            }
                        )
                    )
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAlert = true
                } label: {
                    Text("저장")
                }
                .foregroundColor(Color.defaultColor)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("책 저장"),
                        message: Text("내용을 저장하시겠습니까?"),
                        primaryButton: .default(
                                        Text("취소"),
                                        action: {}
                        ),
                        secondaryButton: .default(
                            Text("확인"),
                            action: {
                                withAnimation {
                                    DataController().editBook(
                                        book: book,
                                        title: title,
                                        author: author,
                                        category: selectedCategory,
                                        rating: selectedRating,
                                        date: date,
                                        oneLineSum: oneLineSum,
                                        notes: notes,
                                        context: managedObjContext
                                    )
                                    self.mode.wrappedValue.dismiss()
                                }
                            }
                        )
                    )
                }
            }
            
        } // toolbar
    } // body

} // struct


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
