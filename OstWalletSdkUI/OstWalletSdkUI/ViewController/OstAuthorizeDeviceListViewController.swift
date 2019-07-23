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

class OstAuthorizeDeviceListViewController: OstBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    public class func newInstance(callBack: @escaping (([String: Any]) -> Void)) -> OstAuthorizeDeviceListViewController {
        let instance = OstAuthorizeDeviceListViewController()
        setEssentials(instance: instance, callBack: callBack)
        return instance;
    }
    
    class func setEssentials(instance: OstAuthorizeDeviceListViewController, callBack: @escaping (([String: Any]) -> Void)) {
        instance.onCellSelected = callBack
    }
    
    var onCellSelected: (([String: Any]) ->Void)? = nil

    enum DeviceStatus: String {
        case authorized
    }

    override func getNavBarTitle() -> String {
        return "Manage Devices"
    }

    func getLeadLabelText() -> String {
        return "This is a list of all the devices that are authorized to access your wallet."
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

    let leadLabel: UILabel = {
        var label = OstUIKit.leadLabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onCellSelected?(["":""])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.onCellSelected = nil
    }

    override func configure() {
        super.configure();
        self.shouldFireIsMovingFromParent = true;
    }

    //MARK: - Add Subview
    override func addSubviews() {
        super.addSubviews()

        setupTableView()
        self.addSubview(leadLabel)
        self.addSubview(deviceTableView)
    }

    func setupTableView() {
        deviceTableView.delegate = self
        deviceTableView.dataSource = self

        registerCells()
    }

    func registerCells() {
        self.deviceTableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: DeviceTableViewCell.deviceCellIdentifier)
    }

    //MARK: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addLeadLabelLayoutConstraints()
        addDeviceTableConstraitns()
    }

    func addLeadLabelLayoutConstraints() {
        leadLabel.topAlignWithParent(multiplier: 1, constant: 20)
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
        let cell: DeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.deviceCellIdentifier,
                                                                      for: indexPath) as! DeviceTableViewCell

        if tableDataArray.count > indexPath.row {
            let deviceDetail = tableDataArray[indexPath.row]
            cell.sendButtonAction = {[weak self] (entity) in
                self?.actionButtonTapped(entity!)
            }
        }else {

        }
        return cell
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

    func showProgressIndicator(withCode textCode: OstProgressIndicatorTextCode) {
        progressIndicator = OstProgressIndicator(textCode: textCode)
        progressIndicator?.show()
    }
}
