/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk
import OstWalletSdkUI

class CurrentUserModel: OstBaseModel, OWFlowInterruptedDelegate, OWFlowCompleteDelegate, OWPassphrasePrefixDelegate, OstJsonApiDelegate, OstPassphrasePrefixDelegate, OstWorkflowUIDelegate {
    
    //MARK: - OstPassphrasePrefixDelegate
    func getPassphrase(ostUserId: String,
                       workflowContext: OstWorkflowContext,
                       delegate: OstPassphrasePrefixAcceptDelegate) {
        
        if ( nil == self.ostUserId || self.ostUserId!.compare(ostUserId) != .orderedSame ) {
            var error:[String:Any] = [:];
            error["display_message"] = "Something went wrong. Please re-launch the application and try again.";
            error["extra_info"] = "Sdk requested for passphrase of user-id which is not logged-in.";
            delegate.cancelFlow();
            return;
        }
        
        UserAPI.getCurrentUserSalt(meta: nil, onSuccess: {[weak self, delegate] (userPinSalt, data) in
            delegate.setPassphrase(ostUserId: self!.ostUserId!, passphrase: userPinSalt);
            }, onFailure: {[weak self, delegate] (error) in
                delegate.cancelFlow();
        });
    }
  
    static let getInstance = CurrentUserModel()
    
    static var shouldPerfromActivateUserAfterDelay: Bool = false
    static var artificalDelayForActivateUser: Double = 24
    
    override init() {
        super.init()
    }
    //MARK: - Variables
    private var userDetails: [String: Any]? {
        didSet {
            userBalanceDetails = nil
            if nil == userDetails {
                isUserLoggedIn = false
            }else {
                isUserLoggedIn = true
            }
        }
    }
    var userBalanceDetails: [String: Any]? = nil
    var pricePoint: [String: Any]? = nil
    var isUserLoggedIn: Bool = false
    
    var setupDeviceOnSuccess: ((OstUser, OstDevice) -> Void)?
    var setupDeviceOnFailure: (([String: Any]?)->Void)?
    
    func logoutUser() {
        self.userDetails = nil
        pricePoint = nil
        userBalanceDetails = nil
        UserCrashlyticsSetting.shared.isUserOptInForFabric = nil
        UserCrashlyticsSetting.shared.isRequestInProgress = false
    }
    
    func logout() {
        UserAPI.logoutUser()
        logoutUser() 
    }
    
    //MARK: - API
    func setupDevice(onSuccess: @escaping ((OstUser, OstDevice) -> Void), onFailure:@escaping (([String: Any]?)->Void)) {
        
        setupDeviceOnSuccess = onSuccess
        setupDeviceOnFailure = onFailure
        
        let workflowCallback = OstSdkInteract.getInstance.getWorkflowCallback(forUserId: CurrentUserModel.getInstance.ostUserId!)
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallback.workflowId, listner: self)
        
