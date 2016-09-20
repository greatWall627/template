import Foundation
import AEXML

public struct Template: Equatable {
  fileprivate let document: AEXMLDocument

  init(xml: Data) throws {
    self.document = try AEXMLDocument(xml: xml)
  }

  func makeElement(with properties: [String: Any]) throws -> Element {
    return try document.root.makeElement(with: properties)
  }
}

public func ==(lhs: Template, rhs: Template) -> Bool {
  return lhs.document.xml == rhs.document.xml
}

extension AEXMLElement {
  func makeElement(with properties: [String: Any]) throws -> Element {
    let resolvedProperties = resolve(properties: attributes, withContextProperties: properties)
    let propertyTypes = NodeRegistry.shared.propertyTypes(for: name)
    let validatedProperties = Validation.validate(propertyTypes: propertyTypes, properties: resolvedProperties)

    return Element(try ElementType.fromRaw(name), validatedProperties, try children.map { try $0.makeElement(with: properties) })
  }

  private func resolve(properties: [String: String], withContextProperties contextProperties: [String: Any]?) -> [String: Any] {
    var resolvedProperties = [String: Any]()
    for (key, value) in properties {
      resolvedProperties[key] = resolve(value, properties: contextProperties)
    }

    return resolvedProperties
  }

  private func resolve(_ value: Any, properties: [String: Any]?) -> Any? {
    guard let expression = value as? String, expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.characters.index(expression.startIndex, offsetBy: 1)
    let keyPath = expression.substring(from: startIndex)

    return properties?.value(forKey: keyPath)
  }
}
