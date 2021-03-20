//
//  EditProjectToolbar.swift
//  Composify
//
//  Created by Eirik Vale Aase on 20/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct EditProjectToolbar: ViewModifier {
    @Binding var isPresented: Bool
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        Text("Edit Project")
                    })
                }
            }
    }
}

extension View {
    func editProjectToolbar(isPresented: Binding<Bool>) -> some View {
        modifier(EditProjectToolbar(isPresented: isPresented))
    }
}
