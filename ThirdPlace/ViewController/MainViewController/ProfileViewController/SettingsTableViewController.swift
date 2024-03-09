//
//  SettingsTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/09.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    //MARK: - Setup
    private func setupTableView() {
        setupTableViewBackground()
        setupTableViewSectionFooter()
    }
    
    //MARK: - Helper
    private func setupTableViewBackground() {
        let image = UIImage(named: "登録画面背景_v2")
        let imageView = UIImageView(frame: CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height))
        imageView.image = image
        self.tableView.backgroundView = imageView
    }
    
    private func setupTableViewSectionFooter() {
        tableView.estimatedSectionFooterHeight = 0.0
        //tableView.sectionHeaderTopPadding = 0
    }
}
