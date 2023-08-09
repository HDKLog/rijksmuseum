//
//  CollectionItem.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 09.08.23.
//

import Foundation

struct CollectionItem {
    struct Image {
        let width: Int
        let height: Int
        let url: URL?
    }

    let id: String
    let title: String
    let description: String
    let webImage: Image
    let headerImage: Image
}
