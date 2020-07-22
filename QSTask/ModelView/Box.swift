//
//  File.swift
//  QSTask
//
//  Created by Dhrupal Shah on 21/07/20.
//  Copyright © 2020 Jeel Shah. All rights reserved.
//

import Foundation

class Box<T> {
    typealias Listner = (T) -> Void
    var listner: Listner?
    
    var value: T {
        didSet {
            listner?(value)
        }
    }
    init(_ value: T){
        self.value = value
    }
    
    func bind(listner: Listner?) {
        self.listner = listner
        listner?(value)
    }
}
