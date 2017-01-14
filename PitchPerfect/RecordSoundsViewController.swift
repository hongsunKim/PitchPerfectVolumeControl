//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by 김홍순 on 2016. 12. 30..
//  Copyright © 2016년 Hongsun. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var recordTimer: Timer!
    var isRecordPause: Bool = false
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var pauseRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
        pauseRecordingButton.isEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear called")
        recordTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(RecordSoundsViewController.recorderTimerUpdate), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recordTimer.invalidate()
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        
        if isRecordPause {
            audioRecorder.record()
            isRecordPause = false
            recordButton.isEnabled = false
            pauseRecordingButton.isEnabled = true
            stopRecordingButton.isEnabled = true
            return
        }
        
        //recordingLabel.text = "Recording in Progress"
        stopRecordingButton.isEnabled = true
        recordButton.isEnabled = false
        pauseRecordingButton.isEnabled = true
                
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        print(filePath)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        //try! audioPlayer = AVAudioPlayer(contentsOf: URL)
        
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true;
        recordingLabel.text = "Tap to Record"
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }
        print("finished recording")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "stopRecording") {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    func recorderTimerUpdate(){
        if nil != audioRecorder {
            if audioRecorder.isRecording{
                let minutes = Int(audioRecorder.currentTime) / 60
                let seconds = Int(audioRecorder.currentTime - (60*Double(minutes)))
                recordingLabel.text = String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }
    
    @IBAction func pauseRecord(_ sender: Any) {
        if nil != audioRecorder {
            if audioRecorder.isRecording {
                audioRecorder.pause()
                recordButton.isEnabled = true
                stopRecordingButton.isEnabled = true
                pauseRecordingButton.isEnabled = false
                isRecordPause = true
            }
        }
    }
    
}

