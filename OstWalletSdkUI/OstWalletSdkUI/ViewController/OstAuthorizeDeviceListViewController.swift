//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstAuthorizeDeviceListViewController: OstBaseViewController, UITableViewDelegate, UITableViewDataSource, OstJsonApiDelegate {
    
    public class func newInstance(userId: String,
                                  callBack: @escaping (([String: Any]?) -> Void)) -> OstAuthorizeDeviceListViewController {
        let instance = OstAuthorizeDeviceListViewController()
        setEssentials(instance: instance,
                      userId: userId,
                      callBack: callBack)
        return instance;
    }
    
    class func setEssentials(instance: OstAuthorizeDeviceListViewController,
                             userId: String,
                             callBack: @escaping (([String: Any]?) -> Void)) {
        instance.onCellSelected = callBack
        instance.userId = userId
    }
    
    var onCellSelected: (([String: Any]?) ->Void)? = nil

    enum DeviceStatus: String {
        case authorized
    }

    //MAKR: - Components
    var deviceTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = .red
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        //        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Users...")
        refreshControl.tintColor = UIColor.color(22, 141, 193)

        return refreshControl
    }()
    
    let titleLabel: OstH1Label = {
       return OstH1Label(text: "Device Recovery")
    }()

    let leadLabel: OstH3Label = {
       return OstH3Label(text: "This is an authorized device, recovery applies only to cases where a user has no authorized device")
    }()

    var progressIndicator: OstProgressIndicator? = nil

    //MARK: - Variables
    var isNewDataAvailable: Bool = false
    var isViewUpdateInProgress: Bool = false
    var shouldReloadData: Bool = false
    var shouldLoadNextPage: Bool = true
    var isApiCallInProgress: Bool = false

    var paginationTriggerPageNumber = 1
    var paginatingViewCount = 1

    var consumedDevices: [String: Any] = [String: Any]()

    var tableDataArray: [[String: Any]] = [[String: Any]]()

    var updatedTableArray: [[String: Any]] = [[String: Any]]()
    var meta: [String: Any]? = nil

    //MARK: - View LC
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getDeviceList(hardRefresh: true)
    }

    override func configure() {
        super.configure();
        self.shouldFireIsMovingFromParent = true;
    }

    //MARK: - Add Subview
    override func addSubviews() {
        super.addSubviews()

        setupTableView()
        self.addSubview(titleLabel)
        self.addSubview(leadLabel)
        self.addSubview(deviceTableView)
    }

    func setupTableView() {
        deviceTableView.delegate = self
        deviceTableView.dataSource = self

        registerCells()
    }

    func registerCells() {
        self.deviceTableView.register(OstDeviceTableViewCell.self, forCellReuseIdentifier: OstDeviceTableViewCell.deviceCellIdentifier)
    }

    //MARK: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addTitleLabelLayoutConstraints()
        addLeadLabelLayoutConstraints()
        addDeviceTableConstraitns()
    }
    
    func addTitleLabelLayoutConstraints() {
        titleLabel.topAlignWithParent(multiplier: 1, constant: 20)
        titleLabel.applyBlockElementConstraints()
    }

    func addLeadLabelLayoutConstraints() {
        leadLabel.placeBelow(toItem: titleLabel)
        leadLabel.applyBlockElementConstraints()
    }

    func addDeviceTableConstraitns() {
        deviceTableView.placeBelow(toItem: leadLabel)
        deviceTableView.applyBlockElementConstraints(horizontalMargin: 0)
        deviceTableView.bottomAlignWithParent()
    }

    //MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OstDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: OstDeviceTableViewCell.deviceCellIdentifier,
                                                                         for: indexPath) as! OstDeviceTableViewCell

        if tableDataArray.count > indexPath.row {
            let deviceDetails = tableDataArray[indexPath.row]
            
            cell.setDeviceDetails(deviceDetails, forIndex: indexPath.row)
            cell.onActionPressed = {[weak self] (deviceDetails) in
                self?.onCellSelected?(deviceDetails)
            }
        }else {
            cell.setDeviceDetails(nil, forIndex: indexPath.row)
            cell.onActionPressed = nil
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: - Scroll View Delegate

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.reloadDataIfNeeded()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.reloadDataIfNeeded()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if tableDataArray.count > 55 {
            return
        }
        if !self.isNewDataAvailable
            && self.shouldLoadNextPage
            && scrollView.panGestureRecognizer.translation(in: scrollView.superview!).y < 0 {

            if (shouldRequestPaginationData(isUpDirection: false,
                                            andTargetPoint: targetContentOffset.pointee.y)) {

                self.shouldLoadNextPage = false
                self.getDeviceList()
            }
        }
    }

    func shouldRequestPaginationData(isUpDirection: Bool = false,
                                     andTargetPoint targetPoint: CGFloat) -> Bool {

        let triggerPoint: CGFloat = CGFloat(self.paginationTriggerPageNumber) * self.deviceTableView.frame.size.height
        if (isUpDirection) {
            return targetPoint <= triggerPoint
        }else {
            return targetPoint >= (self.deviceTableView.contentSize.height - triggerPoint)
        }
    }


    //MARK: - Pull to Refresh
    @objc func pullToRefresh(_ sender: Any? = nil) {
        self.getDeviceList(hardRefresh: true)
    }

    func reloadDataIfNeeded() {

        let isScrolling: Bool = (self.deviceTableView.isDragging) || (self.deviceTableView.isDecelerating)

        if !isScrolling && self.isNewDataAvailable {
            tableDataArray = updatedTableArray
            self.deviceTableView.reloadData()
            self.isNewDataAvailable = false
            self.shouldLoadNextPage = true
        }

        if !isApiCallInProgress {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }


    //MARK: - Get Device

    func getDeviceList(hardRefresh: Bool = false) {
        if isApiCallInProgress {
            reloadDataIfNeeded()
            return
        }
        if hardRefresh {
            meta = nil
            updatedTableArray = []
        }else if nil != meta && meta!.isEmpty {
            reloadDataIfNeeded()
            return
        }
        isApiCallInProgress = true
        
        OstJsonApi.getDeviceList(forUserId: self.userId!,
                                 params: meta,
                                 delegate: self)
    }

    func onFetchDeviceSuccess(_ apiResponse: [String: Any]?) {
        isApiCallInProgress = false

        meta = apiResponse!["meta"] as? [String: Any]
        guard let resultType = apiResponse!["result_type"] as? String else {return}
        guard let devices = apiResponse![resultType] as? [[String: Any]] else {return}

        var newDevices: [[String: Any]] = [[String: Any]]()
        for device in devices {
            if (device["status"] as? String ?? "").caseInsensitiveCompare("AUTHORIZED") == .orderedSame {
                if let deviceAddress = device["address"] as? String,
                    consumedDevices[deviceAddress] == nil {

                    newDevices.append(device)
                    consumedDevices[deviceAddress] = device
                }
            }
        }

        updatedTableArray.append(contentsOf: newDevices)
        self.isNewDataAvailable = true

        reloadDataIfNeeded()
    }

    //MAKR: - Action
    func actionButtonTapped(_ entity: [String: Any]) {
       self.onCellSelected?(entity)
    }
    
    //MARK: - OstJsonApiDelegate
    
    func onOstJsonApiSuccess(data: [String : Any]?) {
        onFetchDeviceSuccess(data)
    }
    
    func onOstJsonApiError(error: OstError?, errorData: [String : Any]?) {
        onFetchDeviceSuccess(nil)
    }
}
