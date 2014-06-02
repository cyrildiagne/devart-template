#include "ofApp.h"

void ofApp::setup()
{
	ofSetFrameRate(30);
    ofSetLogLevel(OF_LOG_VERBOSE);
	ofBackground(0);
    
    setupSockets();
    
    userId = -1;
    isTrackerAvailable = false;
    memset(buffer, 0, NUM_JOINTS*3);
    
    bSaving = false;
    
    try {
        device.setup("test.oni");
//        device.setup();
        if (tracker.setup(device)){
            isTrackerAvailable = true;
            tracker.setSkeletonSmoothingFactor(0.4);
            ofAddListener(tracker.newUser, this, &ofApp::onNewUser);
            ofAddListener(tracker.lostUser, this, &ofApp::onLostUser);
        }
    } catch (string err){
        ofLogError("ofxNi2") << err;
    }
}

void ofApp::setupSockets(){
    ofxLibwebsockets::ServerOptions options = ofxLibwebsockets::defaultServerOptions();
    options.port = 9092;
    options.protocol = "of-protocol";
    options.bBinaryProtocol = true;
    server.setup( options );
    server.addListener(this);
}

void ofApp::exit() {
	tracker.exit();
	device.exit();
}

void ofApp::onNewUser(ofxNiTE2::User::Ref & user){
    
    ofLogVerbose("ofApp") << "New user : " << user->getId();
    
    if (userId == -1) {
        userId = user->getId();
        server.send("/user/in/" + ofToString(userId) );
    }
}

void ofApp::onLostUser(ofxNiTE2::User::Ref & user){
    
    ofLogVerbose("ofApp") << "User lost : " << user->getId();
    if(userId == user->getId()){
        userId = -1;
        server.send("/user/out/" + ofToString(user->getId()) );
    }
}

bool ofApp::isUserCloserThanCurrent(ofxNiTE2::User::Ref & user){
    if (userId != -1 && user->getId() != userId) {
        const ofxNiTE2::Joint & newTorso = user->getJoint(nite::JOINT_TORSO);
        const ofxNiTE2::Joint & currTorso = tracker.getUserByID(userId)->getJoint(nite::JOINT_TORSO);
        if(newTorso.getPositionConfidence() > 0.2 && currTorso.getPositionConfidence() > 0.2) {
            float newUserX = newTorso.get().getPosition().x;
            float currUserX = currTorso.get().getPosition().x;
            if (fabs(newUserX) < fabs(currUserX)) {
                return true;
            }
        }
    }
    return false;
}

ofxNiTE2::User::Ref ofApp::getBestCandidate(){
    
    ofxNiTE2::User::Ref currentUser = tracker.getUserByID( userId );
    
    for (int i=0; i<tracker.getNumUser(); i++) {
        ofxNiTE2::User::Ref otherUser = tracker.getUser(i);
        if (userId != otherUser->getId()) {
            if (isUserCloserThanCurrent(otherUser)) {
                onLostUser(currentUser);
                onNewUser(otherUser);
                return otherUser;
            }
        }
    }
    return currentUser;
}

void ofApp::update() {
    
	if (isTrackerAvailable) {
        
        device.update();
        
        if( userId != -1 ) {
            ofxNiTE2::User::Ref user = getBestCandidate();
            
            for (int i=0; i<NUM_JOINTS; i++) {
                nite::JointType type = (nite::JointType)i;
                const ofxNiTE2::Joint & joint = user->getJoint(type);
                if(joint.getPositionConfidence() > 0) {
                    ofPoint p = tracker.getProjectiveJointPosition(user->getId(), type);
                    float z = tracker.getUserByID(user->getId())->getJoint(type).getGlobalPosition().z;
                    buffer[i*3] = p.x / depth_image.width - 0.5;
                    buffer[i*3+1] = p.y / depth_image.height -  0.5;
                    if(z != 0)
                        buffer[i*3+2] = z;
                }
            }
            sendSkeletonData(user);
        }
    }

}

void ofApp::sendSkeletonData(ofxNiTE2::User::Ref user){
    
    server.send("/skeleton");
    
    unsigned char * data = reinterpret_cast<unsigned char *>(&buffer);
    server.sendBinary(data, sizeof(float)*NUM_JOINTS*3);
    
    if (bSaving) {
        savingToFile.write( reinterpret_cast<char *>(&buffer), sizeof(float)*NUM_JOINTS*3);
    }
}

void ofApp::draw(){
    
    if(isTrackerAvailable) {
    
        depth_image.setFromPixels(tracker.getPixelsRef(1000, 4000));
        
        ofSetColor(255);
        depth_image.draw(0, 0);
        
        if(userId < 0) return;
        
        for(int i=0; i<tracker.getNumUser(); i++) {
            ofxNiTE2::User::Ref user = tracker.getUser(i);
            if(!user.get() || user->isLost() || !user->isVisible()) continue;
            drawUser(user);
        }
    }
}

void ofApp::drawUser(ofxNiTE2::User::Ref user){
    
    if (user->getId()==userId) {
        if(bSaving) {
            ofSetColor(ofColor::red);
        } else {
            ofSetColor(ofColor::blue);
        }
    }
    else ofSetColor(ofColor::royalBlue);
    
    for (int i=0; i<NUM_JOINTS; i++) {
        nite::JointType type = (nite::JointType)i;
        ofPoint p = tracker.getProjectiveJointPosition(user->getId(), type);
        ofCircle(p.x, p.y, 2);
    }
}

void ofApp::keyPressed(int key){
    if (key == 'w') {
        savingToFile.open("output.bin", ofFile::WriteOnly, true);
        bSaving = true;
//        file << "skeleton_data_header_start" << endl;
//        file << "sensor_width " << DEVICE_WIDTH << endl;
//        file << "sensor_height " << DEVICE_HEIGHT << endl;
//        file << "skeleton_data_header_end" << endl;
//        float time = ofGetElapsedTimef();
//        file.write( reinterpret_cast<char *>(&time), sizeof(float));
//        savingToFile.write( reinterpret_cast<char *>(&buffer), sizeof(float)*NUM_JOINTS*3);
        savingToFile.write( reinterpret_cast<char *>(&buffer), sizeof(float)*NUM_JOINTS*3);
//        savingToFile.close();
        ofLog() << "recording started";
    }
    else if (key == 'c' && bSaving) {
        savingToFile.close();
        bSaving = false;
        ofLog() << "recording stopped";
    }
}


//---- socket

void ofApp::onConnect( ofxLibwebsockets::Event& args ){
    cout<<"on connected"<<endl;
}
void ofApp::onOpen( ofxLibwebsockets::Event& args ){
    cout<<"on open"<<endl;
    args.conn.send("/ratio/"+ofToString(DEVICE_WIDTH)+"/"+ofToString(DEVICE_HEIGHT));
}
void ofApp::onClose( ofxLibwebsockets::Event& args ){
    cout<<"on close"<<endl;
}
void ofApp::onIdle( ofxLibwebsockets::Event& args ){
    cout<<"on idle"<<endl;
}
void ofApp::onMessage( ofxLibwebsockets::Event& args ){
    cout<<"got message "<<args.message<<endl;
}
void ofApp::onBroadcast( ofxLibwebsockets::Event& args ){
    cout<<"got broadcast "<<args.message<<endl;
}