        OstWalletSdk.setupDevice(userId: self.ostUserId!,
                                 tokenId: self.tokenId!,
                                 forceSync:true,
                                 delegate: workflowCallback);
    }
    
    func login(username:String,
               phonenumber:String,
               onSuccess: @escaping ((OstUser, OstDevice) -> Void),
               onFailure:@escaping (([String: Any]?)->Void) ) {
        
        var params: [String: Any] = [:]
        params["username"] = username;
        params["password"] = phonenumber;
        
        UserAPI.loginUser(params: params,
                          onSuccess: { (apiResponse) in
                            CurrentUserModel.getInstance.userDetails = apiResponse
                            
                            self.setupDevice(onSuccess: onSuccess, onFailure: onFailure);
        }) { (apiError) in
            let msg = (apiError?["msg"] as? String) ?? "Login failed due to unknown reason"
            OstErroNotification.showNotification(withMessage: msg)
            onFailure(apiError)
        }
    }
    
    func signUp(username:String ,
                phonenumber:String,
                onSuccess: @escaping ((OstUser, OstDevice) -> Void),
                onFailure:@escaping (([String: Any]?)->Void) ) {
        
        var params: [String: Any] = [:];
        params["username"] = username;
        params["password"] = phonenumber;
        
        UserAPI.signupUser(params: params,
                           onSuccess: { (apiResponse) in
                            CurrentUserModel.getInstance.userDetails = apiResponse
                            self.setupDevice(onSuccess: onSuccess, onFailure: onFailure);
        }) { (apiError) in
            
            let msg = (apiError?["msg"] as? String) ?? "Signup failed due to unknown reason"
            OstErroNotification.showNotification(withMessage: msg)
            onFailure(apiError)
        }
    }
    
    func getCurrentUser(onSuccess: @escaping ((OstUser, OstDevice) -> Void),
                        onFailure:@escaping (([String: Any]?)->Void)) {
        
        UserAPI.getCurrentUser(onSuccess: {[weak self] (apiResponse) in
            
            CurrentUserModel.getInstance.userDetails = apiResponse
            self?.setupDevice(onSuccess: onSuccess, onFailure: onFailure);
        }) {(apiResponse) in
            onFailure(apiResponse)
        }
    }
    
   
    
    
    //MARK: - OstWorkflow Delegate
    @objc func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
    
    }
    
    @objc func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        setupDeviceOnFailure?(error.errorInfo);
        if workflowContext.workflowType == OstWorkflowType.activateUser {
            CurrentUserModel.shouldPerfromActivateUserAfterDelay = false
        }
    }
    
    @objc func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
        if ( workflowContext.workflowType == OstWorkflowType.setupDevice ) {
            print("onSuccess triggered for ", workflowContext.workflowType);
           
                setupDeviceOnSuccess?(self.ostUser!, self.currentDevice!)
           
        }else if workflowContext.workflowType == OstWorkflowType.activateUser {
            
            let user: OstUser = contextEntity.entity as! OstUser
            if user.isStatusActivated {
                UserAPI.notifyUserActivated()
            }
            
            if  CurrentUserModel.shouldPerfromActivateUserAfterDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + CurrentUserModel.artificalDelayForActivateUser) {[weak self] in
                    self?.performFlowComplete(workflowContext: workflowContext, contextEntity: contextEntity)
                }
            }
        }else {
             setupDeviceOnFailure?(nil);
        }
    }
    
    func performFlowComplete(workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        OstNotificationManager.getInstance.show(withWorkflowContext: workflowContext,
                                                contextEntity: contextEntity,
                                                error: nil)
        CurrentUserModel.shouldPerfromActivateUserAfterDelay = false
        NotificationCenter.default.post(name: NSNotification.Name("userActivated"), object: nil)
    }
    
    func getPassphrase(ostUserId: String, ostPassphrasePrefixAcceptDelegate: OWPassphrasePrefixAcceptDelegate) {
        if ( nil == self.ostUserId || self.ostUserId!.compare(ostUserId) != .orderedSame ) {
            var error:[String:Any] = [:];
            error["display_message"] = "Something went wrong. Please re-launch the application and try again.";
            error["extra_info"] = "Sdk requested for passphrase of user-id which is not logged-in.";
            ostPassphrasePrefixAcceptDelegate.cancelFlow(error: error);
            return;
        }
        
        UserAPI.getCurrentUserSalt(meta: nil, onSuccess: {[weak self,ostPassphrasePrefixAcceptDelegate] (userPinSalt, data) in
            ostPassphrasePrefixAcceptDelegate.setPassphrase(ostUserId: self!.ostUserId!, passphrase: userPinSalt);
        }, onFailure: {[ostPassphrasePrefixAcceptDelegate] (error) in
            ostPassphrasePrefixAcceptDelegate.cancelFlow(error: error);
        });
    }

    var fetchUserBalanceCompletion: ((Bool, [String : Any]?, [String : Any]?) -> Void)? = nil
    func fetchUserBalance(onCompletion: ((Bool, [String : Any]?, [String : Any]?) -> Void)? = nil) {
        fetchUserBalanceCompletion = onCompletion
        OstJsonApi.getBalanceWithPricePoint(forUserId: ostUserId!, delegate: self)
    }
    
    //MAKR: Ost Json api Delegate
    func onOstJsonApiSuccess(data: [String : Any]?) {
        guard let apiData = data,
            let resutType = OstJsonApi.getResultType(apiData: data),
            let balance = OstJsonApi.getResultAsDictionary(apiData: apiData) else {
            
            fetchUserBalanceCompletion?(false, data, nil)
            return
        }
        if "balance".caseInsensitiveCompare(resutType) == .orderedSame {
            CurrentUserModel.getInstance.pricePoint = apiData["price_point"] as! [String: Any]
            CurrentUserModel.getInstance.updateBalance(balance: balance)
        }
        
        fetchUserBalanceCompletion?(true, data, nil)
        fetchUserBalanceCompletion = nil
    }
    
    func onOstJsonApiError(error: OstError?, errorData: [String : Any]?) {
        if nil != error {
            OstErroNotification.showNotification(withMessage: error!.errorMessage)
        }
        fetchUserBalanceCompletion?(false, nil, errorData)
        fetchUserBalanceCompletion = nil
    }
    
    func updateBalance(balance: [String: Any]) {
        if ( nil == self.userBalanceDetails ) {
            self.userBalanceDetails = [:];
        }
        
        self.userBalanceDetails?.merge(dict: balance);
    }
}

