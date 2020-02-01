import Foundation

struct Map {
    
    let x: Int
    let y: Int
    
    var lifeData: [[Bool]]
    
    var generation = 0
    
    var log = [Int]()
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        lifeData = (0..<y).map { _ in
            (0..<x).map { _ in Bool.random() }
        }
        log.append(survivor * 100 / (x * y))
    }
    
    func show() {
        print((0..<x).reduce("") { $0 + "|\($1 % 10)" } + "|")
        
        for (index, row) in lifeData.enumerated() {
            print(row.reduce("") { $0 + ($1 ? "⬜️" : "⬛️") } + ":\(index)")
        }
        
        let percent = survivor * 100 / (x * y)
        print("\(generation)世代目: 生き残りは\(survivor)人(\(percent)%)です\n")
    }
    
    mutating func next() {
        let cloudedRow = [Int](repeating: 0, count: self.x + 2)
        var cloudedMap = [[Int]](repeating: cloudedRow, count: self.y + 2)
        
        let currentData = lifeData
        // reset map
        lifeData = lifeData.map { $0.map { _ in false } }
        
        //引数worldを読み込み過密状況を調査する
        for y in 0..<y {
            for x in 0..<x {
                if currentData[y][x] {
                    for i in 0...2 {
                        for t in 0...2 {
                            cloudedMap[x+i][y+t] += 1
                        }
                    }
                    cloudedMap[x+1][y+1] -= 1
                }
            }
        }
        
        // cloudedMapから生死を判定する
        for y in 1...y{
            for x in 1...x {
                switch cloudedMap[y][x] {
                case 2:
                    if currentData[x-1][y-1] {
                        lifeData[x-1][y-1] = true
                    }
                case 3:
                    lifeData[x-1][y-1] = true
                case 4:
                    lifeData[x-1][y-1] = false
                default: break
                }
            }
        }
        
        generation += 1
        log.append(survivor * 100 / (x * y))
    }
    
    mutating func godHand(at point: (Int, Int), to perform: ((Bool) -> Bool) = {!$0}) {
        lifeData[point.1][point.0] = perform(lifeData[point.1][point.0])
    }
    
    var survivor: Int {
        lifeData.flatMap { $0 }.filter { $0 }.count
    }
}

// MARK: - For Command Line
var map: Map?

while true {
    print("マップの大きさを決めます。")
    print("1~50の好きな数字を入力してください")
    let input = readLine() ?? ""
    if let size = Int(input), 0 < size && size <= 50 {
        map = Map(x: size, y: size)
        map?.show()
        break
    }
}

let howTo = """
<操作方法>
next:    新しい世代に生まれ変わります
repeat:  数世代連続で生まれ変わります
change:  対象のマスを反転します
reverse: 全てのマスを反転します

log:     これまでの生存率の推移を表示します
reset:   新しいゲームを開始します
exit:    ゲームを終了します

"""
print(howTo)

game: while true {
    guard let _map = map else { continue }
    let inputs = (readLine() ?? "").split(separator: " ")
    
    switch inputs.first {
    case "next":
        map?.next()
        map?.show()
        
    case "repeat":
        var count: Int?
        if inputs.count == 2, let num = Int(inputs[1]), num >= 1 {
            count = num
        } else {
            if inputs.count >= 2 {
                print("引数が無効です")
            }
            while true {
                print("何世代進めますか？")
                if let num = readLine().flatMap(Int.init), num >= 1 {
                    count = num
                    break
                }
            }
        }
        
        for i in 1...count! {
            map?.next()
            print("\(i)回目")
            map?.show()
        }
        
    case "change":
        let xRange = 0...(_map.x - 1)
        let yRange = 0...(_map.y - 1)
        
        var x, y: Int?
        
        if inputs.count == 3,
            let _x = Int(inputs[1]), xRange.contains(_x),
            let _y = Int(inputs[2]), yRange.contains(_y) {
            x = _x; y = _y
        } else {
            if inputs.count > 1 {
                print("引数が無効です")
            }
            while true {
                print("x: (0~\(xRange.last!))")
                let input = readLine() ?? ""
                if let _x = Int(input), xRange.contains(_x) {
                    x = _x; break
                }
            }

            while true {
                print("y: (0~\(yRange.last!))")
                let input = readLine() ?? ""
                if let _y = Int(input), yRange.contains(_y) {
                    y = _y; break
                }
            }
        }

        map?.godHand(at: (x!, y!))
        map?.show()
        
    case "reverse":
        map?.lifeData = _map.lifeData.map { $0.map { !$0 } }
        map?.show()
        
    case "reset":
        map = Map(x: _map.x, y: _map.y)
        map?.show()

    case "log":
        map?.log.enumerated().forEach { index, percent in
            print("\(String(format: "% 4d", index))世代目",
                  "\(String(format: "% 3d", percent))%",
                  String(repeating: "\u{25AE}", count: percent))
        }
        print("\n")
        
    case "exit":
        break game
        
    default:
        print(howTo)
    }
}
