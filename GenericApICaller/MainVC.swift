//
//  ViewController.swift
//  GenericApICaller
//
//  Created by Develop on 4/20/22.
//  Copyright © 2022 Develop. All rights reserved.
//

import UIKit
//Model

struct  Users:Codable {
    let name:String
    let email : String
}



class MainVC: UIViewController {
    var users : [Users]?
    struct  Cosnstant {
        static let url = "https://jsonplaceholder.typicode.com/users"
        
    }
    
    let HeaderTitles = ["NewFeeds","Offers","Tois","Horgada","Segaada"]
    private let tableView : UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        [tableView].forEach{
            $0.delegate = self
            $0.dataSource = self
        }
        
        
        fetchData()
    }
    
    private func fetchData(){
        URLSession.shared.fetchData(url: URL(string: Cosnstant.url), expexting: [Users].self) {  [weak self] result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self?.users = users
                    self?.tableView.reloadData()
                }
                
             
            
            case .failure(let error):
                print(error)
            }
            
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    
    
    
}
extension MainVC : UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell else {return UITableViewCell()}
        cell.textLabel?.text = users?[indexPath.row].email
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return HeaderTitles[section]
    }
    
    
}
extension URLSession {
    
    enum CustomError : Error{
        case invaledURL
        case invaledData
    }
    
    func fetchData <T:Codable>(url:URL?,expexting: T.Type ,completions:@escaping(Result<T,Error>) -> Void) {
        guard let url = url else {
            completions(.failure(CustomError.invaledURL))
            return
        }
        let task = dataTask(with: url) { (data, _, error) in
            guard let data = data else {
                if let error = error {
                    completions(.failure(error))
                }else {
                    completions(.failure(CustomError.invaledData))
                }
                return
            }
            do {
                let results = try JSONDecoder().decode(expexting, from: data)
                completions(.success(results))
            }catch {
                completions(.failure(error))
            }
            
        }
        task.resume()
        
    }
}


