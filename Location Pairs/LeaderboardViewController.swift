//
//  LeaderboardViewController.swift
//  Location Pairs
//
//  Created by Joshua Areogun on 25/03/2017.
//  Copyright © 2017 Joshua Areogun. All rights reserved.
//

import UIKit

var localScoreboard:[[String:Any]] = []

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var leaderboardTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        let defaults = UserDefaults.standard
        localScoreboard = defaults.array(forKey: "scoreboardKey") as! [[String : Any]]

        print(localScoreboard)
        leaderboardTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func setupTableView(){
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self

        leaderboardTableView.estimatedRowHeight = 55
        leaderboardTableView.rowHeight = UITableViewAutomaticDimension
        leaderboardTableView.register(UINib(nibName:"LeaderboardCell", bundle:nil), forCellReuseIdentifier: "leaderCell")
    }

    // tableView delegates.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(localScoreboard.isEmpty == false) {
            return localScoreboard.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: "leaderCell") as! LeaderboardCellView
        if(localScoreboard.isEmpty == false) {
            let item = localScoreboard[indexPath.row]
            cell.playerNameLabel.text = item["name"] as? String
            cell.scoreLabel.text = String(item["score"] as! Int)
        } else
        {
            cell.playerNameLabel.text = " "
            cell.scoreLabel.text = " "
        }

        return cell
    }

}
