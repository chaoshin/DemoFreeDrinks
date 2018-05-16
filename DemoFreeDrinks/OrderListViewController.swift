//
//  OrderListViewController.swift
//  DemoFreeDrinks
//
//  Created by Chao Shin on 2018/5/7.
//  Copyright © 2018 Chao Shin. All rights reserved.
//

import UIKit

class OrderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var orderTableView: UITableView!
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var numberOfOrderLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    
    var orderArray = [OrderInformation]()
    
    func updatePriceUI() {
        var price = 0
        
        for i in 0 ..< orderArray.count {
            if let money = Int(orderArray[i].price){
                price += money
            }
        }
        totalPriceLabel.text = "\(price)"
    }
    
    func updateOrdersUI(){
        numberOfOrderLabel.text = "\(orderArray.count)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let information = orderArray[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderlListCell", for: indexPath) as? OrderListTableViewCell else {
            return UITableViewCell()
        }
        cell.information = information
        cell.updateUI(id: indexPath.row)
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderTableView.dataSource = self
        orderTableView.delegate = self
     //   loadingActivityIndicator.isHidden = isLoading
        getOrderList()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopLoading() {
        loadingActivityIndicator.stopAnimating()
    }
    
    func getOrderList(){
        let urlStr = "https://sheetdb.io/api/v1/5af6fd5e5cda2".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // 將網址轉換成URL編碼（Percent-Encoding）
        let url = URL(string: urlStr!) // 將字串轉換成url
        
        // 背景抓取飲料訂單資料
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data, let content = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]]{ // 因為資料的Json的格式為陣列（Array）包物件（Object），所以[[String: Any]]
                
                for order in content {
                    if let data = OrderInformation(json: order){
                        self.orderArray.append(data)
                    }
                }
//              print(self.orderArray) // Debug用顯示所有抓取的資料
                
                DispatchQueue.main.async {  // UI的更新必須在Main thread
                    self.stopLoading() //停止Loading動畫並且關閉不顯示
                    self.orderTableView.reloadData()    // 更新訂購表
                    self.updateOrdersUI() // 更新訂購數量
                    self.updatePriceUI() // 更新總價
                }
            }
        }
        task.resume() // 開始在背景下載資料
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
