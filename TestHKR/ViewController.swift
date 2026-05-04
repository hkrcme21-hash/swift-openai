//
//  ViewController.swift
//  TestHKR
//
//  Created by CME on 29/09/2025.
//

import UIKit
import OpenAI

class ViewController: UIViewController {

    @IBOutlet weak var stack: UIStackView!
    var openAi: OpenAIProtocol!
    var users: [User]? {
        didSet {
            for aUser in users ?? [] {
                let imageView = UIImageView(image: UIImage(systemName: "Person"))
                var userNameLabel = UILabel()
                userNameLabel.text = aUser.name
                var userAgeLabel = UILabel()
                userAgeLabel.text = "\(aUser.age)"
                
                stack.addArrangedSubview(imageView)
                stack.addArrangedSubview(userNameLabel)
                stack.addArrangedSubview(userAgeLabel)
                
                var separatorLabel = UILabel()
                separatorLabel.text = "---------"
                stack.addArrangedSubview(separatorLabel)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = OpenAI.Configuration(token: Constants.token, organizationIdentifier: Constants.orgId, timeoutInterval: 60.0)
        openAi = OpenAI(configuration: configuration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showInputAlert { input in
                Task {
                    do {
                        self.showPopup(response: try await self.inputText(input: input ?? ""))
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }

        
    }
    
    func showInputAlert(completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "Enter Prompt", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Type something..."
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let input = alert.textFields?.first?.text
            completion(input)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(nil)
        }
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    func showPopup(response: String) {
        let alert = UIAlertController(title: "ChatGPT",
                                       message: response,
                                       preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true)
    }
    
    func inputText(input: String) async throws -> String {
        let query = CreateModelResponseQuery(
            input: .textInput(input),
            model: .gpt3_5Turbo
        )

        let response: ResponseObject = try await openAi.responses.createResponse(query: query)
        
        for output in response.output {
            switch output {
            case .outputMessage(let outputMessage):
                for content in outputMessage.content {
                    switch content {
                    case .OutputTextContent(let textContent):
                        
                        if let data = textContent.text.data(using: .utf8) {
                            let decoder = JSONDecoder()
//                            self.users = try decoder.decode([User].self, from: data)
                            
                            
                        }
                        
                        
                        return textContent.text

                    case .RefusalContent(let refusalContent):
                        print(refusalContent.refusal)
                        return ""
                    }
                }
            default:
                return ""
            }
        }
        
        return ""
    }


}

struct User: Codable {
    let name: String
    let age: Int
}
