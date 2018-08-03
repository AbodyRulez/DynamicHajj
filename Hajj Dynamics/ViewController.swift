//
//  ViewController.swift
//  Hajj Dynamics
//
//  Created by Essa AlOwayyid on 02/08/2018.
//  Copyright © 2018 Essa AlOwayyid. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation
import ARCL
import MapKit
// Hello Hello Hello Hello
class ViewController: UIViewController, ARSessionDelegate, SceneLocationViewDelegate {
    
    var adjustNorthByTappingSidesOfScreen = false
        var centerMapOnUserLocation: Bool = true
        var locationEstimateAnnotation: MKPointAnnotation?
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
            print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
        print("working")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
                print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
    // user icon on map
     var userAnnotation: MKPointAnnotation?
    
    // timer for updating user location
    var updateInfoLabelTimer: Timer?
    
    ///The initial value is respected
    var displayDebugging = false
    
    ///The initial value is respected
    var showMapView: Bool = true
    
    // MARK: Outlets
    let sceneLocationView = SceneLocationView()
    @IBOutlet var sceneView: ARSCNView!
    // map that is shown on page below
    let mapView = MKMapView()
    @IBOutlet weak var blurView: UIVisualEffectView!
    // label that is shown above the map view
    var infoLabel = UILabel()
    
    var updateUserLocationTimer: Timer?
    
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()
    
    // MARK: Properties
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    var nodeForContentType = [VirtualContentType: VirtualFaceNode]()
    
    let contentUpdater = VirtualContentUpdater()
    
    var selectedVirtualContent: VirtualContentType = .overlayModel {
        didSet {
            // Set the selected content based on the content type.
            contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]
        }
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = contentUpdater
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        createFaceGeometry()
        
        // Set the initial face content, if any.
        contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        configureMapKit()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    var count = 0
    public func simulatedUsers(){
//        21.419611, 39.875421
//        21.419318, 39.875344
//        21.419218, 39.875395
//        21.419171, 39.875539
//        21.419373, 39.875346
        let latitude = [21.419611, 21.419318, 21.419298, 21.419171, 21.419373]
        let longitude = [39.875421, 39.875344, 39.875395, 39.875539, 39.875346]
//            let latitude = 21.419346
//            let longitude = 39.875291
        for i in 0..<latitude.count {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = Double(latitude[i])
            annotation.coordinate.longitude = Double(longitude[i])
            
            annotation.title = "Pilgrim"
            annotation.subtitle = "Hello, I'm a Pilgrim, I'm 25 Y/O I have no health issues"
            
            
//                annotation.coordinate.latitude = Double(annotation.coordinate.latitude + 0.00005)
//                annotation.coordinate.longitude = Double(annotation.coordinate.longitude + 0.00001)
            
            
            self.mapView.addAnnotation(annotation)
            
            var incrementLat = 0.000005
            var incrementLong = 0.000001
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
                annotation.coordinate.latitude = Double(latitude[i] + incrementLat)
                annotation.coordinate.longitude = Double(longitude[i] + incrementLong)
                incrementLat += 0.00005
                incrementLong -= 0.00001
            }

            
//            for i in 0..<mapView.annotations.count {
            
//                let newCoordinateLat = mapView.annotations[i].coordinate.latitude +  0.0005
//                let newCoordinateLong = mapView.annotations[i].coordinate.longitude + 0.0001
                
//                mapView.annotations[i].coordinate.latitude = newCoordinateLat
//                mapView.annotations[i].coordinate.longitude = newCoordinateLong
//            }
            print("DEBUG COORDINATES\(mapView.annotations.count)")
        }
        

            /*Annotation.coordinate.latitude = Double(lati)
             Annotation.coordinate.longitude = Double(longt) */
//        }
        
//        self.mapView.addAnnotation(annotation)
//        mapView.removeAnnotations(annoRem)
        let coordinates = CLLocationCoordinate2D(latitude: 21.419611 + 0.000200, longitude: 39.875421 - 0.000200)
        
