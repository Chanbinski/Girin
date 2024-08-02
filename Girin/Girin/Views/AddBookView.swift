//
//  Search.swift
//  girin
//
//  Created by 박찬빈 on 9/10/22.
//

import SwiftUI

class AddBookViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var errorMessage: String = ""
    @Published var noResult: Bool = false
    @Published var searchResultKakao: Array<Document> = []

    let jsconDecoder: JSONDecoder = JSONDecoder()
    
    func resetSearch() {
        self.searchText = ""
        self.searchResultKakao = []
        self.errorMessage = ""
        self.noResult = false
    }
    
    func requestAPIToKakao(queryValue: String) {
        
        let restAPIKey = "KakaoAK a703662afb63022efa90bd460d8e7d30"
        
        let query: String = "https://dapi.kakao.com/v3/search/book?query=\(queryValue)"
        let encodedQuery: String = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: encodedQuery)!
        
        var requestURL = URLRequest(url: queryURL)
        requestURL.addValue(restAPIKey, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: requestURL) { [weak self] data, response, error in
            guard error == nil else { self?.errorMessage = error?.localizedDescription ?? "No error"; return }
            guard let data = data else { self?.errorMessage = error?.localizedDescription ?? "No error"; return }
            
            do {
                let searchInfo: KakaoBook = try self?.jsconDecoder.decode(KakaoBook.self, from: data) as! KakaoBook
                DispatchQueue.main.async {
                    self?.searchResultKakao = searchInfo.documents
                    self?.noResult = searchInfo.documents.isEmpty ? true : false
                    self?.errorMessage = ""
                }
            } catch {
                print(fatalError())
            }
        }
        task.resume()
        
    }

}

struct AddBookView: View {
    
    // Core Data
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var vm = AddBookViewModel()
    
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack() {
            HStack() {
                HStack() {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.defaultColor)
                    TextField("책을 검색하세요", text: $vm.searchText, onCommit: {
                        vm.requestAPIToKakao(queryValue: vm.searchText)
                    })
                    .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .padding()
                            .offset(x: 10)
                            .foregroundColor(Color.defaultColor)
                            .opacity(vm.searchText.isEmpty ? 0.0 : 1.0)
                            .onTapGesture {
                                vm.searchText = ""
                            }
                        
                        ,alignment: .trailing
                    )
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.modeColor)
                        .shadow(
                            color: Color.defaultColor.opacity(0.15),
                            radius: 3, x: 0, y: 0)
                )
                Spacer()
                    .frame(width: 15.0)
                Button {
                    showSheet.toggle()
                    vm.resetSearch()
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color.defaultColor)
                        .font(.title2)
                }
            }
            .padding(.bottom, 10.0)
            
            Text("다음은 카카오 책 API를 이용한 검색 결과입니다.")
                .font(.footnote)
                .foregroundColor(Color.gray)
            
            if vm.noResult {
                Text("검색 결과가 없습니다.")
                    .padding(.top, 30)
            } else if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage)
                    .padding(.top, 30)
            }
            
            List {
                ForEach(vm.searchResultKakao, id: \.self) { kakaoBook in
                    Button {
                        DataController().addBook(data: kakaoBook, context: managedObjContext)
                        showSheet.toggle()
                        vm.resetSearch()
                    } label: {
                        HStack {
                            BookImage(image: kakaoBook.thumbnail, width: 80.0, height: 128.0)
                                .padding(.trailing, 10.0)
                            VStack(alignment: .leading) {
                                Text(kakaoBook.title)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 3.0)
                                Text(kakaoBook.authors.joined(separator: ", "))
                                    .font(.callout)
                                    .foregroundColor(Color.gray)
                                    .padding(.bottom, 3.0)
                                Text(kakaoBook.publisher + ", " + kakaoBook.datetime.prefix(4))
                                    .font(.caption)
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .frame(height: 150)
                    }
                }
            }
            .listStyle(.plain)
            Spacer()
        }
        .padding(.top, 25.0)
        .padding([.leading, .trailing])
        .background(Color.modeColor.edgesIgnoringSafeArea(.all))
    }
}
