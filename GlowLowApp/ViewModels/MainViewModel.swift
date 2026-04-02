import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class MainViewModel {
    private let storageService: StorageService
    private let hapticsService: HapticsService

    var todayEntry: DayEntry?
    var draftStatus: DayStatus?
    var noteText = ""
    var isNoteSheetPresented = false
    var showSavedToast = false

    init(storageService: StorageService, hapticsService: HapticsService) {
        self.storageService = storageService
        self.hapticsService = hapticsService
        loadToday()
    }

    var hasEntryToday: Bool { todayEntry?.status != nil }
    var hasNoteToday: Bool { !trimmedDraftNote.isEmpty }
    var savedStatus: DayStatus? { todayEntry?.status }
    var cardStatus: DayStatus? { draftStatus ?? savedStatus }
    var cardNotePreview: String? { trimmedDraftNote.isEmpty ? nil : trimmedDraftNote }
    var canSave: Bool { cardStatus != nil && hasUnsavedChanges }
    var hasUnsavedChanges: Bool {
        savedStatus != cardStatus || storedNote != trimmedDraftNote
    }

    func loadToday() {
        todayEntry = storageService.fetchTodayEntry()
        draftStatus = todayEntry?.status ?? .mid
        noteText = todayEntry?.textNote ?? ""
    }

    func selectStatus(_ status: DayStatus) {
        draftStatus = status
        hapticsService.selection()
    }

    func handleSwipe(_ status: DayStatus) {
        selectStatus(status)
    }

    func openNoteSheet() {
        isNoteSheetPresented = true
    }

    func saveNote(_ text: String) {
        noteText = String(text.prefix(160))
        isNoteSheetPresented = false
    }

    func saveEntry() {
        guard let status = cardStatus else { return }

        _ = storageService.upsertStatus(for: .now, status: status)
        todayEntry = storageService.upsertNote(for: .now, note: trimmedDraftNote)
        draftStatus = status
        noteText = todayEntry?.textNote ?? ""
        showTransientToast()
        hapticsService.success()
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

    private var storedNote: String {
        (todayEntry?.textNote ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedDraftNote: String {
        noteText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
