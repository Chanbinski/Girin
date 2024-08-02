//
//  StatisticsView.swift
//  girin
//
//  Created by 박찬빈 on 9/20/22.
//

import SwiftUI
import Charts

struct BasicData: Identifiable {
    var name: String
    var count: Double
    var id = UUID()
}

struct StatisticsView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.dismiss) var dismiss
    
    var books: FetchedResults<Book>
    // var books: [BookItem]
    @State var selectedTimePeriod: String
    
    
    private let timePeriod = ["이번 달", "3개월", "1년", "전체"]
    private let categories = ["_", "총류", "철학", "종교", "사회과학", "자연과학", "기술과학", "예술", "언어", "문학", "역사", "기타"]
    @State var catData: [BasicData] = []
    @State var authorData: [BasicData] = []
    @State var totalBooks: Int = 0
    
    func calcBooksByCat() {
        
        catData = []
        let filteredBooks = books.filter { isIncluded($0.userData?.readDate ?? Date()) }
        
        totalBooks = filteredBooks.count
        
        var counts = [String: Int]()
        filteredBooks.forEach { counts[$0.userData?.category ?? "."] = (counts[$0.userData?.category ?? "."] ?? 0) + 1 }
        
        for cat in categories {
            let element = BasicData(name: cat, count: Double(counts[cat] ?? 0))
            catData.append(element)
        }
        
        catData = catData.sorted(by: { $0.count > $1.count } )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Menu {
                    Picker("기간", selection: $selectedTimePeriod) {
                        ForEach(timePeriod, id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: selectedTimePeriod) { value in
                        calcBooksByCat()
                    }
                } label: {
                    Text("\(selectedTimePeriod)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.defaultColor)
                        .padding(.trailing, 2.0)
                    Image(systemName: "chevron.down")
                        .font(.footnote)
                        .foregroundColor(.defaultColor)
                }
                Spacer()
            }
            .padding(.vertical, 10.0)
            
            HStack {
                Spacer()
                HStack(spacing: 0) {
                    Text("\(totalBooks)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                    .frame(width: 60, height: 60, alignment: .center)
                    .padding()
                    .overlay(
                        Circle()
                        .stroke(Color.blue, lineWidth: 10)
                        .padding(6)
                    )
                Spacer()
            }
            .padding(.bottom, 50)
            
            VStack(alignment: .leading) {
                Text("카테고리별")
                
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(catData.prefix(4)) { item in
                            if item.count > 0 {
                                BarMark(
                                    x: .value("Name", item.name),
                                    y: .value("Count", item.count)
                                )
                            }
                        }
                    }
                } else {
                    Text("ios 16 이상부터 지원합니다.")
                }
            }
            .frame(height: 300)
            
            Spacer()
            
//            VStack(alignment: .leading) {
//                Text("저자별")
//
//                if #available(iOS 16.0, *) {
//                    Chart {
//                        BarMark(
//                            x: .value("저자 이름", topAuthNames[0]),
//                            y: .value("책 수", topAuthCount[0])
//                        )
//                        BarMark(
//                            x: .value("저자 이름", topAuthNames[1]),
//                            y: .value("책 수", topAuthCount[1])
//                        )
//                        BarMark(
//                            x: .value("저자 이름", topAuthNames[2]),
//                            y: .value("책 수", topAuthCount[2])
//                        )
//                    }
////                    .frame(height: 150)
//                    .foregroundColor(Color.green)
//                } else {
//                    // Fallback on earlier versions
//                    Text("ios 16 이상부터 지원합니다.")
//                }
//            }
//            Spacer()
        }
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
        }
        .padding(.horizontal, 20.0)
        .onAppear {
            calcBooksByCat()
        }
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
        
        if (selectedTimePeriod == "전체") { return true }
        else if (selectedTimePeriod == "1년") {
            if (currentYear == inputYear) { return true }
            else if (currentYear - inputYear == 1 && currentMonth < inputMonth) { return true }
            else { return false }
        }
        else if (currentYear - inputYear <= 1) {
            if (selectedTimePeriod == "3개월") {
                if (currentMonth < inputMonth) { currentMonth += 12 }
                if (currentMonth - inputMonth < 3) { return true }
            }
            else if (selectedTimePeriod == "이번 달" && currentMonth == inputMonth) {
                return true
            }
        }
        return false
    }
}

//struct StatisticsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatisticsView()
//    }
//}
