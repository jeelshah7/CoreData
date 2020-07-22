//
//  ResultModelView.swift
//  QSTask
//
//  Created by Dhrupal Shah on 21/07/20.
//  Copyright © 2020 Jeel Shah. All rights reserved.
//

import Foundation

class ResultModelView {
    var name: String
    var vicinity: String
    var imageData: Box<Data?> = Box(nil)
    
    init(result: Result) {
        name = result.name
        vicinity = result.vicinity
        if let url = URL(string: result.icon){
            getData(url: url)
        }
    }
    
    func getData(url: URL){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if(error == nil)
            {
                self.imageData.value = data
            }
        }.resume()
    }
}
