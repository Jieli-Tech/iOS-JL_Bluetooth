//
//  JLWeatherSync.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/05/06.
//

#import "JLWeatherSync.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>


@interface JLWeatherSync ()<AMapSearchDelegate,AMapLocationManagerDelegate>

@property(nonatomic,strong)AMapSearchAPI *search;
@property(nonatomic,strong)AMapLocationManager *locationManager;
@property(nonatomic,strong)AMapLocationReGeocode *reGeocode;

@end

@implementation JLWeatherSync

+(instancetype)share{
    static JLWeatherSync *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JLWeatherSync alloc] init];
    });
    return instance;
}

-(instancetype)init{
    if (self = [super init]) {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
        self.locationManager = [[AMapLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

-(void)startSyncWeather{
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setLocationTimeout:5];
    [self.locationManager setReGeocodeTimeout:3];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        self.reGeocode = regeocode;
        [self getWeatherInfo];
    }];
}

-(void)getWeatherInfo{
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = self.reGeocode.adcode;
    request.type = AMapWeatherTypeLive;
    [self.search AMapWeatherSearch:request];
}

//MARK: - 定位callback
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
  //定位错误
    kJLLog(JLLOG_DEBUG,@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}


//MARK: - 天气callback
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response{
    if (response.lives.count > 0) {
        AMapLocalWeatherLive *live = response.lives[0];
        [live logProperties];
        NSDateFormatter *fm = [NSDateFormatter new];
        fm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        JL_MSG_Weather *weather = [JL_MSG_Weather new];
        weather.date = [fm dateFromString:live.reportTime];
        weather.province = live.province;
        weather.city = live.city;
        weather.code = [self weatherTypeFromString:live.weather];
        weather.temperature = live.temperature.integerValue;
        weather.humidity = live.humidity.integerValue;
        
        NSCharacterSet *nonDigitsSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSString *digitsOnlyString = [live.windPower stringByReplacingOccurrencesOfString:@"" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, live.windPower.length)];
        weather.wind = digitsOnlyString.integerValue;
        weather.direction = [self wDirectionTypeFrom:live.windDirection];
        [[JLWearable sharedInstance] w_syncWeather:weather withEntity:[[JL_RunSDK sharedMe] mBleEntityM] result:^(BOOL succeed) {
            kJLLog(JLLOG_DEBUG,@"weather sync to device isSuccess:%d", succeed);
        }];
    }
}



