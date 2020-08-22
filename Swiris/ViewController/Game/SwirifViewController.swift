import UIKit

public struct Cp {
    var px = 0
    var py = 0
}

public enum Which: Int {
    case left = 0
    case right = 1
}

@available(iOS 10.0, *)
class Swiris: UIViewController {
    var barSize: CGFloat = 20
    var score: Int = 0
    var isMove: Bool = false
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var nextBarField: NextBarField!
    @IBOutlet var rotstionButton: UIButton!
    var firstTap: CGFloat = 0
    @IBOutlet var brewView: UIView!
    var isGameOver: Bool!
    @IBOutlet var levelLbl: UILabel!
    var theBar: [[Int]]!
    var nextTheBar: [[Int]]!
    var moveBar: Timer!
    var isBar: Bool = false
    var CBColor: Int!
    var isDownBar: Bool!
    var isPopup: Bool!
    var levelMng: LevelManager!
    var bars: Bars! = Bars()

    @IBOutlet var brewViewHeightConstraint: NSLayoutConstraint!
    var brewCount: Float = 0.0

    var isDown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationItem.titleView = navigationTitle(title: "Swiris")
        levelMng = LevelManager()
        setGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.text = "0"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }

    func setGesture() {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(pushRotation))
        view.addGestureRecognizer(tapGes)

        let swipeGes = UISwipeGestureRecognizer(target: self, action: #selector(downBar))
        swipeGes.direction = .down
        view.addGestureRecognizer(swipeGes)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        barInit()
        startBrew()
    }

    @IBAction func pushInBackButton(_: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func pushRotation(_: Any) {
        tapRotation()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        let touch = touches.first
        firstTap = touch!.location(in: view).x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        let touch = touches.first
        let newDx = touch?.location(in: view).x
        let move = firstTap - newDx!
        if move < -11 {
            if move.truncatingRemainder(dividingBy: 2) == 0 {
                swipeRight()
            }
        } else if move > 11 {
            if move.truncatingRemainder(dividingBy: 2) == 0 {
                swipeLeft()
            }
        }
    }

    @IBAction func left(_: Any) {
        swipeLeft()
    }

    @IBAction func right(_: Any) {
        swipeRight()
    }

    func swipeLeft() {
        if isBarMove(which: .left,
                     noNd: bars.noneed) != true
        {
            if isMoveJusgemnet(which: .left,
                               noNd: bars.noneed) != true
            {
                if isBar == false {
                    let cCp: [Cp] = bars.noneed
                    removeCurrent(cCp: cCp)
                    bars.cp.px -= 1
                    moveBar.invalidate()
                    bars.move(bar: theBar, cColor: CBColor)
                    barDisplay()
                    startEngine()
                }
            }
        }
    }

    func swipeRight() {
            if isBarMove(which: .right,
                         noNd: bars.noneed) != true
            {
                if isMoveJusgemnet(which: .right,
                                   noNd: bars.noneed) != true
                {
                    if isBar == false {
                        let cCp: [Cp] = bars.noneed
                        removeCurrent(cCp: cCp)
                        bars.cp.px += 1
                        bars.move(bar: theBar, cColor: CBColor)
                        barDisplay()
                    }
                }
            }
    }

    func isBarMove(which: Which, noNd: [Cp]) -> Bool {
        for cpVal in noNd {
            if which == .left {
                if cpVal.px <= 0 {
                    return true
                }
            } else if which == .right {
                if cpVal.px >= (Yoko - 1) {
                    return true
                }
            }
        }
        return false
    }

    func isMoveJusgemnet(which: Which, noNd: [Cp]) -> Bool {
        for current in 0 ..< bars.noneed.count {
            let cPosition: Cp = noNd[current]

            let bar: [Bs] = bars.values[cPosition.py]

            if which == .left {
                if bar[cPosition.px - 1].bp == Bars.Store {
                    return true
                }
            } else if which == .right {
                if bar[cPosition.px + 1].bp == Bars.Store {
                    return true
                }
            }
        }
        return false
    }

    @objc func downGes() {
        downBar()
    }

    @objc func downBar() {
        if isDownBar == false,
            isPopup == false
        {
            isDownBar = true
            var isBottom = false
            var count = 1
            let cCp: [Cp] = bars.noneed

            removeCurrent(cCp: cCp)

            while count < (bars.numberOfCount - 1) {
                for current in (0 ..< bars.noneed.count).reversed() {
                    let cPosition: Cp = bars.noneed[current]

                    let judge = cPosition.py + count

                    if judge >= Tate {
                        break
                    }

                    let bar: [Bs] = bars.values[cPosition.py + count]

                    if bar[cPosition.px].bp == Bars.Store {
                        isBottom = true

                        bars.cp.py = (count - 1) + cPosition.py

                        for nd in 0 ..< bars.noneed.count {
                            var n = bars.noneed[nd]
                            bars.cp.py = (count - 1) + n.py

                            if bars.cp.py == 1 {
                                if isPopup == false {
                                    isPopup = true
                                    moveBar.invalidate()
                                    gameOverAlert()
                                    return
                                }
                            }

                            n.py = bars.cp.py
                            var tate: [Bs] = bars.values[n.py]
                            tate[n.px].bp = 1
                            bars.values[n.py] = tate
                        }
                        break
                    }
                }
                if isBottom == true {
                    break
                }
                count += 1
            }

            if isBottom == false {
                bars.cp.py = count - 3
                for tate in 0 ..< theBar.count {
                    let baryoko: [Int] = theBar[tate]

                    for yoko in 0 ..< baryoko.count {
                        if baryoko[yoko] == Bars.Move {
                            var brew: [Bs] = bars.values[bars.cp.py + tate]
                            brew[yoko + bars.cp.px].bp = 1
                            bars.values[bars.cp.py + tate] = brew
                        }
                    }
                }
            }
            theBar = []
            bars.store(cbColor: CBColor)

            var tag: Int

            tag = 1

            for tate in 0 ..< Tate {
                let isBar: [Bs] = bars.values[tate]

                for yoko in 0 ..< Yoko {
                    if isBar[yoko].bp == Bars.Store {
                        let bar = brewView.viewWithTag(tag) as! Bar
                        bar.brew(isBar[yoko].bc)
                    } else {
                        let bar = brewView.viewWithTag(tag) as! Bar
                        bar.noBrew()
                    }
                    tag += 1
                }
            }
            isBar = false
            bars.cp.px = DPX
            bars.cp.py = DPY
            setNextBar()
            if isGameOver == true {
                isPopup = true
                moveBar.invalidate()
                gameOverAlert()
                return
            }
            bars.store(cbColor: CBColor)
            if bars.isInAgreement() {
                barDisplay()
                setScore(sc: bars.removeLists.count)
            }
            isDownBar = false
        }
    }

    func removeCurrent(cCp: [Cp]) {
        for ccp in cCp {
            var br = bars.values[ccp.py]

            br[ccp.px].bp = 0
            br[ccp.px].bc = 0
            bars.values[ccp.py] = br
        }
    }

    @objc func tapRotation() {
        rotation(bar: theBar)
    }

    /*
     [[0,0,0,0],   [[0,0,0,0],
     [0,1,1,0],    [0,0,0,0],
     [0,0,1,0], -> [1,1,1,0],
     [0,0,1,0]]    [1,0,0,0]]
     */
    func rotation(bar: [[Int]]) {
        let rotations = bars.spin(bars: bar)

        if bars.fixPosition(bar: rotations) == true {
            return
        }
        let cCp: [Cp] = bars.noneed
        removeCurrent(cCp: cCp)
        theBar = rotations
        bars.move(bar: theBar, cColor: CBColor)
        barDisplay()
    }

    func startBrew() {
        levelLbl.text = levelMng.levelText
        scoreLabel.text = "0"
        score = 0
        isPopup = false
        nextTheBar = nil
        theBar = nil
        isDownBar = false
        isBar = false
        isMove = false
        isGameOver = false
        BarInitialze()
        nextBarField.initializeField()
        theBar = Bars.getTheBar
        nextBarField.displayNextBar()
        bars = Bars()
        bars.cp.px = DPX
        bars.cp.py = DPY
        CBColor = Color.radomNum()
        theBar = Bars.getTheBar // getTheBar()
        startGame()
    }

    func startGame() {
        if levelMng.currentLevel > 12 {
            levelMng.currentLevel = 12
        }
        startEngine()
    }

    func startEngine() {
        moveBar = Timer.scheduledTimer(timeInterval: TimeInterval(levelMng.levelCount / 10),
                                       target: self,
                                       selector: #selector(Swiris.brewrisEngine),
                                       userInfo: nil, repeats: true)
    }

    @objc func brewrisEngine() {
        brewCount += 0.1

        if brewCount >= levelMng.levelCount {
            brewCount = 0
            moveBarBrew()
        }
    }

    func barSizeCalculation() -> CGFloat {
        return brewView.frame.size.width / CGFloat(Yoko)
    }

    func swirisFieldHeight(barSize: CGFloat) -> CGFloat {
        return barSize * CGFloat(Tate)
    }

    func barInit() {
        var tag = 1
        barSize = barSizeCalculation()
        brewViewHeightConstraint.constant = swirisFieldHeight(barSize: barSize)
        for tate in 0 ..< Tate {
            for yoko in 0 ..< Yoko {
                let bar: Bar = Bar(frame: CGRect(x: CGFloat(yoko) * barSize,
                                                 y: CGFloat(tate) * barSize,
                                                 width: CGFloat(barSize),
                                                 height: CGFloat(barSize)), tag: tag)
                brewView.addSubview(bar)
                tag += 1
            }
        }
    }

    func setNextBar() {
        theBar = nextBarField.nextBar
        isGameOver = GameOver(bar: theBar)
        CBColor = nextBarField.NBColor
        nextBarField.displayNextBar()
    }

    func GameOver(bar: [[Int]]) -> Bool {
        for tate in (0 ..< bar.count).reversed() {
            let baryoko: [Int] = bar[tate]

            for yoko in 0 ..< baryoko.count {
                if baryoko[yoko] == 1 {
                    let brew: [Bs] = bars.values[bars.cp.py + tate]
                    if brew[yoko + bars.cp.px].bp != 0 {
                        print("GAME OVER")
                        return true
                    }
                }
            }
        }
        return false
    }

    func gameOverAlert() {
        let alert: UIAlertController = UIAlertController(title: "GAME OVER", message: "", preferredStyle: .alert)

        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self]
            (_: UIAlertAction!) -> Void in
            self?.startBrew()
        })

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self]
            (_: UIAlertAction!) -> Void in
            print("Cancel")
            self?.startBrew()
        })

        alert.addAction(defaultAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    @objc func moveBarBrew() {
//        BarLog(bar: theBar)
        if isBar == false {
            if isMove == false {
                isMove = true
                bars.move(bar: theBar, cColor: CBColor)
                BarLog(bar: bars.values)
                barDisplay()
                if isGameOver == true {
                    moveBar.invalidate()
                    gameOverAlert()
                }
            }
        }

        if isBottom(needs: bars.noneed) == true
            || isBar == true
        {
            bars.noneed = Array()
            isBar = false
            bars.cp.px = DPX
            bars.cp.py = DPY
            setNextBar()
            bars.store(cbColor: CBColor)
            isGameOver = GameOver(bar: theBar)
            
            if bars.isInAgreement() {
                barDisplay()
                setScore(sc: bars.removeLists.count)
            }
            bars.store(cbColor: CBColor)
            isDownBar = false

        } else {
            isBar = judgementBrew()
            if isBar == false {
                noNeedEmurate()
                isMove = false
                isDown = true
                bars.cp.py += 1
            }
        }
    }

    func BarInitialze() {
        var tag: Int = 1
        for _ in 0 ..< Tate {
            for _ in 0 ..< Yoko {
                let bar: Bar = brewView.viewWithTag(tag) as! Bar
                bar.noBrew()
                tag += 1
            }
        }
    }

    func barDisplay() {
        var tag: Int = 1

        for tate in 0 ..< Tate {
            let isBar: [Bs] = bars.values[tate]

            for yoko in 0 ..< Yoko {
                if isBar[yoko].bp == Bars.Move {
                    let bar = brewView.viewWithTag(tag) as! Bar
                    bar.brew(isBar[yoko].bc)

                } else if isBar[yoko].bp != Bars.Store {
                    let bar: Bar = brewView.viewWithTag(tag) as! Bar
                    bar.noBrew()
                }
                tag += 1
            }
        }
    }

    func noNeedEmurate() {
        for yoko in 0 ..< bars.numberOfCount {
            var tate: [Bs] = bars.values[yoko]

            for brew in 0 ..< tate.count {
                if tate[brew].bp == Bars.Move {
                    tate[brew].bp = 0
                }
            }
            bars.values[yoko] = tate
        }
    }

    func judgementBrew() -> Bool {
        for current in (0 ..< bars.noneed.count).reversed() {
            let cPosition: Cp = bars.noneed[current]

            let bar: [Bs] = bars.values[cPosition.py + 1]

            if bar[cPosition.px].bp == Bars.Store {
                return true
            }
        }
        return false
    }

    func isBottom(needs: [Cp]) -> Bool {
        let bottom = Tate - 1

        for current in needs {
            if bottom <= current.py {
                return true
            }
        }
        return false
    }

    func setScore(sc: Int) {
        score = score + 10 * sc * (levelMng.currentLevel * 5)
        if levelMng.isLevelUp(score: score) {
            levelLbl.text = levelMng.levelText
            moveBar.invalidate()
            startGame()
        }
        scoreLabel.text = score.description
    }
}
