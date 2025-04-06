import Foundation
import UIKit

final class SubscriptionOptionView: UIView {
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let freeTrialLabel: UILabel = {
        let label = UILabel()
        if let paywall = PurchaseService.shared.inAppPaywall {
            label.text = paywall.config.trial
        }
        label.font = R.font.interSemiBold(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        if let paywall = PurchaseService.shared.inAppPaywall {
            label.text = "\(paywall.config.priceDescription) \(paywall.products.first?.localizedPrice ?? "$6.99/week")"
        }
        label.font = R.font.interRegular(size: 14)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = R.color.c1C1C1E()
        layer.cornerRadius = 16
        
        addSubview(checkmarkImageView)
        addSubview(freeTrialLabel)
        addSubview(priceLabel)
        
        checkmarkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(20)
        }
        
        freeTrialLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkmarkImageView.snp.trailing).offset(8)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(freeTrialLabel.snp.trailing).offset(8)
        }
    }
    
    func configure(with price: String, duration: String) {
        priceLabel.text = price
        freeTrialLabel.text = duration
    }
}