extension CurrentUserModel {
    var ostUserId: String? {
        let userId = userDetails?["user_id"]
        return ConversionHelper.toString(userId)
    }
    
    var userName: String? {
        return (userDetails?["username"] as? String) ?? nil
    }
    
    var tokenId: String? {
        let tokenId = userDetails?["token_id"]
        return ConversionHelper.toString(tokenId)
    }
    
    var appUserId: String? {
        let appUserId = userDetails?["app_user_id"]
        return ConversionHelper.toString(appUserId)
    }
    
    var tokenHolderAddress: String? {
        if let userId = ostUserId {
            let ostUser = OstWalletSdk.getUser(userId)
            return ostUser?.tokenHolderAddress
        }
        return nil
    }
    
    var deviceManagerAddress: String? {
        if let userId = ostUserId {
            let ostUser = OstWalletSdk.getUser(userId)
            return ostUser?.deviceManagerAddress
        }
        return nil
    }
    
    var userPinSalt: String? {
        return userDetails?["user_pin_salt"] as? String ?? nil
    }
    
    var ostUser: OstUser? {
        if let userId = ostUserId {
            return OstWalletSdk.getUser(userId)
        }
        return nil
    }
    
    var currentDevice: OstDevice? {
        if let userId = ostUserId {
            let ostUser = OstWalletSdk.getUser(userId)
            return ostUser?.getCurrentDevice()
        }
        return nil
    }
    
    var status: String? {
        return userDetails?["status"] as? String ?? nil
    }
    
    var ostUserStatus: String? {
        if let user = ostUser {
            return user.status
        }
        return nil
    }
    
    var currentDeviceStatus: String {
        var deviceStatus = currentDevice?.status?.uppercased() ?? ""
        if CurrentUserModel.shouldPerfromActivateUserAfterDelay {
            deviceStatus =  "ACTIVATING"
        }
        
        return deviceStatus
    }
    
    var balance: String {
        if let availabelBalance = userBalanceDetails?["available_balance"] {
            let amountVal = ConversionHelper.toString(availabelBalance)!.toRedableFormat()
            return amountVal.toDisplayTxValue()
        }
        return ""
    }
    
    func showTokenHolderInView() {
        
        let webView = WKWebViewController()
        let currentEconomy = CurrentEconomy.getInstance
        
        let tokenHoderURL: String = "\(currentEconomy.viewEndPoint!)token/th-\(currentEconomy.auxiliaryChainId!)-\(currentEconomy.utilityBrandedToken!)-\(tokenHolderAddress!)"
        webView.title = "OST View"
        webView.urlString = tokenHoderURL
        
        webView.showVC()
    }
}