- (JLWeatherType)weatherTypeFromString:(NSString *)string {
    if ([string isEqualToString:@"晴"]) {
        return JLWeatherTypeSunny;
    } else if ([string isEqualToString:@"少云"]) {
        return JLWeatherTypeCloudLess;
    } else if ([string isEqualToString:@"晴间多云"]) {
        return JLWeatherTypePartlyCloudy;
    } else if ([string isEqualToString:@"多云"]) {
        return JLWeatherTypeCloudiness;
    } else if ([string isEqualToString:@"阴"]) {
        return JLWeatherTypeOvercastSky;
    } else if ([string isEqualToString:@"有风/和风/清风/微风"]) {
        return JLWeatherTypeBreeze;
    } else if ([string isEqualToString:@"平静"]) {
        return JLWeatherTypeCalmWind;
    } else if ([string isEqualToString:@"大风/强风/劲风/疾风"]) {
        return JLWeatherTypeHighWind;
    } else if ([string isEqualToString:@"飓风/狂爆风"]) {
        return JLWeatherTypeHurricane;
    } else if ([string isEqualToString:@"热带风暴/风暴"]) {
        return JLWeatherTypeTropicalStorm;
    } else if ([string isEqualToString:@"霾/中度霾/重度霾/严重霾"]) {
        return JLWeatherTypeHaze;
    } else if ([string isEqualToString:@"阵雨"]) {
        return JLWeatherTypeShower;
    } else if ([string isEqualToString:@"雷阵雨"]) {
        return JLWeatherTypeThunderShower;
    } else if ([string isEqualToString:@"雷阵雨并伴有冰雹"]) {
        return JLWeatherTypeHallThunderShower;
    } else if ([string isEqualToString:@"雨/小雨/毛毛雨/细雨/小雨-中雨"]) {
        return JLWeatherTypeLightRain;
    } else if ([string isEqualToString:@"中雨/中雨-大雨"]) {
        return JLWeatherTypeModerateRain;
    } else if ([string isEqualToString:@"大雨/大雨-暴雨"]) {
        return JLWeatherTypeHeavyRain;
    } else if ([string isEqualToString:@"暴雨/暴雨-大暴雨"]) {
        return JLWeatherTypeDownpour;
    } else if ([string isEqualToString:@"大暴雨/大暴雨-特大暴雨"]) {
        return JLWeatherTypeExtraordinaryRainstorm;
    } else if ([string isEqualToString:@"特大暴雨"]) {
        return JLWeatherTypeHeavyDownpour;
    } else if ([string isEqualToString:@"强阵雨"]) {
        return JLWeatherTypeStrongRainShower;
    } else if ([string isEqualToString:@"强雷阵雨"]) {
        return JLWeatherTypeStrongThunderShower;
    } else if ([string isEqualToString:@"极端降雨"]) {
        return JLWeatherTypeExtremeRainfall;
    } else if ([string isEqualToString:@"雨夹雪/阵雨夹雪/冻雨/雨雪天气"]) {
        return JLWeatherTypeRainySnowy;
    } else if ([string isEqualToString:@"雪"]) {
        return JLWeatherTypeSnowy;
    } else if ([string isEqualToString:@"阵雪"]) {
        return JLWeatherTypeSnowShower;
    } else if ([string isEqualToString:@"小雪/小雪-中雪"]) {
        return JLWeatherTypeLightSnow;
    } else if ([string isEqualToString:@"中雪/中雪-大雪"]) {
        return JLWeatherTypeModerateSnow;
    } else if ([string isEqualToString:@"大雪/大雪-暴雪"]) {
        return JLWeatherTypeHeavySnow;
    } else if ([string isEqualToString:@"暴雪"]) {
        return JLWeatherTypeSnowstorm;
    } else if ([string isEqualToString:@"浮尘"]) {
        return JLWeatherTypeDust;
    } else if ([string isEqualToString:@"扬沙"]) {
        return JLWeatherTypeblowingSand;
    } else if ([string isEqualToString:@"沙尘暴"]) {
        return JLWeatherTypedustStorm;
    } else if ([string isEqualToString:@"强沙尘暴"]) {
        return JLWeatherTypeSevereSandstorm;
    } else if ([string isEqualToString:@"龙卷风"]) {
        return JLWeatherTypeTornado;
    } else if ([string isEqualToString:@"雾/轻雾/浓雾/强浓雾/特强浓雾"]) {
        return JLWeatherTypeFog;
    } else if ([string isEqualToString:@"未知2"]) {
        return JLWeatherTypeUnknown1;
    } else if ([string isEqualToString:@"冷"]) {
        return JLWeatherTypeCold;
    } else {
        return JLWeatherTypeUnknow;
    }
}
- (JLWindDirectionType)wDirectionTypeFrom:(NSString *)direction {
    if ([direction isEqualToString:@"东"]) {
        return JLWindDirectionTypeEast;
    }else if ([direction isEqualToString:@"南"]) {
        return JLWindDirectionTypeSouth;
    }else if ([direction isEqualToString:@"西"]) {
        return JLWindDirectionTypeWest;
    }else if ([direction isEqualToString:@"北"]) {
        return JLWindDirectionTypeNorth;
    }else if ([direction isEqualToString:@"东南"]) {
        return JLWindDirectionTypeEastSouth;
    }else if ([direction isEqualToString:@"东北"]) {
        return JLWindDirectionTypeEastNorth;
    }else if ([direction isEqualToString:@"西北"]) {
        return JLWindDirectionTypeWestNorth;
    }else if ([direction isEqualToString:@"西南"]) {
        return JLWindDirectionTypeWestSouth;
    }else if ([direction isEqualToString:@"未知"]) {
        return JLWindDirectionTypeUnknow;
    }else {
        return JLWindDirectionTypeNone;
    }
    
}

@end
