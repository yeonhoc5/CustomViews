//
//  GenericList.swift
//  GenericListView
//
//  Created by yeonhoc5 on 11/21/23.
//

import SwiftUI

struct GenericList<Element, RowContent: View>: View where Element: Identifiable {
    
    let items: [Element]
    private let rowContent: (Element) -> RowContent
    
    private let onTapAction: (Element) -> Void
    private let onMoveAction: (_: IndexSet, _: Int) -> Void
    private let onDeleteAction: (_: IndexSet) -> Void
    
    // blutView
    var isPresentBlurView: Bool
    let blurViewTapAction: () -> Void
    
    // add button
    @Binding var isPresentAddBttn: Bool
    let addBttnPlaceHolder: String
    @Binding var bindingString: String
    @FocusState var isFocused
    let addBttnAction: () -> Void
    
    @Binding var editMode: EditMode
    @State var notHere: Bool = false
    @State var lastColor: Color = Color(red: 230/255, green: 230/255, blue: 230/255)
    
    public init(items: [Element],
                editMode: Binding<EditMode>,
                rowContent: @escaping (Element) -> RowContent,
                onTapAction: @escaping (Element) -> Void,
                onMoveAction: @escaping (_ from: IndexSet, _ to: Int) -> Void,
                onDeleteAction: @escaping (_ on: IndexSet) -> Void,
                isPresentBlurView: Bool,
                blurViewTapAction: @escaping () -> Void,
                isPresentAddBttn: Binding<Bool>,
                addBttnPlaceHolder: String,
                bindingStirng: Binding<String>,
                addBttnAction: @escaping () -> Void) {
        self.items = items
        _editMode = editMode
        self.rowContent = rowContent
        self.onTapAction = onTapAction
        self.onMoveAction = onMoveAction
        self.onDeleteAction = onDeleteAction
        self.isPresentBlurView = isPresentBlurView
        self.blurViewTapAction = blurViewTapAction
        _isPresentAddBttn = isPresentAddBttn
        self.addBttnPlaceHolder = addBttnPlaceHolder
        _bindingString = bindingStirng
        self.addBttnAction = addBttnAction
    }
    
    var body: some View {
        ZStack {
            listMaskView(color: .white, radius: 5)
            ScrollViewReader { proxy in
                List {
                    ForEach(items) { item in
                        eachRowView(item: item, lastColor: lastColor)
                            .id(items.firstIndex(where: {$0.id == item.id}))
                            .offset(x: editMode == .active ? -40 : 0)
                            .onTapGesture(perform: {
                                onTapAction(item)
                            })
                            .accentColor(.red)
                            .foregroundColor(.black)
                            .listRowBackground(Color.white)
                            .accentColor(Color.red)
                    }
                    .onMove { indexSet, int in
                        onMoveAction(indexSet, int)
                    }
                    .onDelete { indexSet in
                        onDeleteAction(indexSet)
                    }
                    Rectangle().fill(.white)
                        .id("listView")
                        .frame(height: 100)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.white)
                }
                .listStyle(.plain)
                .environment(\.editMode, $editMode)
            }
        }
        .padding(15)
        .mask {
            listMaskView(color: .white, radius: 5)
                .padding(15)
        }
        .shadow(color: .black, radius: 1, x: 0, y: 0)
            
        .overlay(alignment: .center) {
            if isPresentBlurView {
                blurViewWithTapAction {
                    blurViewTapAction()
                    isFocused = false
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(alignment: .bottomLeading) {
            if editMode != .active {
                AddButton(width: screenSize.width,
                          placeHolder: addBttnPlaceHolder,
                          isPresented: $isPresentAddBttn,
                          string: $bindingString,
                          isFocused: $isFocused) {
                    addBttnAction()
                }
                  .padding(.horizontal, 10)
                  .transition(.move(edge: screenSize.width < screenSize.height ? .leading : .bottom).combined(with: .opacity))
            }
        }
    }
    
    func eachRowView(item: Element, lastColor: Color) -> some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(.white)
                .overlay(alignment: .trailing, content: {
//                    if editMode == .active {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.teal)
                            .imageScale(.large)
                            .opacity(editMode == .active ? 1 : 0)
//                    }
                })
            rowContent(item)
        }
        .overlay(alignment: .trailing) {
            if editMode == .active {
                Image(systemName: "line.3.horizontal")
                    .imageScale(.large)
                    .offset(x: 33)
                    .transition(.push(from: .trailing))
            }
        }
        .padding(.leading, editMode == .active ? 0 : 40)
        .offset(x: editMode == .active ? 40 : 0)
        .background(alignment: .leading) {
            if let index = items.firstIndex(where: {$0.id == item.id}) {
                    Text(index < 9 ? "0\(index + 1)" : "\(index + 1)")
                        .foregroundStyle(lastColor)
                        .font(Font.system(size: 50, weight: .black, design: .monospaced))
                        .italic()
                        .kerning(-5)
                        .offset(x: -28)
                }
            }
    }
    
}

struct GenericList_Previews: PreviewProvider {
    static var previews: some View {
        GenericList(items: sampleList, editMode: .constant(.inactive), rowContent: { item in
            Text(item.title)
        }, onTapAction: { item in
            print("tapped", item.title)
        }, onMoveAction: { from, to in
            print(from, to)
        }, onDeleteAction: { indexSet in
            print("deleted", indexSet)
        }, isPresentBlurView: false, blurViewTapAction: {
            
        }, isPresentAddBttn: .constant(false), addBttnPlaceHolder: "추가할 리스트", bindingStirng: .constant("")) {
                
        }
    }
}


var screenSize: CGSize {
    get {
        guard let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size
        else {
            return CGSize(width: 200, height: 300)
        }
        return size
    }
}


struct ListRow: Identifiable {
    var id: Int
    var title: String
}

var sampleList: [ListRow] = [ListRow(id: 0, title: "List Row 1"),
                             ListRow(id: 1, title: "List Row 2"),
                             ListRow(id: 2, title: "List Row 3"),
                             ListRow(id: 3, title: "List Row 4")]
