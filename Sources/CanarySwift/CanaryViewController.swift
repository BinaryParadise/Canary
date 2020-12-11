//
//  MockGroupViewController.swift
//  Pods
//
//  Created by Rake Yang on 2020/12/10.
//

import Foundation
import SnapKit

class CanaryViewController: UIViewController {
    var tableView = UITableView(frame: .zero, style: .plain)
    let datas = ["环境配置", "Mock数据"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "金丝雀"
        view.backgroundColor = UIColor(hex: 0xF4F5F6)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(onBackButton))
        tableView.backgroundColor = view.backgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        if #available(iOS 13.0, *) {
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tableView.register(cellWithClass: UITableViewCell.self)
    }
    
    @objc func onBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension CanaryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        cell.textLabel?.text = datas[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.accessoryType = .disclosureIndicator
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else if indexPath.row == 1 {
            
        }
    }
}
