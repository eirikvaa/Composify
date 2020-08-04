import UIKit

class IndexViewController: UIViewController {
  
  init(index: Int) {
    super.init(nibName: nil, bundle: nil)
    title = "View \(index)"
    
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 70, weight: UIFont.Weight.thin)
    label.textColor = UIColor(red: 95/255, green: 102/255, blue: 108/255, alpha: 1)
    label.text = "\(index)"
    label.sizeToFit()
    
    view.addSubview(label)
    view.constrainCentered(label)
    view.backgroundColor = .white
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
