//
//  EmptyDataView.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/04/03.
//

import UIKit

protocol EmptyDataViewDelegate {
    func didClickReloadButton()
}

class EmptyDataView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet var contentView: EmptyDataView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    //MARK: - Var
    var delegate: EmptyDataViewDelegate?
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("EmptyDataView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        delegate?.didClickReloadButton()
    }
}