        let region = CLCircularRegion(center: coordinates, radius: 20, identifier: "geofence")
        //        self.mapView.removeOverlays(mapView.overlays)
        //        locationManager.startMonitoring(for: region)
        let circle = MKCircle(center: coordinates, radius: region.radius)
        var points = [CLLocationCoordinate2DMake(21.419217, 39.875360),
                      CLLocationCoordinate2DMake(21.419402, 39.875542),
                      CLLocationCoordinate2DMake(21.419242, 39.876146),
                      CLLocationCoordinate2DMake(21.418870, 39.875797)]
        let square = MKPolygon(coordinates: points, count: 4)
//        self.mapView.add(circle)
        self.mapView.addOverlays([square,circle])
//        self.mapView.add(square)
        
//        Point 1: 21.419402, 39.875542
//        Point 2: 21.419217, 39.875360
//        Point 3: 21.419242, 39.876146
//        Point 4: 21.418870, 39.875797

    }
    
    public func simulatedBarriers(){
        //        21.419611, 39.875421
        //        21.419318, 39.875344
        //        21.419218, 39.875395
        //        21.419171, 39.875539
        //        21.419373, 39.875346
        let latitude = [21.419611, 21.419318, 21.419298, 21.419171, 21.419373]
        let longitude = [39.875421, 39.875344, 39.875395, 39.875539, 39.875346]
        //            let latitude = 21.419346
        //            let longitude = 39.875291
        for i in 0..<latitude.count {
            let annotation = MKPointAnnotation()
            
            annotation.coordinate.latitude = Double(latitude[i])
            annotation.coordinate.longitude = Double(longitude[i])
            
            annotation.title = "Pilgrim"
            annotation.subtitle = "Hello, I'm a Pilgrim, I'm 25 Y/O I have no health issues"
            
            
            annotation.coordinate.latitude = Double(annotation.coordinate.latitude + 0.00005)
            annotation.coordinate.longitude = Double(annotation.coordinate.longitude + 0.00001)
            
            
            self.mapView.addAnnotation(annotation)
            
            var incrementLat = 0.000005
            var incrementLong = 0.000001
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                annotation.coordinate.latitude = Double(latitude[i] + incrementLat)
                annotation.coordinate.longitude = Double(longitude[i] + incrementLong)
                incrementLat += 0.00005
                incrementLong -= 0.00001
            }
            
            
            //            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            //                print("count\(self.count)")
            //
            //                annotation.coordinate.latitude = Double(annotation.coordinate.latitude + 0.00005)
            //                annotation.coordinate.longitude = Double(annotation.coordinate.latitude + 0.00001)
            //
            //                self.count = self.count + 1
            //            }
            
            
            //            for i in 0..<mapView.annotations.count {
            
            //                let newCoordinateLat = mapView.annotations[i].coordinate.latitude +  0.0005
            //                let newCoordinateLong = mapView.annotations[i].coordinate.longitude + 0.0001
            
            //                mapView.annotations[i].coordinate.latitude = newCoordinateLat
            //                mapView.annotations[i].coordinate.longitude = newCoordinateLong
            //            }
            print("DEBUG COORDINATES\(mapView.annotations.count)")
        }
 
        
        /*Annotation.coordinate.latitude = Double(lati)
         Annotation.coordinate.longitude = Double(longt) */
        //        }
        
        //        self.mapView.addAnnotation(annotation)
        //        mapView.removeAnnotations(annoRem)
        
    }
    

    // acitvated once user hits the screen
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        // the view user tapped on
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn) // location of user tap
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        // hitTest determain if user tapped anything, location of the tap
        if hitTest.isEmpty {
            print("Didn't touch anything")
        } else {
            print("touched something")
            
        
        }
        print("tapped the sceneView")
    }
    
    public func configureMapKit(){
        infoLabel.font = UIFont.systemFont(ofSize: 10)
        infoLabel.textAlignment = .left
        infoLabel.textColor = UIColor.white
        infoLabel.numberOfLines = 0
        sceneLocationView.addSubview(infoLabel)
        
        updateInfoLabelTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(ViewController.updateInfoLabel),
            userInfo: nil,
            repeats: true)
        
        // Set to true to display an arrow which points north.

        //        sceneLocationView.orientToTrueNorth = false
        
