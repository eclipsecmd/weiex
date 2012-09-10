//
//  Status.m
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "Status.h"
#import "WLocation.h"

#define PI 3.141592653

@implementation Status
@synthesize statusId, createdAt, text, source, sourceUrl, favorited, truncated, longitude, latitude, inReplyToStatusId;
@synthesize inReplyToUserId, inReplyToScreenName, thumbnailPic, bmiddlePic, originalPic, user;
@synthesize commentsCount, retweetsCount, retweetedStatus, unread, hasReply;
@synthesize statusKey, relativeLocation, relativeDistance;
@synthesize starAmount,viewAmount;


+ (double)getDistanceByCoorLong:(double) lon1 La:(double) lat1 statusLong:(double) lon2 statusLa:(double) lat2
{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    
    
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    double distance = fabs(dist);
    //NSLog(@" distance four agr: %@,%@,%@,%@, and output distance: %@",lon1,lat1,lon2,lat2,distance);
    return distance;
    }


- (Status*)initWithJsonDictionary:(NSDictionary*)dic 
                         MyRegion:(MKCoordinateRegion)region
{
    self = [super init];
	if (self) {          
		statusId = [dic getLongLongValueValueForKey:@"id" defaultValue:-1];
		statusKey = [[NSNumber alloc]initWithLongLong:statusId];
		createdAt = [dic getTimeValueForKey:@"created_at" defaultValue:0];
		text = [[dic getStringValueForKey:@"text" defaultValue:@""] retain];
		
		// parse source parameter
		NSString *src = [dic getStringValueForKey:@"source" defaultValue:@""];
		NSRange r = [src rangeOfString:@"<a href"];
		NSRange end;
		if (r.location != NSNotFound) {
			NSRange start = [src rangeOfString:@"<a href=\""];
			if (start.location != NSNotFound) {
				int l = [src length];
				NSRange fromRang = NSMakeRange(start.location + start.length, l-start.length-start.location);
				end   = [src rangeOfString:@"\"" options:NSCaseInsensitiveSearch 
											 range:fromRang];
				if (end.location != NSNotFound) {
					r.location = start.location + start.length;
					r.length = end.location - r.location;
					sourceUrl = [src substringWithRange:r];
				}
				else {
					sourceUrl = @"";
				}
			}
			else {
				sourceUrl = @"";
			}			
			start = [src rangeOfString:@"\">"];
			end   = [src rangeOfString:@"</a>"];
			if (start.location != NSNotFound && end.location != NSNotFound) {
				r.location = start.location + start.length;
				r.length = end.location - r.location;
				source = [src substringWithRange:r];
			}
			else {
				source = @"";
			}
		}
		else {
			source = src;
		}
		[source retain];
		[sourceUrl retain];
		
		favorited = [dic getBoolValueForKey:@"favorited" defaultValue:NO];
		truncated = [dic getBoolValueForKey:@"truncated" defaultValue:NO];
		
		NSDictionary* geoDic = [dic objectForKey:@"geo"];
		if (geoDic && [geoDic isKindOfClass:[NSDictionary class]]) {
			NSArray *coordinates = [geoDic objectForKey:@"coordinates"];
			if (coordinates && coordinates.count == 2) {
				longitude = [[coordinates objectAtIndex:1] doubleValue];
				latitude = [[coordinates objectAtIndex:0] doubleValue];
                self.relativeLocation = [Status getRelativeLocation:region.center.longitude
                                                         MyLatitude:region.center.latitude
                                                          Longitude:longitude 
                                                           Latitude:latitude
                                         ];
                self.relativeDistance = [Status getDistanceByCoorLong:region.center.longitude La:region.center.latitude statusLong:longitude statusLa:latitude];
            }
		}
		
		inReplyToStatusId = [dic getLongLongValueValueForKey:@"in_reply_to_status_id" defaultValue:-1];
		inReplyToUserId = [dic getIntValueForKey:@"in_reply_to_user_id" defaultValue:-1];
		inReplyToScreenName = [[dic getStringValueForKey:@"in_reply_to_screen_name" defaultValue:@""] retain];
		thumbnailPic = [[dic getStringValueForKey:@"thumbnail_pic" defaultValue:@""] retain];
		bmiddlePic = [[dic getStringValueForKey:@"bmiddle_pic" defaultValue:@""] retain];
		originalPic = [[dic getStringValueForKey:@"original_pic" defaultValue:@""] retain];
		
        
       
		NSDictionary* userDic = [dic objectForKey:@"user"];
		if (userDic) {
			user = [[User userWithJsonDictionary:userDic] retain];
		}
		//NSLog(@"------------retweeted_status obj:%@", [dic objectForKey:@"retweeted_status"]);
		NSDictionary* retweetedStatusDic = [dic objectForKey:@"retweeted_status"];
		if (retweetedStatusDic) {
			retweetedStatus = [[Status statusWithJsonDictionary:retweetedStatusDic MyRegion:region] retain];
            //NSLog(@"原文微博在说什么------------:%@", retweetedStatus.text);
		}
	}
	return self;
}

