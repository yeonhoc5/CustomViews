//
//  RepeatedPageView.swift
//  InfinitePageView
//
//  Created by yeonhoc5 on 2023/06/14.
//

import SwiftUI

let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size
let colorSet: [Color] = [.red, .blue, .yellow, .green, .teal]

struct RepeatedPageView<Content: View>: View {
    
    let content: (_ offsetIndex: Int, _ pageIndex: Int) -> Content
    let count: Int
    var indexToView: Int
    let width: CGFloat = 100
    @State var offsetIndex = 0
    @Binding var isExpanded: Bool
    var animationID: Namespace.ID
    @State var isUserSwiping: Bool = false
    @State var pagingGesture: Bool = false
    @State var dismissingGesture: Bool = false
    
    @GestureState private var translation: CGSize = .zero
    @State var offsetX: CGFloat = .zero
    
    init(count: Int, indexToView: Int, isExpanded: Binding<Bool>, animationID: Namespace.ID,
         @ViewBuilder content: @escaping (_ page: Int, _ pageNum: Int) -> Content) {
        self.count = count
        self.indexToView = indexToView
        self.content = content
        self._isExpanded = isExpanded
        self.animationID = animationID
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .zIndex(0.2)
            ForEach(-2..<3) { int in
                if (0..<count).contains(calcPageIndex(offsetIndex - int, indexToView)) {
                    contentFrame(offsetIndex: calcOffsetIndex(offsetIndex - int),
                                 pageIndex: calcPageIndex(offsetIndex - int, indexToView),
                                 color: colorSet[int + 2])
                    .zIndex(calcZIndex(calcOffsetIndex(offsetIndex - int)))
                }
            }
        }
    }
}

extension RepeatedPageView {

    func contentFrame(offsetIndex: Int, pageIndex: Int, color: Color) -> some View {
        GeometryReader { geometry in
            content(offsetIndex, pageIndex)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(content: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.gradient)
                })
                .offset(x: self.isUserSwiping
                        ? CGFloat(offsetIndex) * (geometry.size.width + 10) + self.offsetX
                        : CGFloat(offsetIndex) * (geometry.size.width + 10))
                .gesture(dragGesture(geometry: geometry, pageIndex: pageIndex, offsetIndex: offsetIndex))
        }
        .offset(y: abs(offsetIndex) == 2 ? 200 : 0)
        .frame(width: 80, height: 200)
    }
    
    // 페이징 gesture
    private func dragGesture(geometry: GeometryProxy, pageIndex: Int, offsetIndex: Int) -> some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                isUserSwiping = true
                if !dismissingGesture && abs(value.translation.width) > abs(value.translation.height) {
                    pagingGesture = true
                }
                if pagingGesture {
                    if value.translation.width > 0 {
                        self.offsetX = min(value.translation.width, value.predictedEndTranslation.width)
                    } else {
                        self.offsetX = max(value.translation.width, value.predictedEndTranslation.width)
                    }
                }
            }
            .onEnded { value in
                if offsetIndex == 0 {
                    if pagingGesture {
                        if pageIndex > 0
                            && max(value.predictedEndTranslation.width, value.translation.width) > geometry.size.width / 3 {
                            pagingDirection(direction: .right)
                        } else if pageIndex < count - 1
                                    && min(value.predictedEndTranslation.width, value.translation.width) < -geometry.size.width / 3 {
                            pagingDirection(direction: .left)
                        } else {
                            nonePaging()
                        }
                    }
                    pagingGesture = false
                } else {
                    nonePaging()
                }
            }
    }
    
    private func pagingDirection(direction: Direction) {
        withAnimation(.linear) {
            if direction == .right {
                self.offsetIndex += 1
            } else if direction == .left {
                self.offsetIndex -= 1
            }
            isUserSwiping = false
        }
    }
    
    private func nonePaging() {
        withAnimation {
            self.offsetIndex = self.offsetIndex
            isUserSwiping = false
        }
    }
    
    private func calcOffsetIndex(_ current: Int) -> Int {
        if current >= 0 {
            let checkNum = current % 5
            return checkNum >= 3 ? checkNum - 5 : checkNum
        } else {
            let checkNum = (current * -1) % 5
            return checkNum >= 3 ? -checkNum + 5 : -checkNum
        }
    }
    
    private func calcPageIndex(_ index: Int, _ indexToView: Int) -> Int {
        return calcOffsetIndex(index) + indexToView
    }
    
    private func calcZIndex(_ offsetIndex: Int) -> CGFloat {
        return offsetIndex == 0 ? 1 : (abs(offsetIndex) == 1 ? 0.5 : 0)
    }
                            
    enum Direction {
        case right, left
    }
}
