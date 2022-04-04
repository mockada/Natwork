//
//  ViewController.swift
//  Natwork
//
//  Created by Jade Silveira on 04/04/2022.
//  Copyright (c) 2022 Jade Silveira. All rights reserved.
//

import UIKit
import Natwork

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let service = Service(network: Network())
        service.fetchData { result in
            switch result {
            case .success(let responseList):
                // do something
                print(responseList)
                
            case .failure(let error) where error == .objectParse:
                // do something
                break
                
            case .failure:
                // do something
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

