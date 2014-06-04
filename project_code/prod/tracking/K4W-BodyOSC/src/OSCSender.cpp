#include "OSCSender.h"


void WinLog(const wchar_t *text, int n)
{
	wchar_t buf[1024];
	_snwprintf_s(buf, 1024, _TRUNCATE, L"%s %d\n", text, n);
	OutputDebugString(buf);
}

OSCSender::OSCSender() :
transmitSocket( IpEndpointName(ADDRESS, PORT) ),
packetStream(buffer, OUTPUT_BUFFER_SIZE)
{
	prevBodyCount = 0;
	currLegitimateTrackingId = -1;
	newcomerNumPresence = 0;
	newcomerId = -1;
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

void OSCSender::reset() {
	bodies.clear();
}

void OSCSender::addBody(UINT64 trackingId, const Joint* pJoints, const D2D1_POINT_2F* pJointPoints, int width, int height){
	int JOINTS_REF[15] = {
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
	OSCBodyData body(trackingId);
	int i;
	for (int j=0; j < 15; j++)
	{
		i = JOINTS_REF[j];
		body.pts[j].x = pJointPoints[i].x / width - 0.5;
		body.pts[j].y = pJointPoints[i].y / height - 0.5;
		body.pts[j].z = 3000 - pJoints[i].Position.Z * 1000;
	}
	bodies.push_back(body);
}

void OSCSender::updateBodyCount(){
	int bodyCount = bodies.size();
	if (bodyCount != prevBodyCount) {
		if (prevBodyCount == 0 && bodyCount > 0) {
			currLegitimateTrackingId = bodies[0].id;
			WinLog(L"First user (legitimate)", currLegitimateTrackingId);
			sendMessage("/first_user_entered");
		}
		else if (prevBodyCount > 0 && bodyCount == 0) {
			WinLog(L"Lost last user", currLegitimateTrackingId);
			currLegitimateTrackingId = -1;
			newcomerNumPresence = 0;
			newcomerId = -1;
			sendMessage("/last_user_left");
		}
		prevBodyCount = bodyCount;
	}
}

UINT64 OSCSender::getMostCenteredBodyId() {

	if (bodies.size() == 1) {
		return bodies[0].id;
	}

	UINT64 closestToCenter = -1;
	float distanceToCenter = 99999.f;
	for (int i = 0; i < bodies.size(); i++)
	{
		float spineDist = abs( bodies[i].pts[8].x );
		if (spineDist < distanceToCenter) {
			closestToCenter = bodies[i].id;
			distanceToCenter = spineDist;
		}
	}
	return closestToCenter;
}

UINT64 OSCSender::getBodyIdFromTrackingId(UINT64 trackingId) {
	 for (int i = 0; i < bodies.size(); i++)
	 {
		 if (bodies[i].id == trackingId) {
			 return i;
		 }
	 }
	 return -1;
}

int OSCSender::getMostLegitimateBody() {
	if (bodies.size() == 1) {
		return 0;
	}
	UINT64 legitimate = getMostCenteredBodyId();
	if (legitimate != currLegitimateTrackingId) {
		if (legitimate != newcomerId) {
			WinLog(L"New Comer", legitimate);
			newcomerId = legitimate;
			newcomerNumPresence = 0;
		}
		if (newcomerNumPresence++ > 60) {
			WinLog(L"New legitimate", legitimate);
			currLegitimateTrackingId = legitimate;
			newcomerId = -1;
			newcomerNumPresence = 0;
		}
	}
	else {
		if (newcomerNumPresence > 0) {
			WinLog(L"Reset new comer presence", legitimate);
			newcomerNumPresence = 0;
		}
	}

	if (currLegitimateTrackingId != -1) {
		return getBodyIdFromTrackingId(currLegitimateTrackingId);
	}
	return -1;
}

void OSCSender::send(){

	updateBodyCount();
	if (prevBodyCount == 0) {
		return;
	}

	int userId = getMostLegitimateBody();
	if (userId == -1) return;
	const OSCBodyData & body = bodies[userId];

	packetStream.Clear();
	packetStream
		<< osc::BeginBundleImmediate
		<< osc::BeginMessage("/skeleton");
	for(int i = 0; i < 15; i++)
	{
		packetStream
			<< static_cast<float>(body.pts[i].x)
			<< static_cast<float>(body.pts[i].y)
			<< static_cast<float>(body.pts[i].z);
	}
	packetStream
		<< osc::EndMessage
		<< osc::EndBundle;
	transmitSocket.Send(packetStream.Data(), packetStream.Size());
}