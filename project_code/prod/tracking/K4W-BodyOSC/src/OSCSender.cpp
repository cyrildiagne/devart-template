#include "OSCSender.h"

OSCSender::OSCSender() :
transmitSocket( IpEndpointName(ADDRESS, PORT) ),
packetStream(buffer, OUTPUT_BUFFER_SIZE)
{
	bReset = true;
	currBodyCount = 0;
}

OSCSender::~OSCSender()
{
}


void OSCSender::sendMessage(std::string msg){
	char buff[128];
	osc::OutboundPacketStream strm(buff, 128);
	strm << osc::BeginBundleImmediate;
	strm << osc::BeginMessage(msg.c_str()) << osc::EndMessage;
	strm << osc::EndBundle;
	transmitSocket.Send(strm.Data(), strm.Size());
}

void OSCSender::setBodyCount(int bodyCount){
	if (bodyCount != currBodyCount) {
		if (currBodyCount == 0 && bodyCount > 0) {
			sendMessage("/first_user_entered");
			OutputDebugStringW(L"First user entered\n");
		}
		else if (currBodyCount > 0 && bodyCount == 0) {
			sendMessage("/last_user_left");
			OutputDebugStringW(L"Last user left\n");
		}
		std::wstringstream ss;
		ss << "new body count " << bodyCount << std::endl;
		OutputDebugStringW(ss.str().c_str());
		currBodyCount = bodyCount;
	}
}

void OSCSender::addBody(UINT64 trackingId, const Joint* pJoints, const D2D1_POINT_2F* pJointPoints, int width, int height){

	if (bReset) {
		packetStream.Clear();
		packetStream << osc::BeginBundleImmediate;
		bReset = false;
	}

	int jts[15] = {
		JointType_Head,
		JointType_Neck,
		JointType_ShoulderLeft,
		JointType_ShoulderRight,
		JointType_ElbowLeft,
		JointType_ElbowRight,
		JointType_WristLeft,
		JointType_WristRight,
		JointType_SpineMid,
		JointType_HipLeft,
		JointType_HipRight,
		JointType_KneeLeft,
		JointType_KneeRight,
		JointType_AnkleLeft,
		JointType_AnkleRight
	};

	packetStream << osc::BeginMessage("/skeleton")
		<< (int)trackingId;
	
	for (int j=0; j < 15; j++)
	{
		int i = jts[j];
		packetStream
			<< static_cast<float>(pJointPoints[i].x / width - 0.5)
			<< static_cast<float>(pJointPoints[i].y / height - 0.5)
			<< static_cast<float>(3000 - pJoints[i].Position.Z*1000);
	}
	packetStream << osc::EndMessage;
}

void OSCSender::send(){
	packetStream << osc::EndBundle;
	transmitSocket.Send(packetStream.Data(), packetStream.Size());

	bReset = true;
}