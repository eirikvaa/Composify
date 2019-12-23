//
//  AdministrateProjectTableView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class AdministrateProjectTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        configureTableView()
    }

    required init?(coder _: NSCoder) {
        fatalError("Not implemented")
    }
}

private extension AdministrateProjectTableView {
    func configureTableView() {
        keyboardDismissMode = .onDrag
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 100
    }
}
