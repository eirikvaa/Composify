//
//  SectionHeaderView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct SectionHeaderView: View {
    let section: Section

    var body: some View {
        HStack {
            Text(section.title)
                .font(.title)
                .bold()
                .padding()
            Spacer()
        }
    }
}

struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView(section: Section())
    }
}