//                sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        
        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
        }
        
        buildDemoData().forEach { sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0) }
        
        view.addSubview(sceneLocationView)
        
        if showMapView {
            
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.alpha = 0.8
            
            view.addSubview(mapView)
            
            updateUserLocationTimer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(ViewController.updateUserLocation),
                userInfo: nil,
                repeats: true)
            
            simulatedUsers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("run")
        sceneLocationView.run()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         AR experiences typically involve moving the device without
         touch input for some time, so prevent auto screen dimming.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetTracking()
    }
    
    @objc func updateUserLocation() {
        print("updateUserLocation() called")
        guard let currentLocation = sceneLocationView.currentLocation() else {
            return
        }
        print("updateUserLocation() calleded")
        DispatchQueue.main.async {
            print("updateUserLocation() DispatchQueue called")
            if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
                let position = self.sceneLocationView.currentScenePosition() {
                print("")
                print("Fetch current location")
                print("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
                print("current position: \(position)")
                
                let translation = bestEstimate.translatedLocation(to: position)
                
                print("translation: \(translation)")
                print("translated location: \(currentLocation)")
                print("")
            }
            print("location exist")
            if self.userAnnotation == nil {
                self.userAnnotation = MKPointAnnotation()
                print("user annotation exist")
                self.mapView.addAnnotation(self.userAnnotation!)
            }
            print("finished with annotation exist")
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                self.userAnnotation?.coordinate = currentLocation.coordinate
            }, completion: nil)
            
            if self.centerMapOnUserLocation {
                UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                }, completion: { _ in
                    self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                })
            }
            
            if self.displayDebugging {
                let bestLocationEstimate = self.sceneLocationView.bestLocationEstimate()
                
                if bestLocationEstimate != nil {
                    if self.locationEstimateAnnotation == nil {
                        self.locationEstimateAnnotation = MKPointAnnotation()
                        self.mapView.addAnnotation(self.locationEstimateAnnotation!)
                    }
                    
                    self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
                } else {
                    if self.locationEstimateAnnotation != nil {
                        self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
                        self.locationEstimateAnnotation = nil
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
        
        print("pause")
        // Pause the view's session
        sceneLocationView.pause()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
        
        infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
        
        if showMapView {
            infoLabel.frame.origin.y = (self.view.frame.size.height / 2) - infoLabel.frame.size.height
        } else {
            infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
        }
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
    // MARK: - Setup
    
    /// - Tag: CreateARSCNFaceGeometry
    func createFaceGeometry() {
        // This relies on the earlier check of `ARFaceTrackingConfiguration.isSupported`.
        let device = sceneView.device!
        let maskGeometry = ARSCNFaceGeometry(device: device)!
        let glassesGeometry = ARSCNFaceGeometry(device: device)!
        
        nodeForContentType = [
            .faceGeometry: Mask(geometry: maskGeometry),
            .overlayModel: GlassesOverlay(geometry: glassesGeometry),
            .blendShapeModel: RobotHead()
        ]
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        blurView.isHidden = false
        statusViewController.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        blurView.isHidden = true
        
        DispatchQueue.main.async {
            self.resetTracking()
        }
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        statusViewController.showMessage("STARTING A NEW SESSION")
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Interface Actions
    
    /// - Tag: restartExperience
    func restartExperience() {
        // Disable Restart button for a while in order to give the session enough time to restart.
        statusViewController.isRestartExperienceButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.statusViewController.isRestartExperienceButtonEnabled = true
        }
        
        resetTracking()
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition() {
            infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }
        
        if let eulerAngles = sceneLocationView.currentEulerAngles() {
            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }
        
        if let heading = sceneLocationView.locationManager.heading,
            let accuracy = sceneLocationView.locationManager.headingAccuracy {
            infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
        }
        
        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard
            let touch = touches.first,
            let touchView = touch.view
            else {
                return
        }
        
        if mapView == touchView || mapView.recursiveSubviews().contains(touchView) {
            centerMapOnUserLocation = false
        } else {
            let location = touch.location(in: self.view)
            
            if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
                print("left side of the screen")
                sceneLocationView.moveSceneHeadingAntiClockwise()
            } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
                print("right side of the screen")
                sceneLocationView.moveSceneHeadingClockwise()
            } else {
                let image = UIImage(named: "pin")!
                let annotationNode = LocationAnnotationNode(location: nil, image: image)
                annotationNode.scaleRelativeToDistance = true
                sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
            }
        }
    }
    
    
}

