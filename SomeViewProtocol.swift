//
//  SomeViewProtocol.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/22/23.
//

import SwiftUI

protocol SomeView {
    associatedtype Body: View
    @ViewBuilder func makeView() -> Body
}

struct MyText: SomeView {
    func makeView() -> some View {
        Text("Hi")
    }
}

struct SomeViewProtocol: View {
    
    var viewMaker: MyText
    
    var body: some View {
        viewMaker.makeView()
    }
}

#Preview {
    SomeViewProtocol(viewMaker: MyText())
}
