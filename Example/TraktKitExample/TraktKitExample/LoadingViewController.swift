//
//  LoadingViewController.swift
//  TraktKitExample
//
//  Created by Maximilian Litteral on 2/22/26.
//

import UIKit

final class LoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var config = UIContentUnavailableConfiguration.loading()
        config.text = "TraktKit"
        contentUnavailableConfiguration = config
    }
}