- (Status*)initWithJsonDictionary:(NSDictionary*)dic
{
    self = [super init];
	if (self) {          
		statusId = [dic getLongLongValueValueForKey:@"id" defaultValue:-1];
		statusKey = [[NSNumber alloc]initWithLongLong:statusId];
		createdAt = [dic getTimeValueForKey:@"created_at" defaultValue:0];
		text = [[dic getStringValueForKey:@"text" defaultValue:@""] retain];
		
		// parse source parameter
		NSString *src = [dic getStringValueForKey:@"source" defaultValue:@""];
		NSRange r = [src rangeOfString:@"<a href"];
		NSRange end;
		if (r.location != NSNotFound) {
			NSRange start = [src rangeOfString:@"<a href=\""];
			if (start.location != NSNotFound) {
				int l = [src length];
				NSRange fromRang = NSMakeRange(start.location + start.length, l-start.length-start.location);
				end   = [src rangeOfString:@"\"" options:NSCaseInsensitiveSearch 
                                     range:fromRang];
				if (end.location != NSNotFound) {
					r.location = start.location + start.length;
					r.length = end.location - r.location;
					sourceUrl = [src substringWithRange:r];
				}
				else {
					sourceUrl = @"";
				}
			}
			else {
				sourceUrl = @"";
			}			
			start = [src rangeOfString:@"\">"];
			end   = [src rangeOfString:@"</a>"];
			if (start.location != NSNotFound && end.location != NSNotFound) {
				r.location = start.location + start.length;
				r.length = end.location - r.location;
				source = [src substringWithRange:r];
			}
			else {
				source = @"";
			}
		}
		else {
			source = src;
		}
		[source retain];
		[sourceUrl retain];
		
		favorited = [dic getBoolValueForKey:@"favorited" defaultValue:NO];
		truncated = [dic getBoolValueForKey:@"truncated" defaultValue:NO];
		inReplyToStatusId = [dic getLongLongValueValueForKey:@"in_reply_to_status_id" defaultValue:-1];
		inReplyToUserId = [dic getIntValueForKey:@"in_reply_to_user_id" defaultValue:-1];
		inReplyToScreenName = [[dic getStringValueForKey:@"in_reply_to_screen_name" defaultValue:@""] retain];
		thumbnailPic = [[dic getStringValueForKey:@"thumbnail_pic" defaultValue:@""] retain];
		bmiddlePic = [[dic getStringValueForKey:@"bmiddle_pic" defaultValue:@""] retain];
		originalPic = [[dic getStringValueForKey:@"original_pic" defaultValue:@""] retain];
		
        
        
		NSDictionary* userDic = [dic objectForKey:@"user"];
		if (userDic) {
			user = [[User userWithJsonDictionary:userDic] retain];
		}
		//NSLog(@"------------retweeted_status obj:%@", [dic objectForKey:@"retweeted_status"]);
		NSDictionary* retweetedStatusDic = [dic objectForKey:@"retweeted_status"];
		if (retweetedStatusDic) {
			retweetedStatus = [[Status statusWithJsonDictionary:retweetedStatusDic] retain];
            //NSLog(@"原文微博在说什么------------:%@", retweetedStatus.text);
		}
	}
	return self;
}

+ (Status*)statusWithJsonDictionary:(NSDictionary*)dic MyRegion:(MKCoordinateRegion)region
{
	return [[[Status alloc] initWithJsonDictionary:dic MyRegion:region] autorelease];
}

+ (Status*)statusWithJsonDictionary:(NSDictionary*)dic
{
	return [[[Status alloc] initWithJsonDictionary:dic] autorelease];
}