//MARK: - Status
extension CurrentUserModel {
    
    //MARK: - User
    var isCurrentUserStatusActivating: Bool? {
        if CurrentUserModel.shouldPerfromActivateUserAfterDelay {
            return true
        }
        return ostUser?.isStatusActivating
    }
    
    var isCurrentUserStatusActivated: Bool? {
        if CurrentUserModel.shouldPerfromActivateUserAfterDelay {
            return false
        }
        return ostUser?.isStatusActivated
    }
    
    
    //MARK: - Device
    var isCurrentDeviceStatusAuthorizing: Bool {
        if let currentDevice = self.currentDevice,
            let status = currentDevice.status {
            
            if status.caseInsensitiveCompare(ManageDeviceViewController.DeviceStatus.authorizing.rawValue) == .orderedSame{
                return true
            }
        }
        return false
    }
    
    var isCurrentDeviceStatusAuthrozied: Bool {
        if CurrentUserModel.shouldPerfromActivateUserAfterDelay {
            return false
        }
        
        if let currentDevice = self.currentDevice,
            let status = currentDevice.status {
            
            if status.caseInsensitiveCompare(ManageDeviceViewController.DeviceStatus.authorized.rawValue) == .orderedSame{
                return true
            }
        }
        return false
    }
    
    var isCurrentDeviceStatusRegistered: Bool {
        if let currentDevice = self.currentDevice,
            let status = currentDevice.status {
            
            if status.caseInsensitiveCompare(ManageDeviceViewController.DeviceStatus.registered.rawValue) == .orderedSame{
                return true
            }
        }
        return false
    }
}


//MARK: - Price Point
extension CurrentUserModel {
    var getUSDValue: Double? {
        guard let pricePoint = self.pricePoint else {
            return nil
        }
       
        if let tokenId = self.tokenId,
            let ostToken: OstToken = OstWalletSdk.getToken(tokenId) {
            
            let baseCurrency = ostToken.baseToken
            if let currencyPricePoint = pricePoint[baseCurrency] as? [String: Any],
                let strValue = ConversionHelper.toString(currencyPricePoint["USD"]) {
                return Double(strValue)
            }
        }
        return nil
    }
    
    func toUSD(value: String) -> String? {
        guard let usdValue = getUSDValue,
            let doubleValue = Double(value) else {
                return nil
        }
        
        guard let token = OstWalletSdk.getToken(CurrentEconomy.getInstance.tokenId!),
            let conversionFactor = token.conversionFactor,
            let doubleConversionFactor = Double(conversionFactor) else {
                
                return nil
        }
        
        let btToOstVal = (doubleValue/doubleConversionFactor)
        let usdVal = (usdValue * btToOstVal).avoidNotation
        return usdVal.replacingOccurrences(of: ",", with: ".")
    }
    
    func toBt(value: String) -> String? {
        
        guard let token = OstWalletSdk.getToken(CurrentEconomy.getInstance.tokenId!) else {
            return nil
        }
        let baseToken = token.baseToken
        
        guard let btDecimal = token.decimals,
            let conversionFactor = token.conversionFactor,
            let fiatPricePoint = self.pricePoint?[baseToken] as? [String: Any],
            let fiatDecimal = ConversionHelper.toInt(fiatPricePoint["decimals"]) else {
                
                return nil
        }
        
        let pricePoint = String(format: "%@", fiatPricePoint["USD"] as! CVarArg)
        
        let btValue = try? OstConversion.fiatToBt(ostToBtConversionFactor: conversionFactor,
                                    btDecimal: btDecimal,
                                    fiatDecimal: fiatDecimal,
                                    fiatAmount: BigInt(value)!,
                                    pricePoint: pricePoint)
        
        return btValue?.description
    }
}
