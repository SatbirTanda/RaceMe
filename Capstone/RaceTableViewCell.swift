//
//  RaceTableViewCell.swift
//  Capstone
//
//  Created by Satbir Tanda on 7/30/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit
import MapKit

class RaceTableViewCell: UITableViewCell, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var challengerTextLabel: UILabel!
    
    @IBOutlet weak var challengerSpeedTextLabel: UILabel!
    @IBOutlet weak var challengerDurationTextLabel: UILabel!
    @IBOutlet weak var challengerStartTimeTextLabel: UILabel!
    @IBOutlet weak var challengerEndTimeTextLabel: UILabel!
    
    @IBOutlet weak var opponentTextLabel: UILabel!
    
    @IBOutlet weak var opponentSpeedTextLabel: UILabel!
    @IBOutlet weak var opponentDurationTextLabel: UILabel!
    @IBOutlet weak var opponentStartTimeTextLabel: UILabel!
    @IBOutlet weak var opponentEndTimeTextLabel: UILabel!
    
    @IBOutlet weak var statusTextLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapAPI = MapAPI(mapView: mapView, flag: true)
        }
    }
    
    var challengerRoutePoints = [CLLocationCoordinate2D]() {
        didSet {
            print("RoutePointsCount -> \(challengerRoutePoints.count)")
            if challengerRoutePoints.count == 4 {
                mapAPI?.routePoints = challengerRoutePoints
            }
        }
    }
    var opponentRoutePoints = [CLLocationCoordinate2D]()
    
    var mapAPI: MapAPI?
    var _id: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polyShow = MKPolylineRenderer(overlay: overlay)
        polyShow.strokeColor = UIColor.blueColor()
        polyShow.lineWidth = 2
        return polyShow
    }
    

}
