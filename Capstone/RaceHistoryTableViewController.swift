//
//  RaceHistoryTableViewController.swift
//  Capstone
//
//  Created by Satbir Tanda on 7/27/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit
import CoreLocation

class RaceHistoryTableViewController: UITableViewController {
    
    
    private let serverAPI = ServerAPI(url: Routes.baseURL)
    private let storageAPI = StorageAPI()
    private var races = [Race]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl?.beginRefreshing()
        pullToRefresh(refreshControl)
    }
    
    private struct CellIdentifiers {
        static let RaceItem = "RaceItem"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return races.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.RaceItem, forIndexPath: indexPath) as! RaceTableViewCell

        // Configure the cell...
        
        let race = races[indexPath.row]
        
        cell.challengerTextLabel?.text = "Challenger: \(race.challenger)"
        cell.challengerStartTimeTextLabel?.text = "Start Time: \(race.challengerStartTime)"
        cell.challengerEndTimeTextLabel?.text = "Start Time: \(race.challengerEndTime)"

        cell.challengerSpeedTextLabel?.text = "Speed: \(race.challengerSpeed)"
        cell.challengerDurationTextLabel?.text = "Duration: \(race.challengerDuration)"

        
        cell.opponentTextLabel?.text = "Opponent: \(race.opponent)"
        cell.opponentStartTimeTextLabel?.text = "Start Time: \(race.opponentStartTime)"
        cell.opponentEndTimeTextLabel?.text = "Start Time: \(race.opponentEndTime)"
        
        cell.opponentSpeedTextLabel?.text = "Speed: \(race.opponentSpeed)"
        cell.opponentDurationTextLabel?.text = "Duration: \(race.opponentDuration)"
        
        cell.statusTextLabel?.text = "Status: \(race.status)"
        
        cell.challengerRoutePoints = race.challengerRoutePoints
        cell.opponentRoutePoints = race.opponentRoutePoints
        
        cell._id = race.id
        
        if let username = storageAPI.getUsername() {
            if username == race.opponent {
                cell.contentView.backgroundColor = UIColor.flatLimeColor()
            } else {
                cell.contentView.backgroundColor = UIColor.lightGrayColor()
            }
        }
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let race = races[indexPath.row]
        
        if let username = storageAPI.getUsername() {
            if race.status == "In progress" && race.challenger != username {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RaceTableViewCell {
                    performSegueWithIdentifier("ShowChallengeVC", sender: cell)
                }
            }

        }
    }


    @IBAction func pullToRefresh(sender: UIRefreshControl?) {
        refresh(sender)
    }
    
    private func refresh(sender: UIRefreshControl?) {
        serverAPI.getRequestTo(Routes.mailboxPath) { (success, response, error) in
            if success {
                if response != nil {
                    self.races.removeAll()
                    if let arrayOfRaces = response!["response"] as? [[String: AnyObject]] {
                        for race in arrayOfRaces.reverse() {
                            self.appendNewRace(race)
                        }
                    }
                }
            } else {
                print("Error -> \(error)")
            }
            self.tableView.reloadData()
            sender?.endRefreshing()
        }

    }
    
    private func setupUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.flatWhiteColor()]   
    }
    
    private func appendNewRace(race: [String: AnyObject]) {
        if let challenger = race["challenger"]!["username"] as? String {
            if let opponent = race["opponent"]!["username"] as? String {
                // print("challenger -> \(challenger), opponent -> \(opponent)")
                var newRace = Race(challenger: challenger, opponent: opponent)

                if let challengerStartTime = race["challenger"]!["start"] as? Double {
                    let dateString = NSDate().dateFromUnixTime(challengerStartTime)
                    newRace.challengerStartTime = dateString
                }
                
                if let challengerEndTime = race["challenger"]!["end"] as? Double {
                    let dateString = NSDate().dateFromUnixTime(challengerEndTime)
                    newRace.challengerEndTime = dateString
                }
                
                if let challengerSpeed = race["challenger"]!["speed"] as? Double {
                    newRace.challengerSpeed = "\(challengerSpeed)"
                }
                
                if let challengerDuration = race["challenger"]!["duration"] as? Double {
                    newRace.challengerDuration = "\(challengerDuration)"
                }
                
                if let opponentStartTime = race["opponent"]!["start"] as? Double {
                    let dateString = NSDate().dateFromUnixTime(opponentStartTime)
                    newRace.opponentStartTime = dateString
                }
                
                if let opponentEndTime = race["opponent"]!["end"] as? Double {
                    let dateString = NSDate().dateFromUnixTime(opponentEndTime)
                    newRace.opponentEndTime = dateString
                }
                
                if let opponentSpeed = race["opponent"]!["speed"] as? Double {
                    newRace.opponentSpeed = "\(opponentSpeed)"
                }
                
                if let opponentDuration = race["opponent"]!["duration"] as? Double {
                    newRace.opponentDuration = "\(opponentDuration)"
                }

                
                if let route = race["challenger"]!["route"] as? [String: AnyObject] {
                    if let origin = route["origin"] {
                        if let latitude = origin["lat"] as? Double {
                            if let longtitude = origin["lng"] as? Double {
                                newRace.challengerRoutePoints.append(CLLocationCoordinate2DMake(latitude, longtitude))
                            }
                        }
                    }
                }
                
                if let route = race["challenger"]!["route"] as? [String: AnyObject] {
                    if let points = route["wayPoints"] as? [[String: AnyObject]] {
                        for i in 0 ..< points.count {
                            if let lat = points[i]["lat"] as? Double {
                                if let lng = points[i]["lng"] as? Double {
                                    // print("latitude: \(lat)")
                                    // print("longitude: \(lng)")
                                    newRace.challengerRoutePoints.append(CLLocationCoordinate2DMake(lat, lng))
                                }
                            }
                        }
                    }
                }
                
                if let route = race["opponent"]!["route"] as? [String: AnyObject] {
                    if let origin = route["origin"] {
                        if let latitude = origin["lat"] as? Double {
                            if let longtitude = origin["lng"] as? Double {
                                newRace.opponentRoutePoints.append(CLLocationCoordinate2DMake(latitude, longtitude))
                            }
                        }
                    }
                }
                
                if let route = race["opponent"]!["route"] as? [String: AnyObject] {
                    if let points = route["wayPoints"] as? [[String: AnyObject]] {
                        for i in 0 ..< points.count {
                            if let lat = points[i]["lat"] as? Double {
                                if let lng = points[i]["lng"] as? Double {
                                    // print("latitude: \(lat)")
                                    // print("longitude: \(lng)")
                                    newRace.opponentRoutePoints.append(CLLocationCoordinate2DMake(lat, lng))
                                }
                            }
                        }
                    }
                }
                
                if let status = race["status"] as? String {
                    newRace.status = status
                }
                
                if let id = race["_id"] as? String {
                    newRace.id = id
                }
                
                
                self.races.append(newRace)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "ShowChallengeVC" {
                if let cvc = segue.destinationViewController as? ChallengeViewController {
                    if let cell = sender as? RaceTableViewCell {
                        if let row = tableView.indexPathForCell(cell)?.row {
                            let opponent = races[row].challenger
                            cvc.currentOpponent = opponent
                            cvc._id = cell._id
                            cvc.flag = true
                        }
                    }
                }
            }
        }
    }

}

extension NSDate {
    func dateFromUnixTime(unixTime: Double) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        
        let startTime = NSDate(timeIntervalSinceReferenceDate: unixTime)
        let dateString = formatter.stringFromDate(startTime)
        
        return dateString
    }
}

struct Race {
    var challenger = ""
    var challengerStartTime = ""
    var challengerEndTime = ""
    var challengerSpeed = ""
    var challengerDuration = ""
    
    var opponent = ""
    var opponentStartTime = ""
    var opponentEndTime = ""
    var opponentSpeed = ""
    var opponentDuration = ""
    var status = ""
    
    var id = ""
    
    var challengerRoutePoints = [CLLocationCoordinate2D]()
    var opponentRoutePoints = [CLLocationCoordinate2D]()

    
    init(challenger: String, opponent: String) {
        self.challenger = challenger
        self.opponent = opponent
    }
}
