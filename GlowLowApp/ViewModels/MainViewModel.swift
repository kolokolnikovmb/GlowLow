import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class MainViewModel {
    private let storageService: StorageService
    private let hapticsService: HapticsService

    var todayEntry: DayEntry?
    var selectedStatus: DayStatus?
    var noteText = ""
    var isNoteSheetPresented = false
    var showSavedToast = false

    init(storageService: StorageService, hapticsService: HapticsService) {
        self.storageService = storageService
        self.hapticsService = hapticsService
        loadToday()
    }

    var hasEntryToday: Bool { todayEntry != nil }
    var hasNoteToday: Bool { !(todayEntry?.textNote?.isEmpty ?? true) }

    func loadToday() {
        todayEntry = storageService.fetchTodayEntry()
        selectedStatus = todayEntry?.status
        noteText = todayEntry?.textNote ?? ""
    }

    func selectStatus(_ status: DayStatus) {
        todayEntry = storageService.upsertStatus(for: .now, status: status)
        selectedStatus = status
        showTransientToast()
        hapticsService.success()
    }

    func handleSwipe(_ status: DayStatus) {
        selectStatus(status)
    }

    func openNoteSheet() {
        noteText = todayEntry?.textNote ?? ""
        isNoteSheetPresented = true
    }

    func saveNote(_ text: String) {
        todayEntry = storageService.upsertNote(for: .now, note: text)
        noteText = todayEntry?.textNote ?? ""
        isNoteSheetPresented = false
        showTransientToast()
        hapticsService.selection()
    }

    func deleteNote() {
        storageService.deleteNote(for: .now)
        loadToday()
        isNoteSheetPresented = false
        hapticsService.warning()
    }

    private func showTransientToast() {
        withAnimation(AppAnimations.saveFeedback) {
            showSavedToast = true
        }

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(AppAnimations.saveFeedback) {
                showSavedToast = false
            }
        }
    }
}
