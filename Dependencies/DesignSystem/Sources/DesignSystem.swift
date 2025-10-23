import SwiftUI

public struct DEButtonStyle: ButtonStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label.padding().overlay(RoundedRectangle(cornerRadius: 12).stroke())
  }
}
