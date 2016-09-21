//
//  NativeNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class NativeNode<T: NativeView>: PropertyNode {
  weak var parent: Node?
  weak var owner: Node?
  var context: Context?

  var properties: T.PropertiesType
  var children: [Node]? {
    didSet {
      updateParent()
    }
  }
  var element: Element
  var builtView: T?
  var cssNode: CSSNode?

  required init(element: Element, properties: [String: Any], children: [Node]?, owner: Node?) {
    self.element = element
    self.properties = T.PropertiesType(properties)
    self.children = children
    self.owner = owner

    updateParent()
  }

  init(element: Element, properties: T.PropertiesType, children: [Node]? = nil, owner: Node? = nil) {
    self.element = element
    self.properties = properties
    self.children = children
    self.owner = owner

    updateParent()
  }

  func build<V: View>() -> V {
    if builtView == nil {
      builtView = T()
    }

    builtView?.eventTarget = owner
    if builtView?.properties != properties {
      builtView?.properties = properties
    }
    builtView?.children = children?.map { $0.build() as V } ?? []

    return builtView as! V
  }

  func getBuiltView<V>() -> V? {
    return builtView as? V
  }
}
