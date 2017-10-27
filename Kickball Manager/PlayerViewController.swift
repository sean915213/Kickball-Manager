//
//  PlayerViewController.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility
import Firebase

class PlayerViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Initialization
    
    init() {
        super.init(collectionViewLayout: flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private var players = [Player]()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        return layout
    }()
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.backgroundColor = .white
        // Register cell classes
        collectionView!.register(PlayerCell.self, forCellWithReuseIdentifier: PlayerCell.reuseId)
        loadPlayers()
        resizeCollectionView()
    }
    
    private func loadPlayers() {
        Firestore.firestore().collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.players.append(contentsOf: querySnapshot!.getObjects())
                print("&& TYPED OBJECTS?: \(self.players)")
                self.collectionView!.reloadData()
            }
        }

    }

    private func resizeCollectionView() {
        let availWidth = collectionView!.bounds.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right)
        flowLayout.itemSize = CGSize(width: availWidth, height: 50)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PlayerCell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerCell.reuseId, for: indexPath)
        cell.player = players[indexPath.row]
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
