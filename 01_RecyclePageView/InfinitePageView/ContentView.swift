//
//  ContentView.swift
//  InfinitePageView
//
//  Created by yeonhoc5 on 2023/02/21.
//

import SwiftUI

struct ContentView: View {
    var indexArray = Array(0...8)

    @State var indexToView = 3
    @State var isExpanded: Bool = false
    @Namespace var animationID
    @State private var offset: CGFloat = 0
    @State private var isUserSwiping: Bool = false
    
    var body: some View {
        VStack {
            titleView
            RepeatedPageView(count: indexArray.count,
                             indexToView: indexToView,
                             isExpanded: $isExpanded,
                             animationID: animationID) { offsetIndex, pageIndex in
                VStack {
                    // offset Index 뷰 (-2 ~ 2, 5개의 숫자)
                    offsetIndexView(offset: offsetIndex)
                    // page Index 뷰
                    pageIndexView(page: pageIndex,
                                  index: indexToView)
                }
                .onChange(of: offsetIndex) { newValue in
                    if newValue == 0 { indexToView = pageIndex }
                }
            }
        }
    }
}

extension ContentView {
    var titleView: some View {
        HStack {
            Text("항목 : \(indexArray.first!) ~ \(indexArray.last!) (현재 : \(indexToView))")
                .font(.system(size: 30))
                .foregroundColor(.black)
        }
    }
    
    func offsetIndexView(offset: Int) -> some View {
        Text("\(offset)")
            .foregroundColor(.white)
            .bold()
            .padding(.bottom, 10)
    }
    
    func pageIndexView(page: Int, index: Int) -> some View {
        Circle()
            .foregroundColor(.white)
            .frame(width: 40)
            .overlay{
                Text("\(page)")
                    .foregroundColor(.black)
            }
            .offset(y: abs(offset) == 2 ? 200 : 0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
