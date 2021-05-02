//
//  DeleteButtonStyle.swift
//  Composify
//
//  Created by Eirik Vale Aase on 02/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct DeleteButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
        .font(.headline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .foregroundColor(configuration.isPressed ? Color.white.opacity(0.5) : Color.white)
        .listRowBackground(configuration.isPressed ? Color.red.opacity(0.5) : Color.red)
  }
}