// used to specify if user enter specific reigon
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let title = "you entered Reigon"
        let subtitle = "Barrier adjusted"
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
            self.performSegue(withIdentifier: "moveToStatus", sender: nil)
        }
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
//        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
//        circleRenderer.strokeColor = .red
//        circleRenderer.fillColor = .red
//        circleRenderer.alpha = 0.5
//        return circleRenderer
        
        guard let squareOverlay = overlay as? MKPolygon else { return MKOverlayRenderer() }
        let squareRenderer = MKPolygonRenderer(polygon: squareOverlay)
        squareRenderer.strokeColor = .red
        squareRenderer.fillColor = .red
        squareRenderer.alpha = 0.5
        return squareRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let pointAnnotation = annotation as? MKPointAnnotation else {
            return nil
        }
        
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        marker.displayPriority = .required
        
        if pointAnnotation == self.userAnnotation {
            marker.glyphImage = UIImage(named: "user")
        } else {
            marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
//            marker.glyphImage = UIImage(named: "compass")
                        marker.glyphImage = UIImage(named: "user")
        }
        
        return marker
    }
    
    
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        /*
         Popover segues should not adapt to fullscreen on iPhone, so that
         the AR session's view controller stays visible and active.
         */
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
         All segues in this app are popovers even on iPhone. Configure their popover
         origin accordingly.
         */
        guard let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton else { return }
        popoverController.delegate = self
        popoverController.sourceRect = button.bounds
        
        // Set up the view controller embedded in the popover.
        let contentSelectionController = popoverController.presentedViewController as! ContentSelectionController
        
        // Set the initially selected virtual content.
        contentSelectionController.selectedVirtualContent = selectedVirtualContent
        
        // Update our view controller's selected virtual content when the selection changes.
        contentSelectionController.selectionHandler = { [unowned self] newSelectedVirtualContent in
            self.selectedVirtualContent = newSelectedVirtualContent
        }
    }
}


@available(iOS 11.0, *)
private extension ViewController {
    func buildDemoData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []
        
        // TODO: add a few more demo points of interest.
        // TODO: use more varied imagery.
        
        let spaceNeedle = buildNode(latitude: 47.6205, longitude: -122.3493, altitude: 225, imageName: "pin")
        nodes.append(spaceNeedle)
        
        let empireStateBuilding = buildNode(latitude: 40.7484, longitude: -73.9857, altitude: 14.3, imageName: "pin")
        nodes.append(empireStateBuilding)
        
        let canaryWharf = buildNode(latitude: 51.504607, longitude: -0.019592, altitude: 236, imageName: "pin")
        nodes.append(canaryWharf)
        
        return nodes
    }
    
    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance, imageName: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let image = UIImage(named: imageName)!
        return LocationAnnotationNode(location: location, image: image)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}


