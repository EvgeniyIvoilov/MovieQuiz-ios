//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Евгений Ивойлов on 11.01.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    /// Средняя точность
    var totalAccuracy: Double { get }
    /// Общее кол-во игр
    var gamesCount: Int { get }
    /// Лучшая игра
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
        case totalCorrect, totalAmount
    }

    private let userDefaults = UserDefaults.standard
    private var totalCorrect: Int {
        get {
            userDefaults.integer(forKey: Keys.totalCorrect.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalCorrect.rawValue)
        }
    }
    
    private var totalAmount: Int {
        get {
            userDefaults.integer(forKey: Keys.totalAmount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAmount.rawValue)
        }
    }
    
    private func addGameCount() {
        userDefaults.set(gamesCount + 1, forKey: Keys.gamesCount.rawValue)
    }
}

// MARK: - StatisticService

extension StatisticServiceImplementation: StatisticService {
    var totalAccuracy: Double {
        get {
            guard totalAmount != 0 else { return 100 }
            return Double(totalCorrect) / Double(totalAmount) * 100
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        addGameCount()
        totalCorrect += count
        totalAmount += amount
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        guard currentGame > bestGame else { return }
        bestGame = currentGame
    }
}
