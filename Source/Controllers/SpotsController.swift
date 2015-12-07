import UIKit
import Sugar
import Pods

public class SpotsController: UIViewController {

  public private(set) var spots: [Spotable]

  lazy private var container: SpotScrollView = { [unowned self] in
    let container = SpotScrollView(frame: self.view.bounds)
    container.alwaysBounceVertical = true
    container.backgroundColor = UIColor.whiteColor()
    container.clipsToBounds = true
    container.delegate = self

    return container
  }()

  weak public var spotDelegate: SpotsDelegate?

  public required init(spots: [Spotable] = [], refreshable: Bool = true) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)

    spots.enumerate().forEach { spot($0.index).index = $0.index }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(container)

    for spot in spots {
      spot.render().optimize()

      var size = view.frame.size

      if let tabBarController = tabBarController
        where tabBarController.tabBar.translucent {
          (spot.render() as? UITableView)?.contentInset.bottom = tabBarController.tabBar.frame.height
          size.height -= container.contentInset.top
      } else if let _ = navigationController {
        spot.render().contentInset.bottom = container.contentInset.top
      }

      spot.setup(size)
      spot.component.size = CGSize(
        width: view.frame.width,
        height: ceil(spot.render().frame.height))
      container.contentView.addSubview(spot.render())
    }
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    for spot in self.spots {
      spot.render().layoutSubviews()
      spot.render().setNeedsDisplay()
    }
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
  }

  public func spotAtIndex(index: Int) -> Spotable? {
    return spots.filter{ $0.index == index }.first
  }

  public func spot(closure: (index: Int, spot: Spotable) -> Bool) -> Spotable? {
    for (index, spot) in spots.enumerate()
      where closure(index: index, spot: spot) {
        return spot
    }
    return nil
  }

  public func filter(@noescape includeElement: (Spotable) -> Bool) -> [Spotable] {
    return spots.filter(includeElement)
  }

  public func reloadSpots() {
    dispatch { [weak self] in
      self?.spots.forEach { $0.reload([]) {} }
    }
  }

  public func updateSpotAtIndex(index: Int, closure: (spot: Spotable) -> Spotable, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(index) else { return }
    spots[spot.index] = closure(spot: spot)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.spot(spot.index).reload([index]) { }
    }
  }

  public func append(item: ListItem, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.append(item) { completion?() }
  }
  
  public func append(items: [ListItem], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.append(items) { completion?() }
  }
  
  public func prepend(items: [ListItem], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.prepend(items)  { completion?() }
  }

  public func insert(item: ListItem, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.insert(item, index: index)  { completion?() }
  }

  public func update(item: ListItem, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.update(item, index: index)  { completion?() }
  }

  public func delete(index: Int, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.delete(index) { completion?() }
  }

  public func delete(indexes indexes: [Int], spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.delete(indexes) { completion?() }
  }

  public func refreshSpots(refreshControl: UIRefreshControl) {
    dispatch { [weak self] in
      if let weakSelf = self, spotDelegate = weakSelf.spotDelegate {
        spotDelegate.spotsDidReload(refreshControl)
      }
    }
  }
}

extension SpotsController {

  private func component(indexPath: NSIndexPath) -> Component {
    return spot(indexPath).component
  }

  private func spot(indexPath: NSIndexPath) -> Spotable {
    return spots[indexPath.item]
  }

  private func spot(index: Int) -> Spotable {
    return spots[index]
  }
}
