#pragma once

#include "osc/OscOutboundPacketStream.h"
#include "ip/UdpSocket.h"
#include "stdafx.h"
#include <iostream>
#include <sstream>

#define ADDRESS "192.168.3.1"
#define PORT 7000
#define OUTPUT_BUFFER_SIZE 1024

class OSCSender
{
public:
	OSCSender();
	~OSCSender();

	void setBodyCount(int bodyCount);
	void addBody(UINT64 trackingId, const Joint* pJoints, const D2D1_POINT_2F* pJointPoints, int width, int height);
	void send();
	void sendMessage(std::string msg);

private:
	int currBodyCount;
	char buffer[OUTPUT_BUFFER_SIZE];
	osc::OutboundPacketStream packetStream;
	UdpTransmitSocket transmitSocket;
	bool bReset;
};

