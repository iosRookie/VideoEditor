//
//  ViewController.swift
//  VideoEditor
//
//  Created by 杨永刚 on 2019/5/27.
//  Copyright © 2019 yyg. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var myTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myTableview.register(MainCell.self, forCellReuseIdentifier: "MainCell")
        let items = Observable.just([
            "Reverse",
            "Second Item",
            "Third Item"
            ])
        
        items
            .bind(to: self.myTableview.rx.items(cellIdentifier: "MainCell", cellType: UITableViewCell.self)){ (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .disposed(by:disposeBag)
        
        self.myTableview.rx
            .modelSelected(String.self)
            .subscribe(onNext: { value in
                print("开始选中====\(value)")
            })
            .disposed(by: disposeBag)
        
    }
    
    
}

