import Foundation

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
