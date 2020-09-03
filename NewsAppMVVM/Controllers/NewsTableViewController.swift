//
//  NewsTableViewController.swift
//  NewsAppMVVM
//
//  Created by Theodora on 9/3/20.
//  Copyright © 2020 Feodora Andryieuskaya. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


class NewsTableViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    private var articleListVM: ArticleListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        populateNews()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articleListVM == nil ? 0: self.articleListVM.articlesVM.count
    }

   
    
    private func populateNews() {
        
        let resource = Resource<ArticleResponse>(url: URL(string: "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=705e236c5855460bb094293ec34ce93f")!)
         URLRequest.load(resource: resource)
                    .subscribe(onNext: { articleResponse in
                        
                        let articles = articleResponse.articles
                        self.articleListVM = ArticleListViewModel(articles)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }                      
                    }).disposed(by: disposeBag)
                
            }
            
            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ArticleTableViewCell else {
                    fatalError("ArticleTableViewCell is not found")
                }
                
                let articleVM = self.articleListVM.articleAt(indexPath.row)
                
                articleVM.title.asDriver(onErrorJustReturn: "")
                .drive(cell.titleLabel.rx.text)
                .disposed(by: disposeBag)
                
                articleVM.description.asDriver(onErrorJustReturn: "")
                    .drive(cell.descriptionLabel.rx.text)
                    .disposed(by: disposeBag)
                
                return cell
                
            }
            
        }
