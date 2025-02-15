//
//  MessageViewController.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 13/02/2025.
//

import UIKit

class MessageViewController: UIViewController {
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var messageQueue: Set<String> = []
    private var isShowingMessage: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        visualEffectView.layer.cornerRadius = 12.0
        visualEffectView.layer.masksToBounds = true
    }
    
    public func add(_ message: String) {
        
        if messageLabel.text != message { messageQueue.insert(message) }
        
        showQueued()
    }
    
    private func showQueued() {
        
        guard !isShowingMessage, !messageQueue.isEmpty else { return }
        
        isShowingMessage = true
        
        let message = messageQueue.removeFirst()
        messageLabel.text = message
            
        messageLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).concatenating(CGAffineTransform(translationX: 0.0, y: 20.0))
            
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1.0
            self.messageLabel.transform = .identity
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.visualEffectView.alpha = 0.0
                    self.messageLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).concatenating(CGAffineTransform(translationX: 0.0, y: 20.0))
                }) { _ in
                    self.messageLabel.text = nil
                    self.isShowingMessage = false
                    self.showQueued()
                }
            }
        }
    }
}
