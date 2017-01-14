//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by 김홍순 on 2016. 12. 31..
//  Copyright © 2016년 Hongsun. All rights reserved.
//
 import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var fullTime: UILabel!
    @IBOutlet weak var timeSlide: UISlider!

    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var playTimer: Timer!
    var tempString: String!
    
    var volume: Float = 0.5
    
    enum ButtonType: Int { case slow = 0, fast, chipmunk, vader, echo, reverb }
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5, volume: volume)
        case .fast:
            playSound(rate: 1.5, volume: volume)
        case .chipmunk:
            playSound(pitch: 1000, volume: volume)
        case .vader:
            playSound(pitch: -1000, volume: volume)
        case .echo:
            playSound(echo: true, volume: volume)
        case .reverb:
            playSound(reverb: true, volume: volume)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        stopAudio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        print(tempString)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
        playTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(PlaySoundsViewController.timeUpdate), userInfo: nil, repeats: true)
        
        if nil != audioFile {
            let DoubleSeconds = (Double(audioFile.length) / audioFile.fileFormat.sampleRate)
            let minutes = Int(DoubleSeconds) / 60
            let seconds = Int(DoubleSeconds) - 60 * minutes
            fullTime.text = String(format: "%02d:%02d", minutes, seconds)
        }
        
        timeSlide.setValue(0, animated: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playTimer.invalidate()
    }
    
    func timeUpdate(){
        if nil != audioPlayerNode {
            //if audioPlayerNode.isPlaying {
                let minutes = Int(currentTime(node: audioPlayerNode)) / 60
                let seconds = Int(currentTime(node: audioPlayerNode) - (60*Double(minutes)))
                playTime.text = String(format: "%02d:%02d", minutes, seconds)
                let fullSeconds = Float(audioFile.length) / Float(audioFile.fileFormat.sampleRate)
                let curSeconds = Float(currentTime(node: audioPlayerNode))
                timeSlide.setValue(curSeconds/fullSeconds, animated: true)
            //}
        }
                }
    
    func currentTime(node: AVAudioPlayerNode) -> TimeInterval {
        if let nodeTime: AVAudioTime = node.lastRenderTime, let playerTime: AVAudioTime = node.playerTime(forNodeTime: nodeTime) {
            return Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
        }
        return 0
    }
    
    /*이 함수에서 슬라이드 바가 움직이면
     프로퍼티 volume 의 값을 조절한다.
     
     만약 프로퍼티 audioPlayerNode 이 nil 이 아니면
     (플레이 중인 상황이 audioPlayerNode 가 nil이 아닌 상황이라 생각했습니다.)
     
     변경된 volume 값을 audioPlayerNode의 volume 에 저장한다.
     (플레이시 변경 될 때 슬라이드 바를 변경하면 볼륨을 조절하기 위해)
     */
    @IBAction func changeVolume(_ sender: Any) {
        
        let sliderRatio = slider.value / slider.maximumValue
        volume = sliderRatio
        
        print(volume)
        
        if (audioEngine) != nil {
            if audioEngine.isRunning{
                audioEngine.mainMixerNode.outputVolume = volume
            }
        }
    }
}
