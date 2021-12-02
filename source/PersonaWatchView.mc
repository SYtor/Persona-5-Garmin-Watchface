import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class PersonaWatchView extends WatchUi.WatchFace {

    var screenSize;
    var screenCenter;

    var isSleeping = false;

    var font = Graphics.FONT_SYSTEM_NUMBER_HOT;
    var jpFont;

    var jpNumbers = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
    
    var redColor = 0xf40000;
    var secondsCircleWidthPx = 5;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        screenSize = dc.getWidth();
        screenCenter = screenSize / 2;

        jpFont = WatchUi.loadResource(Rez.Fonts.JpFont);
    }

    function onUpdate(dc as Dc) as Void {
        var offsetSeconds = System.getClockTime().timeZoneOffset;
        var offsetDuration = new Time.Duration(offsetSeconds);
        var time = Gregorian.utcInfo(Time.now().add(offsetDuration), Time.FORMAT_SHORT);

        drawSeconds(dc, time);
        drawTime(dc, time);
        drawDate(dc, time);
        drawBatteryLevel(dc);
    }

    function onExitSleep() as Void {
        isSleeping = false;
    }

    function onEnterSleep() as Void {
        isSleeping = true;
    }

    function drawSeconds(dc as Dc, time as Gregorian.Info) {
        dc.setColor(Graphics.COLOR_BLACK, redColor);
        dc.clear();
        dc.fillCircle(screenCenter, screenCenter, screenSize / 2 - secondsCircleWidthPx);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        var seconds = time.sec;
        if(isSleeping) {
            seconds = 0;
        }
        
        if(!(seconds == 60 || seconds == 0)) {
            var rotation;
            var startPoint;
            var helperPoint1;
            var helperPoint2;
            var helperPointZone = seconds / 15;
            switch(helperPointZone) {
                case 0: 
                    rotation = Math.toRadians(-180 - seconds * 6);
                    startPoint = [screenCenter, screenSize];
                    helperPoint1 = [screenSize, 0];
                    helperPoint2 = [screenSize, screenSize];
                    break;
                case 1: 
                    rotation = Math.toRadians(-180 - seconds * 6);
                    startPoint = [screenCenter, screenSize];
                    helperPoint1 = [screenSize, screenSize];
                    helperPoint2 = [screenSize, screenSize];
                    break;
                case 2: 
                    rotation = Math.toRadians(-180 - seconds * 6);
                    startPoint = [screenCenter, 0];
                    helperPoint1 = [0, screenSize];
                    helperPoint2 = [0, 0];
                    break;
                case 3: 
                    rotation = Math.toRadians(-180 - seconds * 6);
                    startPoint = [screenCenter, 0];
                    helperPoint1 = [0, 0];
                    helperPoint2 = [0, 0];
                    break;
            }
            var x = screenCenter + Math.sin(rotation) * screenCenter;
            var y = screenCenter + Math.cos(rotation) * screenCenter;
            if(seconds < 30) {
                dc.fillRectangle(0, 0, screenCenter, screenSize);
            }
            dc.fillPolygon([startPoint, [screenCenter, screenCenter], [x, y],  helperPoint1, helperPoint2]);
        } 
    }

    function drawTime(dc as Dc, time as Gregorian.Info) {
        var hoursText = "";
        var minutesText = "";

        if(time.hour < 10) {
            hoursText += "0";
        }
        hoursText += time.hour;

        if(time.min < 10) {
            minutesText += "0";
        }
        minutesText += time.min;

        var timeText = hoursText + ":" + minutesText;

        var possibleRotations = [3, 5, 175, 177];
        var rotation = possibleRotations[Math.rand() % possibleRotations.size()];

        var separatorDimens = dc.getTextDimensions(":", font); 
        var numsDimens = dc.getTextDimensions("00", font); 

        var textY = dc.getHeight() / 2 - numsDimens[1] * 5 / 6;

        var hoursX = screenCenter - numsDimens[0] - separatorDimens[0];
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatedRectangle(hoursX, textY,  numsDimens[0] , numsDimens[1], Math.toRadians(rotation)));

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(hoursX, textY, font, hoursText, Graphics.TEXT_JUSTIFY_LEFT);
        
        var separatorX = screenCenter;
        
        rotation = possibleRotations[Math.rand() % possibleRotations.size()];
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatedRectangle(separatorX - separatorDimens[0] / 2, textY + separatorDimens[1] / 3,  separatorDimens[0] , separatorDimens[1] / 2, Math.toRadians(rotation)));

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(separatorX, textY, font, ":", Graphics.TEXT_JUSTIFY_CENTER);

        var minutesX = screenCenter + separatorDimens[0];

        rotation = possibleRotations[Math.rand() % possibleRotations.size()];
        dc.setColor(redColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatedRectangle(minutesX, textY,  numsDimens[0] , numsDimens[1], Math.toRadians(rotation)));

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(minutesX, textY, font, minutesText, Graphics.TEXT_JUSTIFY_LEFT);
        
    }

    function drawDate(dc as Dc, time as Gregorian.Info) {
        var dateText = time.month + "月" + time.day + "日";
        var dateTextDimens = dc.getTextDimensions(dateText, jpFont);

        var dateTextX = dc.getWidth() / 2;
        var dateTextY = dc.getHeight() / 2 + 40;
        
        var possibleDateRotations = [2, 4, 178, 176];
        var rotation = possibleDateRotations[Math.rand() % possibleDateRotations.size()];
        
        dc.setColor(0x40b5b7, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatedRectangle(dateTextX - dateTextDimens[0] / 2 + 4, dateTextY - dateTextDimens[1] / 4 - 4, dateTextDimens[0], dateTextDimens[1] * 3 / 2, Math.toRadians(rotation)));
        dc.setColor(redColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatedRectangle(dateTextX - dateTextDimens[0] / 2, dateTextY - dateTextDimens[1] / 4, dateTextDimens[0], dateTextDimens[1] * 3 / 2, Math.toRadians(rotation)));
       
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dateTextX, dateTextY, jpFont, dateText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawBatteryLevel(dc as Dc) {
        var batteryLevel = System.getSystemStats().battery;
        var batteryText = Lang.format( "SP: $1$/100", [ batteryLevel.format( "%2d" ) ] );
        dc.drawText(screenCenter, screenSize - 30, Graphics.FONT_XTINY, batteryText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function rotatedRectangle(x as Number, y as Number, width as Number, height as Number, rotation as Number){
        var center = [x + width / 2, y + height / 2];
        return [
            rotatePoint(center, [x, y],  rotation),
            rotatePoint(center, [x + width, y], rotation),
            rotatePoint(center, [x+width, y+height], rotation),
            rotatePoint(center, [x, y + height], rotation)
        ];
    }

    function rotatePoint(center as Array<Number>, point as Array<Number>, rotation as Number) {
        var s = Math.sin(rotation);
        var c = Math.cos(rotation);

        // translate point back to origin
        var normPoint = [point[0] - center[0], point[1] - center[1] ];

        // rotate point
        var xnew = normPoint[0] * c - normPoint[1] * s;
        var ynew = normPoint[0] * s + normPoint[1] * c;

        return [center[0] + xnew, center[1] + ynew];
    }

    function getJpNumber(num as Number) {
        var result = "";
        var tens = (num / 10) % 10;
        if(tens > 0) {
            if(tens > 1) {
                result += jpNumbers[tens - 1];
            } 
            result += "十";
        }
        var lastNum = (num % 10);
        if(lastNum > 0) {
            result += jpNumbers[lastNum - 1]; 
        }
        return result;
    }

}
