//
//  ControlPointListener.h
//  UPnPSwitch
//
//  Created by zhang fan on 13-8-5.
//  Copyright (c) 2013年 twotrees. All rights reserved.
//

#ifndef __UPnPSwitch__ControlPointListener__
#define __UPnPSwitch__ControlPointListener__

#include <Platinum/Platinum.h>
#include <string>

#define DEVICE_TYPE                 "urn:twotrees-org:device:UPnPSwitch:1"
#define SERVICE_TYPE                "urn:twotrees-org:service:UPnPSwitch:1"

#define ACTION_NAME_QUERY_STATE     "QueryState"
#define ACTION_NAME_SET_VALUE       "SetValue"

#define ACTION_ARG_STATE            "State"
#define ACTION_ARG_INDEX            "Index"
#define ACTION_ARG_VALUE            "Value"

class CUPnPDeviceManager
: public PLT_CtrlPointListener
{
private:
	NPT_Lock<PLT_DeviceDataReferenceList> m_validDevices;
		
public:
	PLT_DeviceDataReference QueryDevice(const std::string& deviceId);
	
public:
	virtual NPT_Result OnDeviceAdded(PLT_DeviceDataReference& device);
    virtual NPT_Result OnDeviceRemoved(PLT_DeviceDataReference& device);
    virtual NPT_Result OnActionResponse(NPT_Result res, PLT_ActionReference& action, void* userdata);
    virtual NPT_Result OnEventNotify(PLT_Service* service, NPT_List<PLT_StateVariable*>* vars);
	
private:
    inline void _addDeviceByType(PLT_DeviceDataReference& device, const char* deviceType, const char* serviceType, NPT_Lock<PLT_DeviceDataReferenceList>& list);
    inline void _removeDeviceByType(PLT_DeviceDataReference& device, const char* deviceType, const char* serviceType, NPT_Lock<PLT_DeviceDataReferenceList>& list);
};

#endif /* defined(__UPnPSwitch__ControlPointListener__) */
