//
//  CardCollectionViewController.swift
//  PrincessGuide
//
//  Created by zzk on 2018/7/11.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit

class CardCollectionViewController: UIViewController, DataChecking, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    
    var layout: UICollectionViewFlowLayout!
    
    var cards = [Card]()
    
    var sortedCards = [Card]()
    
    let refresher = RefreshHeader()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = UICollectionViewFlowLayout()
        layout.sectionInsetReference = .fromSafeArea
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        layout.itemSize = CGSize(width: 64, height: 64)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        view.backgroundColor = Theme.dynamic.color.background
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.description())
        
        collectionView.mj_header = refresher
        // fix a layout issue of mjrefresh
        // refresher.bounds.origin.y = collectionView.contentInset.top
        refresher.refreshingBlock = { [weak self] in self?.check() }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateEnd(_:)), name: .preloadEnd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSortingChange(_:)), name: .cardSortingSettingsDidChange, object: nil)
        loadData()
    }
    
    @objc private func handleUpdateEnd(_ notification: Notification) {
        loadData()
    }
    
    @objc private func handleSortingChange(_ notification: Notification) {
        loadData()
    }
    
    @objc private func handleNavigationRightItem(_ item: UIBarButtonItem) {
        let vc = CardSortingViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .formSheet
        present(nc, animated: true, completion: nil)
    }
    
    private func loadData() {
        LoadingHUDManager.default.show()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let cards = Array(Preload.default.cards.values)
            let sortedCards = cards.sorted(settings: CardSortingViewController.Setting.default)
            DispatchQueue.main.async {
                LoadingHUDManager.default.hide()
                self?.cards = cards
                self?.sortedCards = sortedCards
                self?.collectionView.reloadData()
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedCards.count
    }
    
    func cardOf(indexPath: IndexPath) -> Card {
        return sortedCards[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.description(), for: indexPath) as! CardCollectionViewCell
        
        let card = sortedCards[indexPath.item]
        cell.configure(for: card, isEnable: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = sortedCards[indexPath.item]
        let vc = CDTabViewController(card: card)
        print("card id: \(card.base.unitId)")
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
