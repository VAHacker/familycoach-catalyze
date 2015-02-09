//
//  SUDSThermometerMarkersView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>


@interface SUDSThermometerMarkersView : UIView {
	UIImage *marker;
	int bottomMarker;
	int topMarker;
}

@property(readwrite) int bottomMarker;
@property(readwrite) int topMarker;

@end
