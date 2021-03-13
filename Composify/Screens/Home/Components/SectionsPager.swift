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
    enum State {
        case noRecordings
        case recordings([Recording])
    }
    @Published var state: State = .noRecordings

    func loadRecordings(from section: Section) {
        let recordings = songRepository.getRecordings(in: section)

        if recordings.isEmpty {
            state = .noRecordings
            return
        }

        state = .recordings(recordings)
    }
}

struct SectionsPager: View {
    @StateObject private var page: Page = .first()
    @StateObject private var viewModel = SectionsPagerViewModel()
    var sections: [Section]

    var body: some View {
        Pager(page: page, data: sections, id: \.id) { section in
            VStack {
                HStack {
                    Text(section.title)
                        .font(.title)
                        .bold()
                        .padding()
                    Spacer()
                }

                switch viewModel.state {
                case .recordings(let recordings):
                    SectionPagerView(section: section, recordings: recordings)
                case .noRecordings:
                    Spacer()
                    Text("No recordings, try recording some good stuff.")
                    Spacer()
                }
            }
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
