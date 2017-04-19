import Foundation

public class ComponentManager {

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(item: Item, component: Component, withAnimation animation: Animation = .automatic, completion: Completion) {
    Dispatch.main { [weak self] in
      let numberOfItems = component.model.items.count
      component.model.items.append(item)

      if numberOfItems == 0 {
        component.userInterface?.reloadDataSource()
        self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
      } else {
        component.configureItem(at: numberOfItems, usesViewSize: true)
        component.userInterface?.insert([numberOfItems], withAnimation: animation) {
          self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
        }
      }
    }
  }

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(items: [Item], component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      var indexes = [Int]()
      let numberOfItems = component.model.items.count

      component.model.items.append(contentsOf: items)

      items.enumerated().forEach {
        indexes.append(numberOfItems + $0.offset)
        component.configureItem(at: numberOfItems + $0.offset, usesViewSize: true)
      }

      if numberOfItems > 0 {
        component.userInterface?.insert(indexes, withAnimation: animation) {
          self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
        }
      } else {
        component.userInterface?.reloadDataSource()
        self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
      }
    }
  }

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func prepend(items: [Item], component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      let numberOfItems = component.model.items.count
      var indexes = [Int]()

      component.model.items.insert(contentsOf: items, at: 0)

      items.enumerated().forEach {
        if numberOfItems > 0 {
          indexes.append(items.count - 1 - $0.offset)
        }
        component.configureItem(at: $0.offset, usesViewSize: true)
      }

      if !indexes.isEmpty {
        component.userInterface?.insert(indexes, withAnimation: animation) {
          self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
        }
      } else {
        component.userInterface?.reloadDataSource()
        self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
      }
    }
  }

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func insert(item: Item, atIndex index: Int, component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      let numberOfItems = component.model.items.count
      var indexes = [Int]()

      component.model.items.insert(item, at: index)

      if numberOfItems > 0 {
        indexes.append(index)
      }

      if numberOfItems > 0 {
        component.configureItem(at: numberOfItems, usesViewSize: true)
        component.userInterface?.insert(indexes, withAnimation: animation) {
          self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
        }
      } else {
        component.userInterface?.reloadDataSource()
        self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
      }
    }
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(item: Item, component: Component, withAnimation animation: Animation = .automatic, completion: Completion) {
    Dispatch.main {
      guard let index = component.model.items.index(where: { $0 == item }) else {
        completion?()
        return
      }

      component.model.items.remove(at: index)
      component.userInterface?.delete([index], withAnimation: animation) { [weak self] in
        self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
      }
    }
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(items: [Item], component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.main {
      var indexPaths = [Int]()
      var indexes = [Int]()

      for (index, _) in items.enumerated() {
        indexPaths.append(index)
        indexes.append(index)
      }

      indexes.sorted(by: { $0 > $1 }).forEach {
        component.model.items.remove(at: $0)
      }

      component.userInterface?.delete(indexPaths, withAnimation: animation) { [weak self] in
        self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
      }
    }
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(atIndex index: Int, component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.main {
      component.model.items.remove(at: index)
      component.userInterface?.delete([index], withAnimation: animation) { [weak self] in
        self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
      }
    }
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(atIndexes indexes: [Int], component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.main {
      indexes.sorted(by: { $0 > $1 }).forEach {
        component.model.items.remove(at: $0)
      }

      component.userInterface?.delete(indexes, withAnimation: animation) { [weak self] in
        self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
      }
    }
  }

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func update(item: Item, atIndex index: Int, component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let oldItem = component.item(at: index) else {
        completion?()
        return
      }

      component.model.items[index] = item

      if component.model.items[index].kind == CompositeComponent.identifier {
        if let compositeView: Composable? = component.userInterface?.view(at: index) {
          let compositeComponents = component.compositeComponents.filter { $0.itemIndex == item.index }
          compositeView?.configure(&component.model.items[index],
                                   compositeComponents: compositeComponents)
        } else {
          for compositeSpot in component.compositeComponents {
            compositeSpot.component.setup(with: component.view.frame.size)
            compositeSpot.component.reload([])
          }
        }

        self?.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
        return
      } else {
        component.configureItem(at: index, usesViewSize: true)
        let newItem = component.model.items[index]

        if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
          if let cell: ItemConfigurable = component.userInterface?.view(at: index), animation != .none {
            component.userInterface?.beginUpdates()
            cell.configure(&component.model.items[index])
            component.userInterface?.endUpdates()
          } else {
            component.userInterface?.reload([index], withAnimation: animation, completion: nil)
          }

          self?.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
          return
        } else if let cell: ItemConfigurable = component.userInterface?.view(at: index) {
          cell.configure(&component.model.items[index])
          self?.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
        } else {
          self?.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
        }
      }
    }
  }

  /// Reloads a component only if it changes
  ///
  /// - parameter items:      A collection of Items.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  public func reload(indexes: [Int]? = nil, component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.interactive {
      component.refreshIndexes()
      Dispatch.main { [weak self] in
        if let indexes = indexes {
          indexes.forEach { index  in
            component.configureItem(at: index, usesViewSize: true)
          }
        } else {
          for (index, _) in component.model.items.enumerated() {
            component.configureItem(at: index, usesViewSize: true)
          }
        }

        if let indexes = indexes {
          component.userInterface?.reload(indexes, withAnimation: animation) {
            self?.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
          }
          return
        } else {
          if animation != .none {
            component.userInterface?.reloadSection(0, withAnimation: animation) {
              self?.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
            }
            return
          } else {
            component.userInterface?.reloadDataSource()
          }
        }

        self?.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
      }
    }
  }

  /// Reload component with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes: inserations, updates, reloads, deletions and updated children.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(with changes: ItemChanges, component: Component, withAnimation animation: Animation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    component.userInterface?.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions, childUpdates: changes.updatedChildren), withAnimation: animation, updateDataSource: updateDataSource) { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      if changes.updates.isEmpty {
        strongSelf.process(changes.updatedChildren, component: component, withAnimation: animation) {
          strongSelf.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
        }
      } else {
        strongSelf.process(changes.updates, component: component, withAnimation: animation) {
          strongSelf.process(changes.updatedChildren, component: component, withAnimation: animation) {
            strongSelf.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
          }
        }
      }
    }
  }

  /// Reloads a component only if it changes
  ///
  /// - parameter items:      A collection of Items.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  public func reloadIfNeeded(items: [Item], component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.interactive {
      if component.model.items == items {
        Dispatch.main {
          completion?()
        }
        return
      }

      Dispatch.main { [weak self] in
        guard let strongSelf = self else {
          completion?()
          return
        }

        var indexes: [Int]? = nil
        let oldItems = component.model.items
        component.model.items = items

        if items.count == oldItems.count {
          for (index, item) in items.enumerated() {
            guard !(item == oldItems[index]) else {
              component.model.items[index].size = oldItems[index].size
              continue
            }

            if indexes == nil {
              indexes = [Int]()
            }
            indexes?.append(index)
          }
        }

        strongSelf.reload(indexes: indexes, component: component, withAnimation: animation) {
          strongSelf.finishComponentOperation(component, updateHeightAndIndexes: true, completion: completion)
        }
      }
    }
  }

  /// Reload Component object with JSON if contents changed
  ///
  /// - parameter json:      A JSON dictionary.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  A Animation that is used when performing the mutation (only works for Listable objects)
  public func reloadIfNeeded(json: [String : Any], component: Component, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    Dispatch.interactive {
      let newComponentModel = ComponentModel(json)

      guard component.model != newComponentModel else {
        completion?()
        return
      }

      component.model = newComponentModel
      component.reload(nil, withAnimation: animation) { [weak self] in
        self?.finishComponentOperation(component, updateHeightAndIndexes: false, completion: completion)
      }
    }
  }

  /// Process updates and determine if the updates are done.
  ///
  /// - parameter updates:    A collection of updates.
  /// - parameter component: The component that should be mutated.
  /// - parameter animation:  A Animation that is used when performing the mutation.
  /// - parameter completion: A completion closure that is run when the updates are finished.
  private func process(_ updates: [Int], component: Component, withAnimation animation: Animation, completion: Completion) {
    guard !updates.isEmpty else {
      completion?()
      return
    }

    let lastUpdate = updates.last
    for index in updates {
      guard let item = component.item(at: index) else {
        continue
      }

      update(item: item, atIndex: index, component: component, withAnimation: animation) {
        if index == lastUpdate {
          completion?()
        }
      }
    }
  }

  /// Finish component operation.
  ///
  /// - Parameters:
  ///   - component: A component object that has been modified.
  ///   - updateHeightAndIndexes: Determines if the height and indexes should be refreshed.
  ///   - completion: A completion closure that is run when the operation is done.
  private func finishComponentOperation(_ component: Component, updateHeightAndIndexes: Bool, completion: Completion) {
    if updateHeightAndIndexes {
      component.updateHeightAndIndexes {
        component.afterUpdate()
        component.view.superview?.layoutSubviews()
        completion?()
      }
    } else {
      component.afterUpdate()
      component.view.superview?.layoutSubviews()
      completion?()
    }
  }
}