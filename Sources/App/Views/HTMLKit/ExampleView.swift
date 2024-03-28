//
//  ExampleView.swift
//
//
//  Created by joker on 2024/3/28.
//

import HTMLKit

struct ExampleView: View {

    let context: InfoData

    var body: Content {
        Heading1 {
            "Hello, HTMLKit - \(context.name)"
        }
    }
}
