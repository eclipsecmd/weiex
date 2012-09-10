//
//  TakePictureViewController.m
//  WeiTansuo
//
//  Created by Liu Quan on 11/4/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "TakePictureViewController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SETIMAGE(X) [(UIImageView *)self.view setImage:X];
#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)

void myShowAlert(int line, char *functname, id formatstring,...)
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
	NSString *filename = [[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent];
	NSString *debugInfo = [NSString stringWithFormat:@"%@:%d\n%s", filename, line, functname];
    
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:debugInfo delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

@implementation TakePictureViewController


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; 
{
	if (!error) 
		showAlert(@"Image written to photo album");
	else
		showAlert(@"Error writing to photo album: %@", [error localizedDescription]);
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//      NSLog(@"test---------------2");
//	SETIMAGE(image);

	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	[self dismissModalViewControllerAnimated:YES];
    [DataController setCamera:image];
	[picker release];
    [self getBack];
}

- (void)getBack
{
     [self.navigationController popViewControllerAnimated:YES];
}

// Provide 2.x compliance
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	NSDictionary *dict = [NSDictionary dictionaryWithObject:image forKey:@"UIImagePickerControllerOriginalImage"];
	[self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}

// Optional but "expected" dismiss
/*
 - (void) imagePickerControllerDidCancel: 
 (UIImagePickerController *)picker
 {
 [self dismissModalViewControllerAnimated:YES];
 [picker release];
 }
 */

- (void) snapImage: (id) sender
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType =  UIImagePickerControllerSourceTypeCamera;
	ipc.delegate = self;
	//ipc.allowsImageEditing = NO;
    [DataController setCamera:[UIImage imageNamed:@""]];
	[self presentModalViewController:ipc animated:YES];	
}

- (void) viewDidLoad
{
	//self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Snap", @selector(snapImage:));
	else
		showAlert(@"This function relies on camera access, which is not available on this system. Please run this application on a camera-ready device.");
	self.title = @"Image Picker";
}



@end