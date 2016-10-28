//
//  RecordingsTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class RecordingsTableViewController: UITableViewController {
    var section: Section!
    
    var player: AVAudioPlayer!
    var session: AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Recordings in \(section.title)"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section.recordings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordingCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = section.recordings[indexPath.row].title
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let title = cell.textLabel?.text
        let recording = try! Realm().objects(Recording).filter(
            "title = %s AND section.title = %s AND project.title = %s",
            title!, section.title, (section.project?.title)!
        ).first!
        
        let url = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        print(url.URLByAppendingPathComponent(recording.title + recording.id + ".caf"))
        
        session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try player = AVAudioPlayer(contentsOfURL: url.URLByAppendingPathComponent(recording.title + recording.id + ".caf"))
            
            player.play()
        } catch {
            print(error)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
