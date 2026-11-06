import Foundation
import SwiftUI

    // Models never call URLSession: the sync service does (a comment, never counted)
struct Note {
    var title: String
}
