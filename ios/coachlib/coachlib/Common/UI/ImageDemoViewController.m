/*
 * ImageDemoViewController.m
 * Classes
 * 
 * Created by Jim Dovey on 17/4/2010.
 * 
 * Copyright (c) 2010 Jim Dovey
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "ImageDemoViewController.h"
#import "ImageDemoGridViewCell.h"
#import "ImageDemoFilledCell.h"
#import "iStressLessAppDelegate.h"

enum
{
    ImageDemoCellTypePlain,
    ImageDemoCellTypeFill,
    ImageDemoCellTypeOffset
};

@implementation ImageDemoViewController

@synthesize gridView=_gridView;

@synthesize fetchedResultsController=fetchedResultsController_;

- (NSManagedObjectContext*)managedObjectContext {
	return [iStressLessAppDelegate instance].udManagedObjectContext; 
}

-(void) configureFromContent {
	[self configureMetaContent];
}

- (void)loadView {
	CGRect r = [[UIScreen mainScreen] bounds];
    UIView *container = [[[UIView alloc]initWithFrame:r] autorelease];
	container.autoresizesSubviews = YES;
    r.origin.y += 10;
    r.origin.x += 10;
    r.size.height -= 20;
    r.size.width -= 20;
	AQGridView *gv = [[AQGridView alloc] initWithFrame:r];
	self.gridView = gv;
	gv.delegate = self;
	gv.dataSource = self;
    [container addSubview:gv];
	topView = container;
    [topView retain];
	self.view = topView;
    topView.backgroundColor = [self backgroundColorToUse];
    topView.opaque = TRUE;
	[self configureFromContent];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.gridView.autoresizesSubviews = YES;
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
    [self.gridView reloadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return YES;
}

- (void) viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.gridView = nil;
}

- (void) dealloc
{
    [_gridView release];
    [fetchedResultsController_ release];
    [super dealloc];
}

- (IBAction) toggleLayoutDirection: (UIBarButtonItem *) sender
{
	switch ( _gridView.layoutDirection )
	{
		default:
		case AQGridViewLayoutDirectionVertical:
			sender.title = NSLocalizedString(@"Horizontal Layout", @"");
			_gridView.layoutDirection = AQGridViewLayoutDirectionHorizontal;
			break;
			
		case AQGridViewLayoutDirectionHorizontal:
			sender.title = NSLocalizedString(@"Vertical Layout", @"");
			_gridView.layoutDirection = AQGridViewLayoutDirectionVertical;
			break;
	}
	
	// force the grid view to reflow
	CGRect bounds = CGRectZero;
	bounds.size = _gridView.frame.size;
	_gridView.bounds = bounds;
	[_gridView setNeedsLayout];
}

#pragma mark -
#pragma mark Grid View Data Source

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    int count = [sectionInfo numberOfObjects];
	return count;
}

- (CGRect) gridCellFrame
{
    CGRect r;
	r.origin.x = r.origin.y = 0;
	r.size = [self portraitGridCellSizeForGridView:_gridView];
	return r;
}

- (void)configureCell:(UITableViewCell *)cell atIndex:(int)index {
}

- (AQGridViewCell *)createCell NS_RETURNS_RETAINED {
	return [[ImageDemoGridViewCell alloc] initWithFrame:[self gridCellFrame]
											  reuseIdentifier: @"PlainCellIdentifier"];
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    //static NSString * OffsetCellIdentifier = @"OffsetCellIdentifier";
    
    AQGridViewCell * cell = nil;
	ImageDemoGridViewCell * plainCell = (ImageDemoGridViewCell *)[aGridView dequeueReusableCellWithIdentifier: PlainCellIdentifier];
	if ( plainCell == nil )
	{
		plainCell = (ImageDemoGridViewCell*)[[self createCell] autorelease];
	}

	[self configureCell:(UITableViewCell*)plainCell atIndex:index];
	
	cell = plainCell;
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(320/4, (320/4)) );
}

- (NSFetchedResultsController *)createFetchedResultsController {
	return nil;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ == nil) {
		fetchedResultsController_ = [self createFetchedResultsController];
    }
	
	return fetchedResultsController_;
}    

#pragma mark -
#pragma mark Grid View Delegate

// nothing here yet

@end
