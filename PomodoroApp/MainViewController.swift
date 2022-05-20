//
//  MainViewController.swift
//  PomodoroApp
//
//  Created by Даниил Смирнов on 19.05.2022.
//

import UIKit

class MainViewController: UIViewController {
    
    private var isWorkTime = true
    private var isStarter = false
    private var timer = Timer()
    var singleTimeClass = SingletonTime.shared
    
    
    private var progressLayer = CAShapeLayer()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .medium)
        label.textColor = .systemRed
        
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play")
        button.setImage(image, for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .medium)
        
        return button
    }()
    
    private lazy var parentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Metric.parentStackViewSpacing
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        
        return stackView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupView()
    }
    
    // MARK: - Settings
    
    private func setupHierarchy() {
        view.addSubview(parentStackView)
        parentStackView.addArrangedSubview(timerLabel)
        parentStackView.addArrangedSubview(button)
        
    }
    
    private func setupLayout() {
        parentStackView.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        parentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        parentStackView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        parentStackView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    private func setupView() {
        configMode()
    }
    
    @objc func startButtonTapped() {
        if isStarter {
            timer.invalidate()
            pauseLayer(layer: view.layer)
            isStarter = false
            configButton()
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
//            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            
            isStarter = true
            
            if view.layer.speed == .zero {
                resumeLayer(layer: view.layer)
            } else {
                basicAnimation()
            }
            
            configButton()
        }
    }
    
    @objc func startTimer() {
        configMode()
        if singleTimeClass.time != 0 {
            singleTimeClass.time -= 1
            configMode()
        } else {
            timer.invalidate()
            isWorkTime = !isWorkTime
            isStarter = false
            if isWorkTime == true {
                singleTimeClass.time = 4
            } else {
                singleTimeClass.time = 10
            }
            configMode()
            configButton()
        }
    }
    
    // MARK: - Animation
     
    func createShapeLayer(with color: UIColor) -> CAShapeLayer {
        let center = view.center
                
        let endAngle = (-CGFloat.pi / 2)
        let startAngle = 2 * CGFloat.pi + endAngle
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 1
        progressLayer.lineCap = .round
        progressLayer.strokeColor = color.cgColor
        
        view.layer.addSublayer(progressLayer)
        
        return progressLayer
    }
    
    private func basicAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(singleTimeClass.time)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true

        progressLayer.add(basicAnimation, forKey: "basicAnimation")
        
    }
    
 
    func pauseLayer(layer: CALayer) {
            let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.speed = 0.0
            layer.timeOffset = pausedTime
        }
        
        func resumeLayer(layer: CALayer) {
            let pausedTime: CFTimeInterval = layer.timeOffset
            layer.speed = 1.0
            layer.timeOffset = 0.0
            layer.beginTime = 0.0
            let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            layer.beginTime = timeSincePause
        }
    
    // MARK: - Private methods
    
    private func stringFormat() -> String {
        let minutes = singleTimeClass.time / 60 % 60
        let seconds = singleTimeClass.time % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    
    private func configMode(){
        if isWorkTime {
            timerLabel.text = stringFormat()
            timerLabel.textColor = .systemRed
            button.tintColor = .systemRed
            progressLayer = createShapeLayer(with: .systemRed)
        } else {
            timerLabel.text = stringFormat()
            timerLabel.textColor = .green
            button.tintColor = .green
            progressLayer = createShapeLayer(with: .green)
        }
    }
    
    private func configButton() {
        if isStarter {
            let image = UIImage(systemName: "pause")
            button.setImage(image, for: .normal)
            
        } else {
            let image = UIImage(systemName: "play")
            button.setImage(image, for: .normal)
        }
    }

}

// MARK: - Constants

extension MainViewController {
    enum Metric {
        static let parentStackViewSpacing: CGFloat = 20
    }
}