+ (NSString*)getRelativeLocation:(double)Mylongitude 
                        MyLatitude:(double)Mylatitude 
                        Longitude:(double)longitude 
                        Latitude:(double)latitude;
{    
    NSString *_relativelocation;
    if(Mylongitude >= 0 && Mylatitude >= 0 && longitude >= 0 && latitude >= 0){
        double ladeviation = latitude - Mylatitude;
        double lodeviation = longitude - Mylongitude;
        
        CLLocation* location1 = [[CLLocation alloc] initWithLatitude:Mylatitude longitude:Mylongitude];  
        CLLocation* location2 = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];  
        CLLocationDistance diss = [location2 distanceFromLocation:location1];
        [location1 release];
        [location2 release];
        
        double angle = acos(lodeviation/sqrt(ladeviation*ladeviation+lodeviation*lodeviation));
        
        int dis = (int)diss;
        
        if (dis > 100) {
            int temp = dis % 100;
            if (temp < 50) {
                dis = dis - temp;
            }
            else {
                dis = dis - temp + 100;
            }
        }
        
        if (ladeviation >= 0 && lodeviation >= 0) {
            if (angle < PI/12) {
                _relativelocation = [NSString stringWithFormat:@"东方约 %im",dis];
            }
            else if (angle >=PI/12 && angle <= PI*5/12) {
                _relativelocation = [NSString stringWithFormat:@"东北约 %im",dis];
            }
            else {
                _relativelocation = [NSString stringWithFormat:@"北方约 %im",dis];
            }
            
        } 
        else if(ladeviation > 0 && lodeviation < 0) {
            if (angle < PI*7/12) {
                _relativelocation = [NSString stringWithFormat:@"北方约 %im",dis];
            }
            else if (angle >=PI*7/12 && angle <= PI*11/12) {
                _relativelocation = [NSString stringWithFormat:@"西北约 %im",dis];
            }
            else {
                _relativelocation = [NSString stringWithFormat:@"西方约 %im",dis];
            }
        }
        else if(ladeviation <= 0 && lodeviation <= 0) {
            if (angle < PI*7/12) {
                _relativelocation = [NSString stringWithFormat:@"南方约 %im",dis];
            }
            else if (angle >=PI*7/12 && angle <= PI*11/12) {
                _relativelocation = [NSString stringWithFormat:@"西南约 %im",dis];
            }
            else {
                _relativelocation = [NSString stringWithFormat:@"西方约 %im",dis];
            }
            
        }
        else {
            if (angle < PI/12) {
                _relativelocation = [NSString stringWithFormat:@"东方约 %im",dis];
            }
            else if (angle >=PI/12 && angle <= PI*5/12) {
                _relativelocation = [NSString stringWithFormat:@"东南约 %im",dis];
            }
            else {
                _relativelocation = [NSString stringWithFormat:@"南方约 %im",dis];
            }
        }
    } else {
        _relativelocation = @"";
    }
    
    return _relativelocation;
}



- (NSString*)timestamp
{
	NSString *_timestamp;
    // Calculate distance time string
    //
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, createdAt);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"秒前" : @"秒前"];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"分钟前" : @"分钟前"];
    }   
    
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];            
        }
        
        struct tm * createAtTM = localtime(&createdAt);                    
        NSDate * currentlytime = [NSDate date];
        NSCalendar * gregorian = gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];        
        NSDateComponents * currentlytimeComponents = [gregorian components:NSDayCalendarUnit fromDate:currentlytime];           
        if (createAtTM->tm_mday == [currentlytimeComponents day]) {
            [dateFormatter setDateFormat:@"HH:mm"];
        }            
        else if (createAtTM->tm_mday == ([currentlytimeComponents day] - 1) ) {
            [dateFormatter setDateFormat:@"'昨' HH:mm"];
        }
        else {
            [dateFormatter setDateFormat:@"MM.dd HH:mm"];    
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];        
        _timestamp = [dateFormatter stringFromDate:date];      
        
    }
    
    
    
    return _timestamp;
}


- (void)dealloc {
	[text release];
	[source release];
	[sourceUrl release];
	[inReplyToScreenName release];
	[thumbnailPic release];
	[bmiddlePic release];
	[originalPic release];
	[user release];
	[retweetedStatus release];
	[statusKey release];
	[super dealloc];
}


@end
