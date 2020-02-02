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

