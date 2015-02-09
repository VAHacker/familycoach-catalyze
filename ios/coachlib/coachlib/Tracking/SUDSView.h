//
//  SUDSView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "GLabel.h"
#import "SUDSThermometerMarkersView.h"

@interface SUDSView : UIView {
	UIImageView *therm;
	SUDSThermometerMarkersView *markersView;
	UIImageView *mercury;
	GLabel *numberLabel;
	CGRect originalMercury;
	int rating;
    BOOL touchDown;
}

@property(readwrite) int rating;

@property(readwrite, retain, nonatomic) IBOutlet UIImageView *therm;
@property(readwrite, retain, nonatomic) IBOutlet SUDSThermometerMarkersView *markersView;
@property(readwrite, retain, nonatomic) IBOutlet UIImageView *mercury;
@property(readwrite, retain, nonatomic) IBOutlet GLabel *numberLabel;

@end
