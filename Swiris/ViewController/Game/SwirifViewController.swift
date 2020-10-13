import UIKit

@available(iOS 10.0, *)
final class Swiris: UIViewController {
    var score: Int = 0
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var nextBarField: NextBarField!
    @IBOutlet private var rotstionButton: UIButton!
    var firstTap: CGFloat = 0
    @IBOutlet var brewView: BrewView!
    @IBOutlet var levelLbl: UILabel!
    var theBar: [[Bs]]!
    var nextTheBar: [[Int]]!
    var moveBar: Timer!
    var CBColor: Int!
    var levelMng: LevelManager!
    var bars: Bars! = Bars()

    @IBOutlet var brewViewHeightConstraint: NSLayoutConstraint!
    var brewCount: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationItem.titleView = navigationTitle(title: "Swiris")
        levelMng = LevelManager()
        setGesture()
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.text = "0"
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
        if bars.isSwipe(which: .left) {
            if !bars.judgementBrew() {
                let cCp: [Cp] = bars.noneed
                bars.removeCurrent(cCp: cCp)
                bars.cp.px -= 1
                bars.move(bar: theBar, cColor: CBColor)
                brewView.barDisplay(bars: bars.values)
            }
        }
    }

    func swipeRight() {
        if bars.isSwipe(which: .right) {
            if !bars.judgementBrew() {
                let cCp: [Cp] = bars.noneed
                bars.removeCurrent(cCp: cCp)
                bars.cp.px += 1
                bars.move(bar: theBar, cColor: CBColor)
                brewView.barDisplay(bars: bars.values)
            }
        }
    }

    @objc func downGes() {
        downBar()
    }

    @objc func downBar() {
        bars.down(bar: theBar) {
            moveBar.invalidate()
            gameOverAlert()
        }
        onTheBar()
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
    func rotation(bar: [[Bs]]) {
        let rotations = bars.spin(bars: bar)

        if bars.fixPosition(bar: rotations) == true {
            return
        }
        let cCp: [Cp] = bars.noneed
        bars.removeCurrent(cCp: cCp)
        theBar = rotations
        bars.move(bar: theBar, cColor: CBColor)
        brewView.barDisplay(bars: bars.values)
    }

    func startBrew() {
        levelLbl.text = levelMng.levelText
        scoreLabel.text = "0"
        score = 0
        nextTheBar = nil
        theBar = nil
        brewView.barInitialze()
        nextBarField.initializeField()
        CBColor = Color.radomNum()
        theBar = Bars.getTheBar(color: CBColor)
        nextBarField.displayNextBar()
        bars = Bars()
        bars.cp.px = DPX
        bars.cp.py = DPY
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

    func barInit() {
        brewViewHeightConstraint.constant = brewView.fieldHeight
        brewView.configure()
    }

    func setNextBar() {
        theBar = nextBarField.nextBar
        if bars.isGameOver(bar: theBar) {
            moveBar.invalidate()
            gameOverAlert()
        }
        CBColor = nextBarField.NBColor
        nextBarField.displayNextBar()
    }

    func gameOverAlert() {
        let actions = [AlertAction(title: "Ok", style: .default, handler: { [weak self] _, _ in
            self?.startBrew()
        }), AlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _, _ in
            self?.startBrew()
        })]
        alert(title: "GAME OVER", message: "Out of move", actions: actions)
    }

    @objc func moveBarBrew() {
        BarLog(bar: bars.values)
        if !bars.judgementBrew() {
            bars.move(bar: theBar, cColor: CBColor)
            brewView.barDisplay(bars: bars.values)
        }

        if bars.isBottom
            || bars.judgementBrew()
        {
            onTheBar()

        } else {
            if !bars.judgementBrew() {
                bars.noNeedEmurate()
                bars.cp.py += 1
            }
        }
    }

    func onTheBar() {
        bars.initalize()
        bars.store(cbColor: CBColor)
        BarLog(bar: bars.values)
        if bars.isInAgreement() {
            BarLog(bar: bars.values)
            brewView.barDisplay(bars: bars.values)
            setScore(sc: bars.removeCount)
            bars.store(cbColor: CBColor)
        }
        setNextBar()
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
