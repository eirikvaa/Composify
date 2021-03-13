//
//  SectionsPager.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftUI
import SwiftUIPager

class SectionsPagerViewModel: ObservableObject, SongRepositoryInjectable {
    @Published var recordings: [Recording] = []

    func loadRecordings(from section: Section) {
        recordings = songRepository.getRecordings(in: section)
    }
}

struct SectionsPager: View {
    @StateObject private var page: Page = .first()
    @StateObject private var viewModel = SectionsPagerViewModel()
    var sections: [Section]

    var body: some View {
        Pager(page: page, data: sections, id: \.id) { section in
            SectionPagerView(section: section, recordings: viewModel.recordings)
                .onAppear {
                    viewModel.loadRecordings(from: section)
                }
        }
    }
}

struct SectionsPager_Previews: PreviewProvider {
    static var previews: some View {
        SectionsPager(sections: [])
    }
}
