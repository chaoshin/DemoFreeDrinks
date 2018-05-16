//
//  MainViewController.swift
//  DemoFreeDrinks
//
//  Created by Chao Shin on 2018/5/7.
//  Copyright © 2018 Chao Shin. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {
    @IBOutlet var waitOrderView: UIView!
    
    var orderArray = [OrderInformation]()
    
    
    @IBAction func editButtonPress(_ sender: Any) {
        checkPasswordAlertMessage()
    }
    
    @objc func updateWaitUI(noti: Notification) {
        if let info = noti.userInfo, let  message = info["message"] as? Bool{
            DispatchQueue.main.async {  // UI的更新必須在Main thread
                self.waitOrderView.isHidden = message   //顯示或是隱藏訂購中                
                if message == true{
                    self.navigationController?.isNavigationBarHidden = false // 顯示NavigationBar
                    self.showAlertMessage(title: "訂購完成", message: "謝謝") //訂購完成顯示確認視窗
                }
            }
        }
    }
    
    func checkPasswordAlertMessage() {
        let checkAlert = UIAlertController(title: "修改訂單", message: "請輸入密碼", preferredStyle: .alert) //產生AlertController
        
        // 產生確認按鍵
        let okAction = UIAlertAction(title: "確認", style: .default) { (action: UIAlertAction) in
            let nameTextField  = checkAlert.textFields![0] as UITextField // 取得訂購者姓名
            let passwordTextField = checkAlert.textFields![1] as UITextField // 取得使用者輸入密碼
            let userDefault = UserDefaults.standard
            let name = userDefault.string(forKey: "name:\(nameTextField.text!)") // 從UserDefaults讀取訂購者姓名
            let password = userDefault.string(forKey: "password:\(nameTextField.text!)") // 從UserDefaults讀取訂購者的密碼
            
            if nameTextField.text! == name && passwordTextField.text! == password  { // 判斷訂購者與密碼是否正確                
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "EditTableView") as? EditTableViewController { // 正確則顯示下一個修改畫面
                    
                    controller.userName = name
                    controller.userPassword = password
                    // controller.name = name
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                self.dismiss(animated: true, completion: nil)
                
            }else {
                self.showAlertMessage(title: "輸入資料錯誤", message: "請確認姓名與密碼")
            }
        }
        
        // 產生取消按鍵
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (action: UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        // 增加Name的Text Field到Alert
        checkAlert.addTextField(configurationHandler: {(textField: UITextField!)->Void in
            textField.placeholder = "Enter Name"
        })
        // 增加Password的Text Field到AlertController
        checkAlert.addTextField(configurationHandler: {(textField: UITextField!)->Void in
            textField.placeholder = "Enter Password"
        })
        
        checkAlert.addAction(okAction) // 將確認按鍵加入AlertController
        checkAlert.addAction(cancelAction) // 將取消按鍵加入AlertController
        self.present(checkAlert, animated: true, completion: nil) // 顯示Alert
    }
    
    func showAlertMessage(title: String, message: String) {
        let inputErrorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert) //產生AlertController
        let okAction = UIAlertAction(title: "確認", style: .default, handler: nil) // 產生確認按鍵
        inputErrorAlert.addAction(okAction) // 將確認按鍵加入AlertController
        self.present(inputErrorAlert, animated: true, completion: nil) // 顯示Alert
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationName = Notification.Name("waitMessage")
        NotificationCenter.default.addObserver(self, selector: #selector(updateWaitUI(noti:)), name: notificationName, object: nil) //註冊訂購確認通知
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getOrder(name: String, password: String){
        let commandString = "search?name=\(name)&&password=\(password)"
        let urlStr = "https://sheetdb.io/api/v1/5af6fd5e5cda2/\(commandString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // 將網址轉換成URL編碼（Percent-Encoding）
        let url = URL(string: urlStr!) // 將字串轉換成url
        // 背景抓取飲料訂單資料
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data, let content = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]]{ // 因為資料的Json的格式為陣列（Array）包物件（Object），所以[[String: Any]]
                for order in content {
                    if let data = OrderInformation(json: order){
                        self.orderArray.append(data)
                    }
                }
                
                print(self.orderArray) // Debug用顯示所有抓取的資料
                
                DispatchQueue.main.async {  // UI的更新必須在Main thread
                    //                    self.stopLoading() //停止Loading動畫並且關閉不顯示
                    //                    self.editTableView.reloadData()    // 更新訂購表
                    //                   self.updateOrdersUI() // 更新訂購數量
                    //                   self.updatePriceUI() // 更新總價
                }
            }
        }
        task.resume() // 開始在背景下載資料
    }
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
     */
    
}
