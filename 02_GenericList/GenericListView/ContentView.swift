//
//  ContentView.swift
//  GenericListView
//
//  Created by yeonhoc5 on 11/21/23.
//

import SwiftUI

struct ContentView: View {
    @State var editMode: EditMode = .inactive
    @State var isPresentAddButton: Bool = false
    @State var isPresentBlurView: Bool = false
    var body: some View {
        GenericList(items: sampleList, 
                    editMode: $editMode,
                    rowContent: { item in
            // 로우 View
            Text("리스트 로우 타이틀 : \(item.title)")
        }, onTapAction: { int in
            // 탭액션
        }, onMoveAction: { from, to in
            // 이동 액션
        }, onDeleteAction: { on in
            // 지우기 액션
        }, isPresentBlurView: isPresentBlurView,
                    blurViewTapAction: {
            // blurView tap action
        }, isPresentAddBttn: $isPresentAddButton,
                    addBttnPlaceHolder: "",
                    bindingStirng: .constant("")) {
            // addbutton action
        }
    }
}

#Preview {
    ContentView()
}
