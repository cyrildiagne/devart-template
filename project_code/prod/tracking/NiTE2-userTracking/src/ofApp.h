#pragma once

#include "ofMain.h"

#include "ofxNI2.h"
#include "ofxNiTE2.h"
#include "ofxLibwebsockets.h"

#define HOST "localhost"
#define PORT 6667

#define DEVICE_WIDTH 320
#define DEVICE_HEIGHT 240
#define NUM_JOINTS 15

class ofApp : public ofBaseApp
{
public:
	void setup();
	void exit();
	void update();
	void draw();

	void keyPressed(int key);
    
    // websocket methods
    void onConnect( ofxLibwebsockets::Event& args );
    void onOpen( ofxLibwebsockets::Event& args );
    void onClose( ofxLibwebsockets::Event& args );
    void onIdle( ofxLibwebsockets::Event& args );
    void onMessage( ofxLibwebsockets::Event& args );
    void onBroadcast( ofxLibwebsockets::Event& args );
    
private:
    
	ofxNI2::Device device;
	ofxNiTE2::UserTracker tracker;
    ofImage depth_image;
    
    int userId;
    bool isTrackerAvailable;
    
    void onNewUser(ofxNiTE2::User::Ref & user);
    void onLostUser(ofxNiTE2::User::Ref & user);
    bool isUserCloserThanCurrent(ofxNiTE2::User::Ref & user);
    ofxNiTE2::User::Ref getBestCandidate();
    void sendSkeletonData(ofxNiTE2::User::Ref user);
    void drawUser(ofxNiTE2::User::Ref user);
    
    float buffer[NUM_JOINTS*3];
    
    // ----
    
    ofFile savingToFile;
    bool bSaving;
    
    // ----
    
    ofxLibwebsockets::Server server;
    void setupSockets();
    
};