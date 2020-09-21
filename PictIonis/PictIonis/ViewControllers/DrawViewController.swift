//
//  DrawViewController.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 09/09/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {

    @IBOutlet weak var collectionColorView: UICollectionView!
    
    @IBOutlet weak var canvasView: CanvasView!
    
    @IBOutlet weak var rootStackView: UIStackView!
    
    var colorsArray: [UIColor] = [UIColor.white, UIColor.black, UIColor.red, UIColor.blue, UIColor.green, UIColor.orange, UIColor.yellow, UIColor.purple, UIColor.systemPink]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionColorView.delegate = self
        collectionColorView.dataSource = self
//        view.setGradientBackground(colorOne: Colors.violet, colorTwo: Colors.instagramyBlue)
        //rootStackView.setGradientBackground(colorOne: Colors.violet, colorTwo: Colors.instagramyBlue)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickUndo(_ sender: Any) {
        canvasView.undoDraw()
    }
    
    @IBAction func onClickClear(_ sender: Any) {
        canvasView.clearCanvasView()
    }
    
    @IBAction func onChangeBrushSize(_ sender: UISlider) {
        canvasView.strokeWidth = CGFloat(sender.value)
    }
}

extension DrawViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let view = cell.viewWithTag(111) as UIView? {
            view.backgroundColor = colorsArray[indexPath.row]
            view.layer.cornerRadius = 3
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        canvasView.strokeColor = colorsArray[indexPath.row]
    }
    
    
}
