//
//  RemindersRepository.swift
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

import EventKit
import Foundation
import SwiftUI
import Combine
import SyncTionCore
import PreludePackage

final class RemindersRepository: EKEventsRepository, FormRepository {
    static let shared = RemindersRepository()

    var lists: [Option] {
        Self.store.calendars(for: .reminder).map {
            Option(optionId: $0.calendarIdentifier, description: $0.title)
        }
    }

    func post(form: FormModel) async throws -> Void {
        let granted = try? await Self.store.requestAccess(to: .reminder)
        guard granted != nil else {
            logger.error("RemindersRepository: post() Failed you dont have permissions")
            throw FormError.auth(RemindersFormService.shared.id)
        }
        
        let reminder = EKReminder(eventStore: Self.store)
        let title: TextTemplate? = form.inputs.first(tag: Tag.Reminders.TitleField)
        let note: TextTemplate? = form.inputs.first(tag: Tag.Reminders.NoteField)
        let list: OptionsTemplate? = form.inputs.first(tag: Tag.Reminders.ListField)
        let priority: OptionsTemplate? = form.inputs.first(tag: Tag.Reminders.PriorityField)
        let alert: DateTemplate? = form.inputs.first(tag: Tag.Reminders.AlertField)
        
        reminder.title = title?.value
        reminder.notes = note?.value
        reminder.priority = Int(priority?.value.selected.first?.optionId ?? "0") ?? 0
        if let alertDate = alert?.value.date {
            let alarm = EKAlarm(absoluteDate: alertDate)
            reminder.addAlarm(alarm)
        }
        if let optionId = list?.value.selected.first?.optionId {
            reminder.calendar = Self.store.calendar(withIdentifier: optionId)
        } else {
            reminder.calendar = Self.store.defaultCalendarForNewReminders()
        }
        
        do {
            try Self.store.save(reminder, commit: true)
            logger.info("RemindersRepository: post() Saved")
        } catch {
            logger.error("RemindersRepository: post() Failed on save")
            throw FormError.api(.general(CodableError(error)))
        }
    }

    static var scratchTemplate: FormTemplate {
        let style = FormModel.Style(
            formName: RemindersFormService.shared.description,
            icon: .static(RemindersFormService.shared.icon),
            color: Color.accentColor.rgba
        )
        let remindersDate = DateTemplate(
            header: Header(
                name: String(localized: "Alert date"),
                icon: "calendar",
                tags: [Tag.Reminders.AlertField]
            )
        )
        let remindersPriority = OptionsTemplate(
            header: Header(
                name: String(localized: "Priority"),
                icon: "exclamationmark.2",
                tags: [Tag.Reminders.PriorityField]
            ),
            config: OptionsTemplateConfig(
                singleSelection: Editable(true, constant: true),
                typingSearch: Editable(false, constant: false),
                hideDescription: Editable(true, constant: false)
            ),
            value: Options(
                options: [
                    Option(optionId: "1", icon: .sfsymbols("exclamationmark", nil), description: "1"),
                    Option(optionId: "5", icon: .sfsymbols("exclamationmark.2", nil), description: "5"),
                    Option(optionId: "9", icon: .sfsymbols("exclamationmark.3", nil), description: "9"),
                ],
                singleSelection: true
            )
        )
        let remindersNote = TextTemplate(
            header: Header(
                name: String(localized: "Note"),
                icon: "text.justify.leading",
                tags: [Tag.Reminders.NoteField]
            )
        )
        let remindersText = TextTemplate(
            header: Header(
                name: String(localized: "Reminder"),
                icon: "textformat.abc",
                tags: [Tag.Reminders.TitleField]
            )
        )
        let remindersList = OptionsTemplate(
            header: Header(
                name: String(localized: "My lists"),
                icon: "list.bullet",
                tags: [Tag.Reminders.ListField]
            ),
            config: OptionsTemplateConfig(
                singleSelection: Editable(true, constant: true),
                typingSearch: Editable(false, constant: false)
            )
        )
        
        return FormTemplate(
            FormHeader(
                id: FormTemplateId(),
                style: style,
                integration: RemindersFormService.shared.id
            ),
            inputs: [remindersList, remindersText, remindersNote, remindersPriority, remindersDate]
        )
    }
}

class EKEventsRepository {
    static let store = EKEventStore()
    static func requestAccess(to type: EKEntityType, result: @escaping (Result<Bool, Error>) -> Void) {
        Self.store.requestAccess(to: type) { granted, error in
            Task { @MainActor in
                if let error {
                    result(.failure(error))
                } else {
                    result(.success(granted))
                }
            }
        }
    }
}
