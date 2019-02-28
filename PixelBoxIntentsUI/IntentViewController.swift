
import IntentsUI

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        // Rain
        if interaction.intent is RainIntent {
            if interaction.intentResponse is RainIntentResponse {
                addVC(IntentVisualViewController((interaction.intentResponse as! RainIntentResponse).serverMessage!))
            }
            let viewSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            completion(true, parameters, viewSize)
            return
        }
        
        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
}

extension IntentViewController {
    private func addVC(_ vc:UIViewController) {
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
        vc.didMove(toParent: self)
        
        vc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func instantiateAndInstall<VC:UIViewController>(ofType type: VC.Type) -> VC {
        let vc = VC()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
        vc.didMove(toParent: self)
        
        vc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        return vc
    }
}

extension IntentViewController: INUIHostedViewSiriProviding {
    var displaysMessage: Bool {
        return true
    }
}
