//
//  RemindersHeaderType.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 29/12/22.
//

/*
This file is part of SyncTion and is licensed under the GNU General Public License version 3.
SyncTion is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import SyncTionCore

extension Tag {
    struct Reminders {
        private init() { fatalError() }

        static let ListField =  Tag("3635c9d8-34f2-49c5-8078-7552f6b8aef0")!
        static let TitleField =  Tag("4403cef4-c12c-4fbe-a9e2-72f74cd2e0f5")!
        static let NoteField =  Tag("754a2fc4-4e91-4f2e-82fa-62c6431409cd")!
        static let PriorityField =  Tag("0d22c905-cfc1-4342-9ce1-2380e59aaa74")!
        static let AlertField =  Tag("91e7c924-46f4-47a1-b130-d14106f2f66e")!
    }
}
