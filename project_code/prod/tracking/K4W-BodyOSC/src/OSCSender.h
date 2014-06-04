#pragma once

#include "osc/OscOutboundPacketStream.h"
#include "ip/UdpSocket.h"
#include "stdafx.h"
#include <iostream>
#include <sstream>
#include <vector>

#define ADDRESS "192.168.3.1"
#define PORT 7000
#define OUTPUT_BUFFER_SIZE 1024

struct Point3f
{
	float x;
	float y;
	float z;
};

class OSCBodyData
{
public:
	OSCBodyData(UINT64 id_) :id(id_){}
	UINT64 id;
	Point3f pts[15];
};

class OSCSender
{
public:
	OSCSender();
	~OSCSender();

	void reset();
	void addBody(UINT64 trackingId, const Joint* pJoints, const D2D1_POINT_2F* pJointPoints, int width, int height);
	void send();
	void sendMessage(std::string msg);

private:
	void updateBodyCount();
	int getMostLegitimateBody();
	UINT64 getMostCenteredBodyId();
	UINT64 currLegitimateTrackingId;
	int newcomerNumPresence;
	UINT64 newcomerId;

	UINT64 getBodyIdFromTrackingId(UINT64 trackingId);
	
	int prevBodyCount;
	std::vector<OSCBodyData> bodies;
	
	char buffer[OUTPUT_BUFFER_SIZE];
	osc::OutboundPacketStream packetStream;
	UdpTransmitSocket transmitSocket;
};

